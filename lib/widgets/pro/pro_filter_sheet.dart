import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/pro_profile.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Bottom sheet for filtering pro search results.
class ProFilterSheet extends StatefulWidget {
  final List<ProType> selectedTypes;
  final String? city;
  final bool remoteOnly;
  final String? textQuery;
  final ValueChanged<ProFilterParams> onApply;

  const ProFilterSheet({
    super.key,
    required this.selectedTypes,
    this.city,
    this.remoteOnly = false,
    this.textQuery,
    required this.onApply,
  });

  static void show(
    BuildContext context, {
    required List<ProType> selectedTypes,
    String? city,
    bool remoteOnly = false,
    String? textQuery,
    required ValueChanged<ProFilterParams> onApply,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProFilterSheet(
        selectedTypes: selectedTypes,
        city: city,
        remoteOnly: remoteOnly,
        textQuery: textQuery,
        onApply: onApply,
      ),
    );
  }

  @override
  State<ProFilterSheet> createState() => _ProFilterSheetState();
}

class _ProFilterSheetState extends State<ProFilterSheet> {
  late Set<ProType> _selectedTypes;
  late TextEditingController _cityController;
  late bool _remoteOnly;

  @override
  void initState() {
    super.initState();
    _selectedTypes = Set.from(widget.selectedTypes);
    _cityController = TextEditingController(text: widget.city ?? '');
    _remoteOnly = widget.remoteOnly;
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _apply() {
    widget.onApply(ProFilterParams(
      types: _selectedTypes.toList(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      remoteOnly: _remoteOnly,
    ));
    Navigator.pop(context);
  }

  void _clear() {
    widget.onApply(const ProFilterParams());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hasFilters =
        _selectedTypes.isNotEmpty || _remoteOnly || _cityController.text.isNotEmpty;

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
          _buildRemoteToggle(theme, l10n),
          const Divider(),
          _buildCityField(theme, l10n),
          const Divider(),
          _buildTypeSection(theme, l10n),
          _buildActions(theme, l10n, hasFilters),
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
              child: FaIcon(FontAwesomeIcons.sliders, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.proFilterTitle,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  l10n.proFilterDesc,
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

  Widget _buildRemoteToggle(ThemeData theme, AppLocalizations l10n) {
    return SwitchListTile(
      title: Text(l10n.proFilterRemoteOnly,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(l10n.proFilterRemoteDesc),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const FaIcon(FontAwesomeIcons.wifi, size: 16, color: Colors.green),
      ),
      value: _remoteOnly,
      onChanged: (v) => setState(() => _remoteOnly = v),
    );
  }

  Widget _buildCityField(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: _cityController,
        decoration: InputDecoration(
          labelText: l10n.proFilterCity,
          hintText: l10n.proFilterCityHint,
          prefixIcon: const Icon(Icons.location_city, size: 20),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildTypeSection(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.proProfileTypeLabel,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ProType.values.map((type) {
              final isSelected = _selectedTypes.contains(type);
              return FilterChip(
                label: Text(type.label),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTypes.add(type);
                    } else {
                      _selectedTypes.remove(type);
                    }
                  });
                },
                selectedColor:
                    theme.colorScheme.primary.withValues(alpha: 0.2),
                checkmarkColor: theme.colorScheme.primary,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme, AppLocalizations l10n, bool hasFilters) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (hasFilters) ...[
            OutlinedButton.icon(
              onPressed: _clear,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.clearFilters, overflow: TextOverflow.ellipsis),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: FilledButton(
              onPressed: _apply,
              child: Text(l10n.applyFilters),
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter parameters for pro search.
class ProFilterParams {
  final List<ProType> types;
  final String? city;
  final bool remoteOnly;

  const ProFilterParams({
    this.types = const [],
    this.city,
    this.remoteOnly = false,
  });

  bool get hasActiveFilters =>
      types.isNotEmpty || city != null || remoteOnly;
}
