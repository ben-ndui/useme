import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/payment_method.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Form widget for managing pro payment methods.
class ProPaymentMethodsForm extends StatelessWidget {
  final List<PaymentMethod> methods;
  final ValueChanged<List<PaymentMethod>> onChanged;
  final double depositPercent;
  final ValueChanged<double>? onDepositChanged;

  const ProPaymentMethodsForm({
    super.key,
    required this.methods,
    required this.onChanged,
    this.depositPercent = 30,
    this.onDepositChanged,
  });

  static const _availableTypes = [
    PaymentMethodType.bankTransfer,
    PaymentMethodType.paypal,
    PaymentMethodType.cash,
    PaymentMethodType.card,
    PaymentMethodType.other,
  ];

  PaymentMethod? _getMethod(PaymentMethodType type) {
    try {
      return methods.firstWhere((m) => m.type == type);
    } catch (_) {
      return null;
    }
  }

  void _toggleMethod(PaymentMethodType type, bool enabled) {
    final existing = _getMethod(type);
    if (enabled && existing == null) {
      onChanged([...methods, PaymentMethod(type: type, isEnabled: true)]);
    } else if (!enabled && existing != null) {
      onChanged(methods.where((m) => m.type != type).toList());
    }
  }

  void _updateMethod(PaymentMethodType type, PaymentMethod updated) {
    onChanged(methods.map((m) => m.type == type ? updated : m).toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FaIcon(FontAwesomeIcons.wallet, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              l10n.proPaymentMethods,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.proPaymentMethodsDesc,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        ..._availableTypes.map((type) => _buildMethodTile(theme, l10n, type)),
        if (methods.any((m) => m.isEnabled)) ...[
          const SizedBox(height: 24),
          _buildDepositSection(theme, l10n),
        ],
      ],
    );
  }

  Widget _buildDepositSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.defaultDeposit, style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          l10n.depositPercentDescription,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: depositPercent,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${depositPercent.toInt()}%',
                onChanged: onDepositChanged != null
                    ? (v) => onDepositChanged!(v)
                    : null,
              ),
            ),
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${depositPercent.toInt()}%',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodTile(ThemeData theme, AppLocalizations l10n, PaymentMethodType type) {
    final method = _getMethod(type);
    final isEnabled = method != null;

    return Column(
      children: [
        SwitchListTile.adaptive(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          secondary: FaIcon(_iconForType(type), size: 16),
          title: Text(type.label, style: const TextStyle(fontSize: 14)),
          value: isEnabled,
          onChanged: (v) => _toggleMethod(type, v),
        ),
        if (isEnabled) _buildDetailsField(theme, l10n, type, method),
      ],
    );
  }

  Widget _buildDetailsField(
      ThemeData theme, AppLocalizations l10n, PaymentMethodType type, PaymentMethod method) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          if (type == PaymentMethodType.bankTransfer) ...[
            _field(l10n.iban, method.details, (v) =>
                _updateMethod(type, method.copyWith(details: v))),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _field('BIC', method.bic, (v) =>
                    _updateMethod(type, method.copyWith(bic: v)))),
                const SizedBox(width: 8),
                Expanded(child: _field(l10n.accountHolder, method.accountHolder, (v) =>
                    _updateMethod(type, method.copyWith(accountHolder: v)))),
              ],
            ),
          ] else if (type == PaymentMethodType.paypal)
            _field(l10n.paypalEmail, method.details, (v) =>
                _updateMethod(type, method.copyWith(details: v)))
          else if (type == PaymentMethodType.other) ...[
            _field(l10n.paymentMethodName, method.details, (v) =>
                _updateMethod(type, method.copyWith(details: v))),
            const SizedBox(height: 8),
            _field(l10n.paymentInstructions, method.instructions, (v) =>
                _updateMethod(type, method.copyWith(instructions: v))),
          ] else if (type == PaymentMethodType.card)
            _field(l10n.paymentInstructions, method.instructions, (v) =>
                _updateMethod(type, method.copyWith(instructions: v))),
        ],
      ),
    );
  }

  Widget _field(String label, String? value, ValueChanged<String> onChanged) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onChanged: onChanged,
    );
  }

  IconData _iconForType(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.bankTransfer:
        return FontAwesomeIcons.buildingColumns;
      case PaymentMethodType.paypal:
        return FontAwesomeIcons.paypal;
      case PaymentMethodType.cash:
        return FontAwesomeIcons.moneyBill;
      case PaymentMethodType.card:
        return FontAwesomeIcons.creditCard;
      case PaymentMethodType.stripeInApp:
        return FontAwesomeIcons.stripe;
      case PaymentMethodType.other:
        return FontAwesomeIcons.ellipsis;
    }
  }
}
