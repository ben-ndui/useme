import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/payment_method.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Payment method and deposit selection for accept booking sheet
class BookingPaymentSelector extends StatelessWidget {
  final List<PaymentMethod> enabledMethods;
  final PaymentMethod? selectedMethod;
  final double depositPercent;
  final double totalAmount;
  final TextEditingController messageController;
  final ValueChanged<PaymentMethod> onMethodSelected;
  final ValueChanged<double> onDepositChanged;

  const BookingPaymentSelector({
    super.key,
    required this.enabledMethods,
    required this.selectedMethod,
    required this.depositPercent,
    required this.totalAmount,
    required this.messageController,
    required this.onMethodSelected,
    required this.onDepositChanged,
  });

  double get depositAmount => totalAmount * (depositPercent / 100);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPaymentMethodSection(theme, l10n),
        const SizedBox(height: 24),
        _buildDepositSection(theme, l10n),
        const SizedBox(height: 24),
        _buildCustomMessageSection(theme, l10n),
      ],
    );
  }

  Widget _buildPaymentMethodSection(ThemeData theme, AppLocalizations l10n) {
    if (enabledMethods.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            FaIcon(FontAwesomeIcons.triangleExclamation, size: 20, color: theme.colorScheme.error),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                l10n.noPaymentMethodConfigured,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.paymentMode, style: theme.textTheme.titleSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: enabledMethods.map((method) {
            final isSelected = selectedMethod?.type == method.type;
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    _getIconForType(method.type),
                    size: 14,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(method.type.label),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => onMethodSelected(method),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDepositSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.depositRequested, style: theme.textTheme.titleSmall),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: depositPercent,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${depositPercent.toInt()}%',
                onChanged: onDepositChanged,
              ),
            ),
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${depositAmount.toStringAsFixed(0)} €',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Text(
          l10n.ofTotalAmount(depositPercent.toInt()),
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
        ),
      ],
    );
  }

  Widget _buildCustomMessageSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.customMessageOptional, style: theme.textTheme.titleSmall),
        const SizedBox(height: 12),
        TextField(
          controller: messageController,
          decoration: InputDecoration(
            hintText: l10n.customMessageHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  IconData _getIconForType(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.cash:
        return FontAwesomeIcons.moneyBill;
      case PaymentMethodType.bankTransfer:
        return FontAwesomeIcons.buildingColumns;
      case PaymentMethodType.paypal:
        return FontAwesomeIcons.paypal;
      case PaymentMethodType.card:
        return FontAwesomeIcons.creditCard;
      case PaymentMethodType.other:
        return FontAwesomeIcons.ellipsis;
    }
  }
}
