import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/common/app_loader.dart';

/// Services (catalog) list page
class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.serviceCatalogTitle),
      ),
      body: BlocBuilder<ServiceBloc, ServiceState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const AppLoader();
          }

          if (state.services.isEmpty) {
            return _buildEmptyState(context, l10n);
          }

          return RefreshIndicator(
            onRefresh: () async {
              // TODO: Refresh services
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.services.length,
              itemBuilder: (context, index) {
                return _buildServiceCard(context, state.services[index], l10n);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.serviceAdd),
        icon: const FaIcon(FontAwesomeIcons.plus, size: 18),
        label: Text(l10n.newService),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.tags, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            l10n.noService,
            style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.createServiceCatalog,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push(AppRoutes.serviceAdd),
            icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
            label: Text(l10n.newService),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, StudioService service, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/services/${service.id}/edit'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(_getServiceIcon(service.name), size: 20, color: theme.colorScheme.primary),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (service.description != null)
                      Text(
                        service.description!,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '${service.hourlyRate.toStringAsFixed(0)}€/h • min ${service.minDurationHours}h',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Status & arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: service.isActive ? Colors.green.shade50 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      service.isActive ? l10n.active : l10n.inactive,
                      style: TextStyle(
                        fontSize: 11,
                        color: service.isActive ? Colors.green.shade700 : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FaIcon(FontAwesomeIcons.chevronRight, size: 14, color: theme.colorScheme.outline),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getServiceIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('mix')) return FontAwesomeIcons.sliders;
    if (lower.contains('master')) return FontAwesomeIcons.compactDisc;
    if (lower.contains('record') || lower.contains('enregistr')) return FontAwesomeIcons.microphone;
    if (lower.contains('edit')) return FontAwesomeIcons.scissors;
    return FontAwesomeIcons.music;
  }
}
