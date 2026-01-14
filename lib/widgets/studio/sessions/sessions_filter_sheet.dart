import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:useme/core/models/session.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Filter options for studio/engineer sessions
class SessionFilters {
  final SessionStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;

  const SessionFilters({this.status, this.startDate, this.endDate});

  bool get hasFilters => status != null || startDate != null || endDate != null;
  bool get hasDateRange => startDate != null && endDate != null;

  SessionFilters copyWith({SessionStatus? status, DateTime? startDate, DateTime? endDate, bool clearAll = false}) {
    if (clearAll) return const SessionFilters();
    return SessionFilters(
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  static const empty = SessionFilters();
}

/// Filter bottom sheet for sessions with status and date range
class SessionsFilterSheet extends StatefulWidget {
  final SessionFilters currentFilters;
  final ValueChanged<SessionFilters> onFiltersChanged;

  const SessionsFilterSheet({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  static void show(
    BuildContext context, {
    required SessionFilters currentFilters,
    required ValueChanged<SessionFilters> onFiltersChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SessionsFilterSheet(
        currentFilters: currentFilters,
        onFiltersChanged: onFiltersChanged,
      ),
    );
  }

  @override
  State<SessionsFilterSheet> createState() => _SessionsFilterSheetState();
}

class _SessionsFilterSheetState extends State<SessionsFilterSheet> {
  late SessionStatus? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentFilters.status;
    _startDate = widget.currentFilters.startDate;
    _endDate = widget.currentFilters.endDate;
  }

  void _applyFilters() {
    widget.onFiltersChanged(SessionFilters(status: _selectedStatus, startDate: _startDate, endDate: _endDate));
    Navigator.pop(context);
  }

  void _clearFilters() {
    widget.onFiltersChanged(SessionFilters.empty);
    Navigator.pop(context);
  }

  Future<void> _selectDateRange() async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      initialDateRange: _startDate != null && _endDate != null ? DateTimeRange(start: _startDate!, end: _endDate!) : null,
      helpText: l10n.selectDateRange,
      saveText: l10n.confirm,
      cancelText: l10n.cancel,
    );
    if (result != null) {
      setState(() {
        _startDate = result.start;
        _endDate = result.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(theme),
          _buildHeader(theme, l10n),
          const Divider(),
          _buildDateRangeSection(theme, l10n),
          const SizedBox(height: 8),
          _buildStatusSection(theme, l10n),
          _buildActions(theme, l10n),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: FaIcon(FontAwesomeIcons.filter, size: 18)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.filterSessions, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(l10n.filterSessionsDescription, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSection(ThemeData theme, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat('d MMM yyyy', locale);
    final hasRange = _startDate != null && _endDate != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.dateRange, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          InkWell(
            onTap: _selectDateRange,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: hasRange ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: hasRange ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5)) : null,
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.calendarDays,
                    size: 16,
                    color: hasRange ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasRange ? '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}' : l10n.selectDateRange,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: hasRange ? FontWeight.w500 : FontWeight.w400,
                        color: hasRange ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (hasRange)
                    GestureDetector(
                      onTap: () => setState(() {
                        _startDate = null;
                        _endDate = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: FaIcon(FontAwesomeIcons.xmark, size: 14, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(ThemeData theme, AppLocalizations l10n) {
    final statusOptions = [
      (null, l10n.all, theme.colorScheme.primary),
      (SessionStatus.pending, l10n.pendingStatus, Colors.orange),
      (SessionStatus.confirmed, l10n.confirmed, Colors.blue),
      (SessionStatus.inProgress, l10n.inProgressStatus, Colors.green),
      (SessionStatus.completed, l10n.completedStatus, Colors.grey),
      (SessionStatus.cancelled, l10n.cancelledStatus, Colors.red),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.statusLabel, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: statusOptions.map((option) {
              final (status, label, color) = option;
              final isSelected = _selectedStatus == status;
              return FilterChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedStatus = status),
                selectedColor: color.withValues(alpha: 0.2),
                checkmarkColor: color,
                avatar: isSelected ? null : Icon(Icons.circle, size: 12, color: color),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme, AppLocalizations l10n) {
    final hasFilters = _selectedStatus != null || _startDate != null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (hasFilters) ...[
            OutlinedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.clearFilters, overflow: TextOverflow.ellipsis),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: FilledButton(onPressed: _applyFilters, child: Text(l10n.applyFilters)),
          ),
        ],
      ),
    );
  }
}
