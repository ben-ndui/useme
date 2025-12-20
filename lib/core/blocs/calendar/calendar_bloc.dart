import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../../models/calendar_connection.dart';
import '../../models/unavailability.dart';
import '../../services/unavailability_service.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

/// CalendarBloc - gère la connexion calendrier et les indisponibilités
class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final UnavailabilityService _unavailabilityService;
  StreamSubscription<List<Unavailability>>? _unavailabilitiesSubscription;

  // URL de base de l'API (note: /api/api car le nom de la fonction est 'api')
  static const String _baseUrl =
      'https://us-central1-smoothandesign.cloudfunctions.net/api/api';

  CalendarBloc({UnavailabilityService? unavailabilityService})
      : _unavailabilityService = unavailabilityService ?? UnavailabilityService(),
        super(const CalendarInitialState()) {
    on<LoadCalendarStatusEvent>(_onLoadStatus);
    on<ConnectGoogleCalendarEvent>(_onConnectGoogle);
    on<DisconnectCalendarEvent>(_onDisconnect);
    on<SyncCalendarEvent>(_onSync);
    on<LoadUnavailabilitiesEvent>(_onLoadUnavailabilities);
    on<AddUnavailabilityEvent>(_onAddUnavailability);
    on<DeleteUnavailabilityEvent>(_onDeleteUnavailability);
    on<CalendarConnectedEvent>(_onCalendarConnected);
  }

  /// Charge le statut de connexion du calendrier
  Future<void> _onLoadStatus(
    LoadCalendarStatusEvent event,
    Emitter<CalendarState> emit,
  ) async {
    emit(const CalendarLoadingState());

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/calendar/status/${event.userId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final connected = data['connected'] as bool? ?? false;

        if (connected) {
          final connection = CalendarConnection(
            provider: CalendarProviderExtension.fromString(data['provider'] as String?),
            connected: true,
            email: data['email'] as String?,
            lastSync: data['lastSync'] != null
                ? DateTime.tryParse(data['lastSync'].toString())
                : null,
          );

          emit(CalendarConnectedState(connection: connection));

          // Charger les indisponibilités
          add(LoadUnavailabilitiesEvent(studioId: event.userId));
        } else {
          emit(const CalendarDisconnectedState());
        }
      } else {
        emit(const CalendarDisconnectedState());
      }
    } catch (e) {
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
    final currentState = state;
    if (currentState is CalendarConnectedState) {
      emit(currentState.copyWith(isSyncing: true));

      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/calendar/sync'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'userId': event.userId}),
        );

        if (response.statusCode == 200) {
          // Recharger les indisponibilités
          add(LoadUnavailabilitiesEvent(studioId: event.userId));
        } else {
          emit(currentState.copyWith(isSyncing: false));
        }
      } catch (e) {
        emit(currentState.copyWith(isSyncing: false));
      }
    }
  }

  /// Charge les indisponibilités
  Future<void> _onLoadUnavailabilities(
    LoadUnavailabilitiesEvent event,
    Emitter<CalendarState> emit,
  ) async {
    // Annuler l'ancien stream
    await _unavailabilitiesSubscription?.cancel();

    // Écouter les nouvelles indisponibilités
    _unavailabilitiesSubscription = _unavailabilityService
        .streamByStudioId(event.studioId)
        .listen((unavailabilities) {
      final currentState = state;
      if (currentState is CalendarConnectedState) {
        // ignore: invalid_use_of_visible_for_testing_member
        emit(currentState.copyWith(
          unavailabilities: unavailabilities,
          isSyncing: false,
        ));
      } else if (currentState is CalendarDisconnectedState) {
        // ignore: invalid_use_of_visible_for_testing_member
        emit(CalendarDisconnectedState(
          manualUnavailabilities: unavailabilities
              .where((u) => u.source == UnavailabilitySource.manual)
              .toList(),
        ));
      }
    });
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

  @override
  Future<void> close() {
    _unavailabilitiesSubscription?.cancel();
    return super.close();
  }
}
