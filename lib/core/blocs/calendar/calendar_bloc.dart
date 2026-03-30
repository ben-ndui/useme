import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:smoothandesign_package/core/models/calendar_connection.dart';
import '../../models/google_calendar_event.dart';
import 'package:smoothandesign_package/core/models/unavailability.dart';
import '../../services/unavailability_service.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';
import 'package:useme/core/utils/app_logger.dart';

/// CalendarBloc - gère la connexion calendrier et les indisponibilités
class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final UnavailabilityService _unavailabilityService;
  StreamSubscription<List<Unavailability>>? _unavailabilitiesSubscription;

  // URL de base de l'API (note: /api/api car le nom de la fonction est 'api')
  static const String _baseUrl =
      'https://europe-west1-uzme-app.cloudfunctions.net/api/api';

  CalendarBloc({UnavailabilityService? unavailabilityService})
      : _unavailabilityService = unavailabilityService ?? UnavailabilityService(),
        super(const CalendarInitialState()) {
    on<ResetCalendarEvent>(_onReset);
    on<LoadCalendarStatusEvent>(_onLoadStatus);
    on<ConnectGoogleCalendarEvent>(_onConnectGoogle);
    on<DisconnectCalendarEvent>(_onDisconnect);
    on<SyncCalendarEvent>(_onSync);
    on<LoadUnavailabilitiesEvent>(_onLoadUnavailabilities);
    on<UnavailabilitiesUpdatedEvent>(_onUnavailabilitiesUpdated);
    on<AddUnavailabilityEvent>(_onAddUnavailability);
    on<DeleteUnavailabilityEvent>(_onDeleteUnavailability);
    on<CalendarConnectedEvent>(_onCalendarConnected);
    // Import preview handlers
    on<FetchCalendarPreviewEvent>(_onFetchPreview);
    on<ImportCategorizedEventsEvent>(_onImportCategorized);
  }

  /// Reset calendar state (called on logout)
  Future<void> _onReset(
    ResetCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    appLog('📅 [CalendarBloc] Reset calendar state');
    await _unavailabilitiesSubscription?.cancel();
    _unavailabilitiesSubscription = null;
    emit(const CalendarInitialState());
  }

  /// Charge le statut de connexion du calendrier
  Future<void> _onLoadStatus(
    LoadCalendarStatusEvent event,
    Emitter<CalendarState> emit,
  ) async {
    emit(const CalendarLoadingState());
    appLog('📅 [CalendarBloc] LoadCalendarStatus pour userId: ${event.userId}');

    try {
      final url = '$_baseUrl/calendar/status/${event.userId}';
      appLog('📅 [CalendarBloc] GET $url');

      final response = await http.get(Uri.parse(url));
      appLog('📅 [CalendarBloc] Response status: ${response.statusCode}');
      appLog('📅 [CalendarBloc] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final connected = data['connected'] as bool? ?? false;
        appLog('📅 [CalendarBloc] Connected: $connected');

        if (connected) {
          final connection = CalendarConnection(
            provider: CalendarProvider.fromString(data['provider'] as String?),
            connected: true,
            email: data['email'] as String?,
            lastSync: data['lastSync'] != null
                ? DateTime.tryParse(data['lastSync'].toString())
                : null,
          );
          appLog('📅 [CalendarBloc] Connection: email=${connection.email}, lastSync=${connection.lastSync}');

          emit(CalendarConnectedState(connection: connection));

          // Charger les indisponibilités
          add(LoadUnavailabilitiesEvent(studioId: event.userId));
        } else {
          emit(const CalendarDisconnectedState());
        }
      } else {
        appLog('📅 [CalendarBloc] Non-200 response, émit DisconnectedState');
        emit(const CalendarDisconnectedState());
      }
    } catch (e) {
      appLog('📅 [CalendarBloc] Erreur: $e');
      emit(CalendarErrorState(message: e.toString()));
    }
  }

  /// Connecte Google Calendar
  Future<void> _onConnectGoogle(
    ConnectGoogleCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    emit(const CalendarLoadingState());

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/calendar/google/auth-url'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': event.userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final authUrl = data['authUrl'] as String;

        // Ouvrir l'URL OAuth dans le navigateur
        final uri = Uri.parse(authUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          emit(CalendarAuthUrlReadyState(authUrl: authUrl));
        } else {
          emit(const CalendarErrorState(message: 'Impossible d\'ouvrir le navigateur'));
        }
      } else {
        emit(CalendarErrorState(message: 'Erreur: ${response.body}'));
      }
    } catch (e) {
      emit(CalendarErrorState(message: e.toString()));
    }
  }

  /// Déconnecte le calendrier
  Future<void> _onDisconnect(
    DisconnectCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    emit(const CalendarLoadingState());

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/calendar/disconnect'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': event.userId}),
      );

      if (response.statusCode == 200) {
        emit(const CalendarDisconnectedState());
      } else {
        emit(CalendarErrorState(message: 'Erreur de déconnexion'));
      }
    } catch (e) {
      emit(CalendarErrorState(message: e.toString()));
    }
  }

  /// Synchronise le calendrier
  Future<void> _onSync(
    SyncCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    appLog('📅 [CalendarBloc] SyncCalendar pour userId: ${event.userId}');
    final currentState = state;
    if (currentState is CalendarConnectedState) {
      emit(currentState.copyWith(isSyncing: true));

      try {
        final url = '$_baseUrl/calendar/sync';
        appLog('📅 [CalendarBloc] POST $url');

        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'userId': event.userId}),
        );

        appLog('📅 [CalendarBloc] Sync response status: ${response.statusCode}');
        appLog('📅 [CalendarBloc] Sync response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body)['data'];
          appLog('📅 [CalendarBloc] Sync data: deleted=${data['deleted']}, created=${data['created']}');
          // Recharger les indisponibilités
          add(LoadUnavailabilitiesEvent(studioId: event.userId));
        } else {
          appLog('📅 [CalendarBloc] Sync failed avec status ${response.statusCode}');
          emit(currentState.copyWith(isSyncing: false));
        }
      } catch (e) {
        appLog('📅 [CalendarBloc] Sync erreur: $e');
        emit(currentState.copyWith(isSyncing: false));
      }
    } else {
      appLog('📅 [CalendarBloc] Sync ignoré - state n\'est pas CalendarConnectedState');
    }
  }

  /// Charge les indisponibilités
  Future<void> _onLoadUnavailabilities(
    LoadUnavailabilitiesEvent event,
    Emitter<CalendarState> emit,
  ) async {
    appLog('📅 [CalendarBloc] LoadUnavailabilities pour studioId: ${event.studioId}');
    // Annuler l'ancien stream
    await _unavailabilitiesSubscription?.cancel();

    // Écouter les nouvelles indisponibilités et dispatcher un event
    _unavailabilitiesSubscription = _unavailabilityService
        .streamByStudioId(event.studioId)
        .listen((unavailabilities) {
      appLog('📅 [CalendarBloc] Stream reçu: ${unavailabilities.length} indisponibilités');
      // Dispatch internal event instead of emitting directly
      add(UnavailabilitiesUpdatedEvent(unavailabilities: unavailabilities));
    });
  }

  /// Handler for stream updates
  void _onUnavailabilitiesUpdated(
    UnavailabilitiesUpdatedEvent event,
    Emitter<CalendarState> emit,
  ) {
    appLog('📅 [CalendarBloc] UnavailabilitiesUpdated: ${event.unavailabilities.length} items');
    for (final u in event.unavailabilities) {
      appLog('📅   - ${u.title ?? 'Sans titre'} | source: ${u.source} | ${u.start} -> ${u.end}');
    }

    final currentState = state;
    if (currentState is CalendarConnectedState) {
      emit(currentState.copyWith(
        unavailabilities: event.unavailabilities,
        isSyncing: false,
      ));
    } else if (currentState is CalendarDisconnectedState) {
      emit(CalendarDisconnectedState(
        manualUnavailabilities: event.unavailabilities
            .where((u) => u.source == UnavailabilitySource.manual)
            .toList(),
      ));
    }
  }

  /// Ajoute une indisponibilité manuelle
  Future<void> _onAddUnavailability(
    AddUnavailabilityEvent event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      await _unavailabilityService.create(event.unavailability);
      emit(UnavailabilityAddedState(unavailability: event.unavailability));
    } catch (e) {
      emit(CalendarErrorState(message: e.toString()));
    }
  }

  /// Supprime une indisponibilité
  Future<void> _onDeleteUnavailability(
    DeleteUnavailabilityEvent event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      await _unavailabilityService.delete(event.unavailabilityId);
      emit(UnavailabilityDeletedState(unavailabilityId: event.unavailabilityId));
    } catch (e) {
      emit(CalendarErrorState(message: e.toString()));
    }
  }

  /// Callback après connexion OAuth
  Future<void> _onCalendarConnected(
    CalendarConnectedEvent event,
    Emitter<CalendarState> emit,
  ) async {
    if (event.success) {
      // Recharger le statut
      add(LoadCalendarStatusEvent(userId: event.userId));
    } else {
      emit(CalendarErrorState(message: event.error ?? 'Connexion échouée'));
    }
  }

  // ===========================================================================
  // IMPORT PREVIEW HANDLERS
  // ===========================================================================

  /// Récupère les événements Google Calendar pour preview
  Future<void> _onFetchPreview(
    FetchCalendarPreviewEvent event,
    Emitter<CalendarState> emit,
  ) async {
    emit(const CalendarPreviewLoadingState());
    appLog('📅 [CalendarBloc] FetchPreview pour userId: ${event.userId}');

    try {
      // Construire l'URL avec les paramètres de date optionnels
      final queryParams = <String, String>{};
      if (event.startDate != null) {
        queryParams['startDate'] = event.startDate!.toIso8601String();
      }
      if (event.endDate != null) {
        queryParams['endDate'] = event.endDate!.toIso8601String();
      }

      final uri = Uri.parse('$_baseUrl/calendar/events/preview/${event.userId}')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

      appLog('📅 [CalendarBloc] GET $uri');

      final response = await http.get(uri);
      appLog('📅 [CalendarBloc] Preview response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final eventsList = data['events'] as List<dynamic>;
        final dateRange = data['dateRange'] as Map<String, dynamic>?;

        final events = eventsList
            .map((e) => GoogleCalendarEvent.fromJson(e as Map<String, dynamic>))
            .toList();

        appLog('📅 [CalendarBloc] ${events.length} events chargés');
        appLog('📅 [CalendarBloc] Date range: ${dateRange?['start']} -> ${dateRange?['end']}');

        emit(CalendarPreviewLoadedState(
          events: events,
          startDate: dateRange != null ? DateTime.tryParse(dateRange['start']) : null,
          endDate: dateRange != null ? DateTime.tryParse(dateRange['end']) : null,
        ));
      } else {
        final error = json.decode(response.body)['message'] ?? 'Erreur';
        appLog('📅 [CalendarBloc] Preview error: $error');
        emit(CalendarErrorState(message: error));
      }
    } catch (e) {
      appLog('📅 [CalendarBloc] Preview exception: $e');
      emit(CalendarErrorState(message: e.toString()));
    }
  }

  /// Importe les événements catégorisés
  Future<void> _onImportCategorized(
    ImportCategorizedEventsEvent event,
    Emitter<CalendarState> emit,
  ) async {
    emit(const CalendarImportingState());
    appLog('📅 [CalendarBloc] Import ${event.events.length} events');

    try {
      // Filtrer les events à importer (exclure les skip)
      final eventsToImport = event.events
          .where((e) => e.importType != ImportType.skip)
          .map((e) => e.toImportJson())
          .toList();

      if (eventsToImport.isEmpty) {
        appLog('📅 [CalendarBloc] Aucun event à importer');
        emit(const CalendarImportSuccessState(
          sessionsCreated: 0,
          unavailabilitiesCreated: 0,
        ));
        return;
      }

      appLog('📅 [CalendarBloc] ${eventsToImport.length} events à envoyer');

      final response = await http.post(
        Uri.parse('$_baseUrl/calendar/import'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': event.userId,
          'events': eventsToImport,
        }),
      );

      appLog('📅 [CalendarBloc] Import response: ${response.statusCode}');
      appLog('📅 [CalendarBloc] Import body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        emit(CalendarImportSuccessState(
          sessionsCreated: data['sessionsCreated'] as int? ?? 0,
          unavailabilitiesCreated: data['unavailabilitiesCreated'] as int? ?? 0,
        ));
      } else {
        final error = json.decode(response.body)['message'] ?? 'Erreur';
        emit(CalendarErrorState(message: error));
      }
    } catch (e) {
      appLog('📅 [CalendarBloc] Import exception: $e');
      emit(CalendarErrorState(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _unavailabilitiesSubscription?.cancel();
    return super.close();
  }
}
