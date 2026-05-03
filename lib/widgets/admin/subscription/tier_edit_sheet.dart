import 'package:flutter/material.dart';
import 'package:uzme/core/models/subscription_tier_config.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/widgets/admin/subscription/tier_edit_form_sections.dart';

/// Bottom sheet pour editer un tier d'abonnement
class TierEditSheet extends StatefulWidget {
  final SubscriptionTierConfig tier;

  const TierEditSheet({super.key, required this.tier});

  @override
  State<TierEditSheet> createState() => _TierEditSheetState();
}

class _TierEditSheetState extends State<TierEditSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceMonthlyCtrl;
  late final TextEditingController _priceYearlyCtrl;
  late final TextEditingController _sessionsCtrl;
  late final TextEditingController _roomsCtrl;
  late final TextEditingController _servicesCtrl;
  late final TextEditingController _engineersCtrl;
  late final TextEditingController _aiMsgCtrl;
  late final List<TextEditingController> _allControllers;

  late bool _hasAIAssistant, _hasAdvancedAI, _hasDiscoveryVisibility;
  late bool _hasAnalytics, _hasAdvancedAnalytics, _hasMultiStudios;
  late bool _hasApiAccess, _hasPrioritySupport, _hasVerifiedBadge;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final t = widget.tier;
    _nameCtrl = TextEditingController(text: t.name);
    _descCtrl = TextEditingController(text: t.description);
    _priceMonthlyCtrl = TextEditingController(text: t.priceMonthly.toStringAsFixed(0));
    _priceYearlyCtrl = TextEditingController(text: t.priceYearly.toStringAsFixed(0));
    _sessionsCtrl = TextEditingController(text: t.maxSessions.toString());
    _roomsCtrl = TextEditingController(text: t.maxRooms.toString());
    _servicesCtrl = TextEditingController(text: t.maxServices.toString());
    _engineersCtrl = TextEditingController(text: t.maxEngineers.toString());
    _aiMsgCtrl = TextEditingController(text: t.aiMessagesPerMonth.toString());
    _allControllers = [
      _nameCtrl, _descCtrl, _priceMonthlyCtrl, _priceYearlyCtrl,
      _sessionsCtrl, _roomsCtrl, _servicesCtrl, _engineersCtrl, _aiMsgCtrl,
    ];
    _hasAIAssistant = t.hasAIAssistant;
    _hasAdvancedAI = t.hasAdvancedAI;
    _hasDiscoveryVisibility = t.hasDiscoveryVisibility;
    _hasAnalytics = t.hasAnalytics;
    _hasAdvancedAnalytics = t.hasAdvancedAnalytics;
    _hasMultiStudios = t.hasMultiStudios;
    _hasApiAccess = t.hasApiAccess;
    _hasPrioritySupport = t.hasPrioritySupport;
    _hasVerifiedBadge = t.hasVerifiedBadge;
    _isActive = t.isActive;
  }

  @override
  void dispose() {
    for (final c in _allControllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          _buildHandle(theme),
          _buildHeader(theme, l10n),
          const Divider(),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(16),
              children: _buildFormSections(l10n),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) => Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8), width: 40, height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2)));

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          Text(l10n.adminEditTier(widget.tier.name),
              style: theme.textTheme.titleLarge),
          const Spacer(),
          FilledButton(onPressed: _save, child: Text(l10n.save)),
        ]));

  List<Widget> _buildFormSections(AppLocalizations l10n) => [
        buildInfoSection(context,
            nameController: _nameCtrl, descriptionController: _descCtrl),
        const SizedBox(height: 24),
        buildPricingSection(context,
            priceMonthlyController: _priceMonthlyCtrl,
            priceYearlyController: _priceYearlyCtrl),
        const SizedBox(height: 24),
        buildLimitsSection(context,
            maxSessionsController: _sessionsCtrl,
            maxRoomsController: _roomsCtrl,
            maxServicesController: _servicesCtrl,
            maxEngineersController: _engineersCtrl,
            aiMessagesPerMonthController: _aiMsgCtrl),
        const SizedBox(height: 24),
        ..._buildToggleSections(l10n),
        const SizedBox(height: 40),
      ];

  List<Widget> _buildToggleSections(AppLocalizations l10n) => [
        buildToggleSection(context, l10n.adminSectionAiFeatures, [
          FeatureToggle(title: l10n.adminFeatureAiAssistant,
              subtitle: l10n.adminAiAssistantSubtitle, value: _hasAIAssistant,
              onChanged: (v) => setState(() => _hasAIAssistant = v)),
          FeatureToggle(title: l10n.adminFeatureAdvancedAi,
              subtitle: l10n.adminAdvancedAiSubtitle, value: _hasAdvancedAI,
              onChanged: (v) => setState(() => _hasAdvancedAI = v)),
        ]),
        const SizedBox(height: 24),
        buildToggleSection(context, l10n.adminSectionFeatures, [
          FeatureToggle(title: l10n.adminFeatureDiscoveryVisibility,
              subtitle: l10n.adminDiscoverySubtitle,
              value: _hasDiscoveryVisibility,
              onChanged: (v) => setState(() => _hasDiscoveryVisibility = v)),
          FeatureToggle(title: l10n.adminFeatureBasicAnalytics,
              value: _hasAnalytics,
              onChanged: (v) => setState(() => _hasAnalytics = v)),
          FeatureToggle(title: l10n.adminFeatureAdvancedAnalytics,
              value: _hasAdvancedAnalytics,
              onChanged: (v) => setState(() => _hasAdvancedAnalytics = v)),
          FeatureToggle(title: l10n.adminFeatureVerifiedBadge,
              value: _hasVerifiedBadge,
              onChanged: (v) => setState(() => _hasVerifiedBadge = v)),
          FeatureToggle(title: l10n.adminFeatureMultiStudios,
              value: _hasMultiStudios,
              onChanged: (v) => setState(() => _hasMultiStudios = v)),
          FeatureToggle(title: l10n.adminFeatureApiAccess,
              value: _hasApiAccess,
              onChanged: (v) => setState(() => _hasApiAccess = v)),
          FeatureToggle(title: l10n.adminFeaturePrioritySupportFull,
              value: _hasPrioritySupport,
              onChanged: (v) => setState(() => _hasPrioritySupport = v)),
        ]),
        const SizedBox(height: 24),
        buildToggleSection(context, l10n.adminSectionStatus, [
          FeatureToggle(title: l10n.adminTierActive,
              subtitle: l10n.adminTierActiveSubtitle, value: _isActive,
              onChanged: widget.tier.id == 'free'
                  ? null : (v) => setState(() => _isActive = v)),
        ]),
      ];

  void _save() {
    final updated = widget.tier.copyWith(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      priceMonthly: double.tryParse(_priceMonthlyCtrl.text) ?? 0,
      priceYearly: double.tryParse(_priceYearlyCtrl.text) ?? 0,
      maxSessions: int.tryParse(_sessionsCtrl.text) ?? -1,
      maxRooms: int.tryParse(_roomsCtrl.text) ?? -1,
      maxServices: int.tryParse(_servicesCtrl.text) ?? -1,
      maxEngineers: int.tryParse(_engineersCtrl.text) ?? -1,
      aiMessagesPerMonth: int.tryParse(_aiMsgCtrl.text) ?? 50,
      hasAIAssistant: _hasAIAssistant,
      hasAdvancedAI: _hasAdvancedAI,
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
