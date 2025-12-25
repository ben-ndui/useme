import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/payment_method.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Summary and actions section for accept booking sheet
class BookingSheetSummary extends StatelessWidget {
  final double totalAmount;
  final double depositAmount;
  final PaymentMethod? selectedMethod;
  final List<AppUser> selectedEngineers;
  final bool needsEngineerSelection;
  final bool proposeMode;
  final bool saveAsDefault;
  final bool canSubmit;
  final ValueChanged<bool> onSaveAsDefaultChanged;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const BookingSheetSummary({
    super.key,
    required this.totalAmount,
    required this.depositAmount,
    required this.selectedMethod,
    required this.selectedEngineers,
    required this.needsEngineerSelection,
    required this.proposeMode,
    required this.saveAsDefault,
    required this.canSubmit,
    required this.onSaveAsDefaultChanged,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        _buildSummaryCard(theme, l10n),
        const SizedBox(height: 24),
        _buildActions(theme, l10n),
      ],
    );
  }

  Widget _buildSummaryCard(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildRow(l10n.totalAmount, '${totalAmount.toStringAsFixed(2)} €'),
          const SizedBox(height: 8),
          _buildRow(
            l10n.depositToPay,
            '${depositAmount.toStringAsFixed(2)} €',
            isBold: true,
            valueColor: Colors.green,
            theme: theme,
          ),
          if (selectedMethod != null) ...[
            const SizedBox(height: 8),
            _buildRow(l10n.paymentBy, selectedMethod!.type.label),
          ],
          if (needsEngineerSelection) ...[
            const SizedBox(height: 8),
            _buildEngineerRow(theme, l10n),
          ],
          const SizedBox(height: 12),
          _buildSaveAsDefaultCheckbox(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? valueColor, ThemeData? theme}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: isBold && theme != null ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold) : null),
        Text(
          value,
          style: isBold && theme != null
              ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: valueColor)
              : null,
        ),
      ],
    );
  }

  Widget _buildEngineerRow(ThemeData theme, AppLocalizations l10n) {
    Widget valueWidget;
    if (!proposeMode) {
      valueWidget = Text(l10n.assignLater, style: TextStyle(color: Colors.orange.shade700));
    } else if (selectedEngineers.isEmpty) {
      valueWidget = Text(l10n.selectAtLeastOne, style: TextStyle(color: theme.colorScheme.error));
    } else {
      valueWidget = Text(
        selectedEngineers.length == 1 ? selectedEngineers.first.displayName ?? '' : '${selectedEngineers.length} proposés',
        style: TextStyle(color: theme.colorScheme.primary),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(l10n.soundEngineer), valueWidget],
    );
  }

  Widget _buildSaveAsDefaultCheckbox(ThemeData theme, AppLocalizations l10n) {
    return CheckboxListTile(
      value: saveAsDefault,
      onChanged: (value) => onSaveAsDefaultChanged(value ?? false),
      title: Text(l10n.saveAsDefault, style: theme.textTheme.bodyMedium),
      subtitle: Text(
        l10n.saveAsDefaultDescription,
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
      ),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
    );
  }

  Widget _buildActions(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: canSubmit ? onSubmit : null,
            icon: const FaIcon(FontAwesomeIcons.paperPlane, size: 14),
            label: Text(l10n.acceptAndSendInfo),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onCancel,
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
