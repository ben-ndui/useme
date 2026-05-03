import 'package:flutter/material.dart';
import 'package:uzme/l10n/app_localizations.dart';

/// Reusable section header for tier edit form
Widget buildFormSection(BuildContext context, String title, List<Widget> children) {
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

/// Information section (name + description)
Widget buildInfoSection(
  BuildContext context, {
  required TextEditingController nameController,
  required TextEditingController descriptionController,
}) {
  final l10n = AppLocalizations.of(context)!;
  return buildFormSection(context, l10n.adminSectionInformation, [
    TextField(
      controller: nameController,
      decoration: InputDecoration(labelText: l10n.adminLabelName),
    ),
    const SizedBox(height: 12),
    TextField(
      controller: descriptionController,
      decoration: InputDecoration(labelText: l10n.adminLabelDescription),
      maxLines: 2,
    ),
  ]);
}

/// Pricing section (monthly + yearly)
Widget buildPricingSection(
  BuildContext context, {
  required TextEditingController priceMonthlyController,
  required TextEditingController priceYearlyController,
}) {
  final l10n = AppLocalizations.of(context)!;
  return buildFormSection(context, l10n.adminSectionPricing, [
    Row(
      children: [
        Expanded(
          child: TextField(
            controller: priceMonthlyController,
            decoration:
                InputDecoration(labelText: l10n.adminLabelMonthlyPrice),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: priceYearlyController,
            decoration:
                InputDecoration(labelText: l10n.adminLabelYearlyPrice),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    ),
  ]);
}

/// Limits section (sessions, rooms, services, engineers, AI messages)
Widget buildLimitsSection(
  BuildContext context, {
  required TextEditingController maxSessionsController,
  required TextEditingController maxRoomsController,
  required TextEditingController maxServicesController,
  required TextEditingController maxEngineersController,
  required TextEditingController aiMessagesPerMonthController,
}) {
  final l10n = AppLocalizations.of(context)!;
  return buildFormSection(context, l10n.adminSectionLimits, [
    Row(
      children: [
        Expanded(
          child: TextField(
            controller: maxSessionsController,
            decoration:
                InputDecoration(labelText: l10n.adminLabelSessionsPerMonth),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: maxRoomsController,
            decoration: InputDecoration(labelText: l10n.adminLabelRooms),
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
            controller: maxServicesController,
            decoration: InputDecoration(labelText: l10n.adminLabelServices),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: maxEngineersController,
            decoration: InputDecoration(labelText: l10n.adminLabelEngineers),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    ),
    const SizedBox(height: 12),
    TextField(
      controller: aiMessagesPerMonthController,
      decoration:
          InputDecoration(labelText: l10n.adminLabelAiMessagesPerMonth),
      keyboardType: TextInputType.number,
    ),
  ]);
}

/// Feature toggle data for building switch list tiles
class FeatureToggle {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const FeatureToggle({
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
  });
}

/// Builds a section with SwitchListTile items
Widget buildToggleSection(
  BuildContext context,
  String title,
  List<FeatureToggle> toggles,
) {
  return buildFormSection(
    context,
    title,
    toggles
        .map((t) => SwitchListTile(
              title: Text(t.title),
              subtitle: t.subtitle != null ? Text(t.subtitle!) : null,
              value: t.value,
              onChanged: t.onChanged,
            ))
        .toList(),
  );
}
