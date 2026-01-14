import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/config/useme_theme.dart';
import 'package:useme/core/blocs/map/map_bloc.dart';
import 'package:useme/core/blocs/map/map_event.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Bottom sheet for filtering map studios
class MapFilterSheet extends StatefulWidget {
  const MapFilterSheet({super.key});

  static void show(BuildContext context) {
    final mapBloc = context.read<MapBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: mapBloc,
        child: const MapFilterSheet(),
      ),
    );
  }

  @override
  State<MapFilterSheet> createState() => _MapFilterSheetState();
}

class _MapFilterSheetState extends State<MapFilterSheet> {
  late Set<String> _selectedServices;
  late bool _partnerOnly;

  static const _availableServices = [
    'Enregistrement',
    'Mixage',
    'Mastering',
    'Production',
    'Beatmaking',
    'Podcast',
    'Voix Off',
    'Répétition',
  ];

  @override
  void initState() {
    super.initState();
    final state = context.read<MapBloc>().state;
    _selectedServices = Set.from(state.serviceFilters);
    _partnerOnly = state.partnerOnly;
  }

  void _applyFilters() {
    context.read<MapBloc>().add(UpdateFiltersEvent(
          serviceFilters: _selectedServices,
          partnerOnly: _partnerOnly,
        ));
    Navigator.pop(context);
  }

  void _clearFilters() {
    context.read<MapBloc>().add(const ClearFiltersEvent());
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
          _buildPartnerToggle(theme, l10n),
          const Divider(),
          _buildServicesSection(theme, l10n),
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
              child: FaIcon(FontAwesomeIcons.sliders, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.filterStudios,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  l10n.filterDescription,
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

  Widget _buildPartnerToggle(ThemeData theme, AppLocalizations l10n) {
    return SwitchListTile(
      title: Text(l10n.partnerStudiosOnly, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(l10n.partnerStudiosDescription),
      value: _partnerOnly,
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return UseMeTheme.primaryColor;
        }
        return null;
      }),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const FaIcon(FontAwesomeIcons.solidStar, size: 16, color: Colors.green),
      ),
      onChanged: (value) => setState(() => _partnerOnly = value),
    );
  }

  Widget _buildServicesSection(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.serviceTypes,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableServices.map((service) {
              final isSelected = _selectedServices.contains(service);
              return FilterChip(
                label: Text(service),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedServices.add(service);
                    } else {
                      _selectedServices.remove(service);
                    }
                  });
                },
                selectedColor: UseMeTheme.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: UseMeTheme.primaryColor,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme, AppLocalizations l10n) {
    final hasFilters = _selectedServices.isNotEmpty || _partnerOnly;

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
