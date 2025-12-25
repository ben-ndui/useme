import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/core/models/subscription_tier_config.dart';
import 'package:useme/core/services/subscription_config_service.dart';
import 'package:useme/widgets/common/app_loader.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Écran SuperAdmin pour configurer les tiers d'abonnement
class SubscriptionTiersScreen extends StatefulWidget {
  const SubscriptionTiersScreen({super.key});

  @override
  State<SubscriptionTiersScreen> createState() =>
      _SubscriptionTiersScreenState();
}

class _SubscriptionTiersScreenState extends State<SubscriptionTiersScreen> {
  final SubscriptionConfigService _service = SubscriptionConfigService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration Abonnements'),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.creditCard, size: 18),
            tooltip: 'Config Stripe',
            onPressed: () => context.push('/admin/stripe-config'),
          ),
        ],
      ),
      body: StreamBuilder<List<SubscriptionTierConfig>>(
        stream: _service.streamTiers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader();
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.triangleExclamation,
                      size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Erreur: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final tiers = snapshot.data ?? [];

          if (tiers.isEmpty) {
            return _buildInitializeState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tiers.length,
            itemBuilder: (ctx, i) => _TierCard(
              tier: tiers[i],
              onEdit: () => _showEditDialog(tiers[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitializeState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.gears,
              size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text('Aucun tier configuré', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Initialiser avec les valeurs par défaut ?',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _initializeDefaults,
            child: const Text('Initialiser'),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeDefaults() async {
    try {
      for (final tier in SubscriptionTierConfig.defaultTiers) {
        await _service.createTier(tier);
      }
      if (mounted) {
        AppSnackBar.success(context, 'Tiers initialisés avec succès');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Erreur: $e');
      }
    }
  }

  Future<void> _showEditDialog(SubscriptionTierConfig tier) async {
    final result = await showModalBottomSheet<SubscriptionTierConfig>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _TierEditSheet(tier: tier),
    );

    if (result != null) {
      try {
        await _service.updateTier(result);
        if (mounted) {
          AppSnackBar.success(context, '${result.name} mis à jour');
        }
      } catch (e) {
        if (mounted) {
          AppSnackBar.error(context, 'Erreur: $e');
        }
      }
    }
  }
}

/// Card pour afficher un tier
class _TierCard extends StatelessWidget {
  final SubscriptionTierConfig tier;
  final VoidCallback onEdit;

  const _TierCard({required this.tier, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = switch (tier.id) {
      'free' => Colors.grey,
      'pro' => Colors.blue,
      'enterprise' => Colors.purple,
      _ => theme.colorScheme.primary,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tier.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!tier.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Désactivé',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: Colors.red),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    tier.isFree
                        ? 'Gratuit'
                        : '${tier.priceMonthly.toStringAsFixed(0)}€/mois',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              if (tier.description.isNotEmpty)
                Text(
                  tier.description,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              const SizedBox(height: 16),

              // Limites
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _LimitChip(
                    icon: FontAwesomeIcons.calendar,
                    label: tier.isUnlimited(tier.maxSessions)
                        ? 'Sessions ∞'
                        : '${tier.maxSessions} sessions',
                  ),
                  _LimitChip(
                    icon: FontAwesomeIcons.doorOpen,
                    label: tier.isUnlimited(tier.maxRooms)
                        ? 'Salles ∞'
                        : '${tier.maxRooms} salles',
                  ),
                  _LimitChip(
                    icon: FontAwesomeIcons.microphone,
                    label: tier.isUnlimited(tier.maxServices)
                        ? 'Services ∞'
                        : '${tier.maxServices} services',
                  ),
                  _LimitChip(
                    icon: FontAwesomeIcons.userGroup,
                    label: tier.isUnlimited(tier.maxEngineers)
                        ? 'Engineers ∞'
                        : '${tier.maxEngineers} engineers',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Features
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (tier.hasDiscoveryVisibility)
                    _FeatureChip(
                        icon: FontAwesomeIcons.eye, label: 'Discovery'),
                  if (tier.hasAnalytics)
                    _FeatureChip(
                        icon: FontAwesomeIcons.chartLine, label: 'Analytics'),
                  if (tier.hasVerifiedBadge)
                    _FeatureChip(
                        icon: FontAwesomeIcons.circleCheck, label: 'Badge'),
                  if (tier.hasMultiStudios)
                    _FeatureChip(
                        icon: FontAwesomeIcons.building, label: 'Multi-studios'),
                  if (tier.hasApiAccess)
                    _FeatureChip(icon: FontAwesomeIcons.code, label: 'API'),
                  if (tier.hasPrioritySupport)
                    _FeatureChip(
                        icon: FontAwesomeIcons.headset, label: 'Support+'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LimitChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _LimitChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 12, color: theme.colorScheme.outline),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 12, color: Colors.green),
          const SizedBox(width: 6),
          Text(label,
              style:
                  theme.textTheme.labelSmall?.copyWith(color: Colors.green)),
        ],
      ),
    );
  }
}

/// Bottom sheet pour éditer un tier
class _TierEditSheet extends StatefulWidget {
  final SubscriptionTierConfig tier;

  const _TierEditSheet({required this.tier});

  @override
  State<_TierEditSheet> createState() => _TierEditSheetState();
}

class _TierEditSheetState extends State<_TierEditSheet> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceMonthlyController;
  late TextEditingController _priceYearlyController;
  late TextEditingController _maxSessionsController;
  late TextEditingController _maxRoomsController;
  late TextEditingController _maxServicesController;
  late TextEditingController _maxEngineersController;

  late bool _hasDiscoveryVisibility;
  late bool _hasAnalytics;
  late bool _hasAdvancedAnalytics;
  late bool _hasMultiStudios;
  late bool _hasApiAccess;
  late bool _hasPrioritySupport;
  late bool _hasVerifiedBadge;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tier.name);
    _descriptionController =
        TextEditingController(text: widget.tier.description);
    _priceMonthlyController =
        TextEditingController(text: widget.tier.priceMonthly.toStringAsFixed(0));
    _priceYearlyController =
        TextEditingController(text: widget.tier.priceYearly.toStringAsFixed(0));
    _maxSessionsController =
        TextEditingController(text: widget.tier.maxSessions.toString());
    _maxRoomsController =
        TextEditingController(text: widget.tier.maxRooms.toString());
    _maxServicesController =
        TextEditingController(text: widget.tier.maxServices.toString());
    _maxEngineersController =
        TextEditingController(text: widget.tier.maxEngineers.toString());

    _hasDiscoveryVisibility = widget.tier.hasDiscoveryVisibility;
    _hasAnalytics = widget.tier.hasAnalytics;
    _hasAdvancedAnalytics = widget.tier.hasAdvancedAnalytics;
    _hasMultiStudios = widget.tier.hasMultiStudios;
    _hasApiAccess = widget.tier.hasApiAccess;
    _hasPrioritySupport = widget.tier.hasPrioritySupport;
    _hasVerifiedBadge = widget.tier.hasVerifiedBadge;
    _isActive = widget.tier.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceMonthlyController.dispose();
    _priceYearlyController.dispose();
    _maxSessionsController.dispose();
    _maxRoomsController.dispose();
    _maxServicesController.dispose();
    _maxEngineersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('Modifier ${widget.tier.name}',
                    style: theme.textTheme.titleLarge),
                const Spacer(),
                FilledButton(onPressed: _save, child: const Text('Enregistrer')),
              ],
            ),
          ),
          const Divider(),

          // Form
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Basic info
                _buildSection('Informations', [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nom'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                ]),
                const SizedBox(height: 24),

                // Pricing
                _buildSection('Tarification', [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _priceMonthlyController,
                          decoration:
                              const InputDecoration(labelText: 'Prix mensuel €'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _priceYearlyController,
                          decoration:
                              const InputDecoration(labelText: 'Prix annuel €'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 24),

                // Limits
                _buildSection('Limites (-1 = illimité)', [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _maxSessionsController,
                          decoration:
                              const InputDecoration(labelText: 'Sessions/mois'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _maxRoomsController,
                          decoration: const InputDecoration(labelText: 'Salles'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _maxServicesController,
                          decoration:
                              const InputDecoration(labelText: 'Services'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _maxEngineersController,
                          decoration:
                              const InputDecoration(labelText: 'Engineers'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 24),

                // Features
                _buildSection('Fonctionnalités', [
                  SwitchListTile(
                    title: const Text('Visibilité Discovery'),
                    subtitle: const Text('Visible par les artistes'),
                    value: _hasDiscoveryVisibility,
                    onChanged: (v) =>
                        setState(() => _hasDiscoveryVisibility = v),
                  ),
                  SwitchListTile(
                    title: const Text('Analytics basiques'),
                    value: _hasAnalytics,
                    onChanged: (v) => setState(() => _hasAnalytics = v),
                  ),
                  SwitchListTile(
                    title: const Text('Analytics avancés'),
                    value: _hasAdvancedAnalytics,
                    onChanged: (v) => setState(() => _hasAdvancedAnalytics = v),
                  ),
                  SwitchListTile(
                    title: const Text('Badge vérifié'),
                    value: _hasVerifiedBadge,
                    onChanged: (v) => setState(() => _hasVerifiedBadge = v),
                  ),
                  SwitchListTile(
                    title: const Text('Multi-studios'),
                    value: _hasMultiStudios,
                    onChanged: (v) => setState(() => _hasMultiStudios = v),
                  ),
                  SwitchListTile(
                    title: const Text('Accès API'),
                    value: _hasApiAccess,
                    onChanged: (v) => setState(() => _hasApiAccess = v),
                  ),
                  SwitchListTile(
                    title: const Text('Support prioritaire'),
                    value: _hasPrioritySupport,
                    onChanged: (v) => setState(() => _hasPrioritySupport = v),
                  ),
                ]),
                const SizedBox(height: 24),

                // Status
                _buildSection('Statut', [
                  SwitchListTile(
                    title: const Text('Tier actif'),
                    subtitle:
                        const Text('Les studios peuvent souscrire à ce tier'),
                    value: _isActive,
                    onChanged: widget.tier.id == 'free'
                        ? null
                        : (v) => setState(() => _isActive = v),
                  ),
                ]),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: theme.textTheme.titleSmall
                ?.copyWith(color: theme.colorScheme.primary)),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  void _save() {
    final updated = widget.tier.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      priceMonthly: double.tryParse(_priceMonthlyController.text) ?? 0,
      priceYearly: double.tryParse(_priceYearlyController.text) ?? 0,
      maxSessions: int.tryParse(_maxSessionsController.text) ?? -1,
      maxRooms: int.tryParse(_maxRoomsController.text) ?? -1,
      maxServices: int.tryParse(_maxServicesController.text) ?? -1,
      maxEngineers: int.tryParse(_maxEngineersController.text) ?? -1,
      hasDiscoveryVisibility: _hasDiscoveryVisibility,
      hasAnalytics: _hasAnalytics,
      hasAdvancedAnalytics: _hasAdvancedAnalytics,
      hasMultiStudios: _hasMultiStudios,
      hasApiAccess: _hasApiAccess,
      hasPrioritySupport: _hasPrioritySupport,
      hasVerifiedBadge: _hasVerifiedBadge,
      isActive: _isActive,
    );

    Navigator.pop(context, updated);
  }
}
