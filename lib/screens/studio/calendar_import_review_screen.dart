import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/blocs/blocs_exports.dart';
import '../../core/models/artist.dart';
import '../../core/models/google_calendar_event.dart';
import '../../core/services/artist_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/snackbar/app_snackbar.dart';

/// Écran de review pour l'import des événements Google Calendar
class CalendarImportReviewScreen extends StatefulWidget {
  final String userId;

  const CalendarImportReviewScreen({super.key, required this.userId});

  @override
  State<CalendarImportReviewScreen> createState() =>
      _CalendarImportReviewScreenState();
}

class _CalendarImportReviewScreenState
    extends State<CalendarImportReviewScreen> {
  final ArtistService _artistService = ArtistService();
  List<Artist> _artists = [];
  List<GoogleCalendarEvent> _events = [];
  bool _isLoading = true;

  // Plage de dates pour l'import
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    // Par défaut: 30 jours avant → 90 jours après
    _startDate = DateTime.now().subtract(const Duration(days: 30));
    _endDate = DateTime.now().add(const Duration(days: 90));
    _loadData();
  }

  Future<void> _loadData() async {
    final artists = await _artistService.getArtistsByStudioId(widget.userId);
    if (!mounted) return;
    setState(() {
      _artists = artists;
      _isLoading = true;
    });
    context.read<CalendarBloc>().add(
          FetchCalendarPreviewEvent(
            userId: widget.userId,
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.importFromGoogleCalendar),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<CalendarBloc, CalendarState>(
        listener: (context, state) {
          if (state is CalendarPreviewLoadedState) {
            setState(() {
              _events = state.events;
              _isLoading = false;
            });
          } else if (state is CalendarImportSuccessState) {
            // Reload sessions to show imported data
            if (state.sessionsCreated > 0) {
              context.read<SessionBloc>().add(
                    LoadSessionsEvent(studioId: widget.userId),
                  );
            }

            // Reload calendar status to update lastSync
            context.read<CalendarBloc>().add(
                  LoadCalendarStatusEvent(userId: widget.userId),
                );

            AppSnackBar.success(
              context,
              l10n.importSuccessMessage(
                state.sessionsCreated,
                state.unavailabilitiesCreated,
              ),
            );
            context.pop();
          } else if (state is CalendarErrorState) {
            AppSnackBar.error(context, state.message);
            setState(() => _isLoading = false);
          }
        },
        builder: (context, state) {
          if (_isLoading || state is CalendarPreviewLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CalendarImportingState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.loading),
                ],
              ),
            );
          }

          if (_events.isEmpty) {
            return _buildEmptyState(context, l10n, theme);
          }

          return _buildEventsList(context, l10n, theme);
        },
      ),
      bottomNavigationBar: _events.isEmpty || _isLoading
          ? null
          : _buildBottomBar(context, l10n, theme),
    );
  }

  Widget _buildDateRangeSelector(ThemeData theme, AppLocalizations l10n) {
    final dateFormat = DateFormat('d MMM yyyy', 'fr_FR');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: InkWell(
        onTap: () => _selectDateRange(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.calendarDays,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dateRange,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${dateFormat.format(_startDate)} → ${dateFormat.format(_endDate)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit_calendar,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Column(
      children: [
        _buildDateRangeSelector(theme, l10n),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.calendarXmark,
                  size: 64,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noEventsToImport,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.tryChangingDateRange,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _selectDateRange(context),
                  icon: const Icon(Icons.date_range),
                  label: Text(l10n.changeDateRange),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventsList(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Column(
      children: [
        _buildDateRangeSelector(theme, l10n),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _events.length,
            itemBuilder: (context, index) {
              return _EventCard(
                event: _events[index],
                artists: _artists,
                l10n: l10n,
                onChanged: (updated) {
                  setState(() => _events[index] = updated);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final sessionsCount =
        _events.where((e) => e.importType == ImportType.session).length;
    final unavailCount =
        _events.where((e) => e.importType == ImportType.unavailability).length;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.importSummary(sessionsCount, unavailCount),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: (sessionsCount + unavailCount) > 0
                    ? () => _importEvents()
                    : null,
                icon: const FaIcon(FontAwesomeIcons.fileImport, size: 16),
                label: Text(l10n.importButton),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _importEvents() {
    context.read<CalendarBloc>().add(
          ImportCategorizedEventsEvent(
            userId: widget.userId,
            events: _events,
          ),
        );
  }
}

/// Carte pour un événement Google Calendar
class _EventCard extends StatelessWidget {
  final GoogleCalendarEvent event;
  final List<Artist> artists;
  final AppLocalizations l10n;
  final ValueChanged<GoogleCalendarEvent> onChanged;

  const _EventCard({
    required this.event,
    required this.artists,
    required this.l10n,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEE d MMM', 'fr_FR');
    final timeFormat = DateFormat('HH:mm', 'fr_FR');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre et dates
            Text(
              event.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              event.isAllDay
                  ? '${dateFormat.format(event.start)} - ${l10n.allDay}'
                  : '${dateFormat.format(event.start)} ${timeFormat.format(event.start)} - ${timeFormat.format(event.end)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 12),

            // Sélecteur de type
            SegmentedButton<ImportType>(
              segments: [
                ButtonSegment(
                  value: ImportType.session,
                  label: Text(l10n.importAsSession),
                  icon: const FaIcon(FontAwesomeIcons.microphone, size: 14),
                ),
                ButtonSegment(
                  value: ImportType.unavailability,
                  label: Text(l10n.importAsUnavailability),
                  icon: const FaIcon(FontAwesomeIcons.ban, size: 14),
                ),
                ButtonSegment(
                  value: ImportType.skip,
                  label: Text(l10n.skipImport),
                  icon: const FaIcon(FontAwesomeIcons.forward, size: 14),
                ),
              ],
              selected: {event.importType},
              onSelectionChanged: (selected) {
                onChanged(event.copyWith(
                  importType: selected.first,
                  selectedArtistId: null,
                  selectedArtistName: null,
                  externalArtistName: null,
                ));
              },
            ),

            // Sélection d'artiste si session
            if (event.importType == ImportType.session) ...[
              const SizedBox(height: 12),
              _ArtistSelector(
                event: event,
                artists: artists,
                l10n: l10n,
                onChanged: onChanged,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Sélecteur d'artiste pour les sessions
class _ArtistSelector extends StatefulWidget {
  final GoogleCalendarEvent event;
  final List<Artist> artists;
  final AppLocalizations l10n;
  final ValueChanged<GoogleCalendarEvent> onChanged;

  const _ArtistSelector({
    required this.event,
    required this.artists,
    required this.l10n,
    required this.onChanged,
  });

  @override
  State<_ArtistSelector> createState() => _ArtistSelectorState();
}

class _ArtistSelectorState extends State<_ArtistSelector> {
  final TextEditingController _externalController = TextEditingController();
  bool _showExternalField = false;

  @override
  void initState() {
    super.initState();
    _showExternalField = widget.event.externalArtistName != null;
    if (_showExternalField) {
      _externalController.text = widget.event.externalArtistName ?? '';
    }
  }

  @override
  void dispose() {
    _externalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown artistes existants
        if (!_showExternalField)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: widget.event.selectedArtistId,
              hint: Text(widget.l10n.selectAnArtist),
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: widget.artists
                  .map((artist) => DropdownMenuItem(
                        value: artist.id,
                        child: Text(artist.stageName ?? artist.name),
                      ))
                  .toList(),
              onChanged: (value) {
                final artist = widget.artists.firstWhere((a) => a.id == value);
                widget.onChanged(widget.event.copyWith(
                  selectedArtistId: value,
                  selectedArtistName: artist.stageName ?? artist.name,
                  externalArtistName: null,
                ));
              },
            ),
          ),

        // Lien pour créer artiste externe
        if (!_showExternalField && widget.artists.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: GestureDetector(
              onTap: () => setState(() => _showExternalField = true),
              child: Text(
                widget.l10n.orCreateExternal,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),

        // Champ artiste externe
        if (_showExternalField || widget.artists.isEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _externalController,
                      decoration: InputDecoration(
                        labelText: widget.l10n.externalArtistName,
                        hintText: widget.l10n.externalArtistHint,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) {
                        widget.onChanged(widget.event.copyWith(
                          selectedArtistId: null,
                          selectedArtistName: null,
                          externalArtistName: value.isNotEmpty ? value : null,
                        ));
                      },
                    ),
                  ),
                  if (widget.artists.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() => _showExternalField = false);
                        _externalController.clear();
                        widget.onChanged(widget.event.copyWith(
                          externalArtistName: null,
                        ));
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
      ],
    );
  }
}
