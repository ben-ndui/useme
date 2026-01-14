import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/session.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Filter options for artist sessions
class ArtistSessionFilters {
  final Set<SessionStatus> statuses;

  const ArtistSessionFilters({this.statuses = const {}});

  bool get hasFilters => statuses.isNotEmpty;

  ArtistSessionFilters copyWith({Set<SessionStatus>? statuses}) {
    return ArtistSessionFilters(statuses: statuses ?? this.statuses);
  }

  static const empty = ArtistSessionFilters();
}

/// Bottom sheet for filtering artist sessions
class ArtistSessionFilterSheet extends StatefulWidget {
  final ArtistSessionFilters currentFilters;
  final void Function(ArtistSessionFilters) onApply;

  const ArtistSessionFilterSheet({
    super.key,
    required this.currentFilters,
    required this.onApply,
  });

  static void show(
    BuildContext context, {
    required ArtistSessionFilters currentFilters,
    required void Function(ArtistSessionFilters) onApply,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ArtistSessionFilterSheet(
        currentFilters: currentFilters,
        onApply: onApply,
      ),
    );
  }

  @override
  State<ArtistSessionFilterSheet> createState() => _ArtistSessionFilterSheetState();
}

class _ArtistSessionFilterSheetState extends State<ArtistSessionFilterSheet> {
  late Set<SessionStatus> _selectedStatuses;

  @override
  void initState() {
    super.initState();
    _selectedStatuses = Set.from(widget.currentFilters.statuses);
  }

  void _applyFilters() {
    widget.onApply(ArtistSessionFilters(statuses: _selectedStatuses));
    Navigator.pop(context);
  }

  void _clearFilters() {
    widget.onApply(ArtistSessionFilters.empty);
    Navigator.pop(context);
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
            child: const Center(
              child: FaIcon(FontAwesomeIcons.filter, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.filterSessions,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  l10n.filterSessionsDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(ThemeData theme, AppLocalizations l10n) {
    final statusOptions = [
      (SessionStatus.pending, l10n.pendingStatus, Colors.orange),
      (SessionStatus.confirmed, l10n.confirmedStatus, Colors.green),
      (SessionStatus.inProgress, l10n.inProgressStatus, Colors.blue),
      (SessionStatus.completed, l10n.completedStatus, Colors.grey),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statusLabel,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: statusOptions.map((option) {
              final (status, label, color) = option;
              final isSelected = _selectedStatuses.contains(status);
              return FilterChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedStatuses.add(status);
                    } else {
                      _selectedStatuses.remove(status);
                    }
                  });
                },
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
    final hasFilters = _selectedStatuses.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (hasFilters) ...[
            OutlinedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.clearFilters, overflow: TextOverflow.ellipsis),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: FilledButton(
              onPressed: _applyFilters,
              child: Text(l10n.applyFilters),
            ),
          ),
        ],
      ),
    );
  }
}
