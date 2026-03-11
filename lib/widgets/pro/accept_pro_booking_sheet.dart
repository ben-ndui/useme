import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/payment_method.dart';
import 'package:useme/core/models/pro_profile.dart';
import 'package:useme/core/models/session.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/studio/booking/booking_payment_selector.dart';

/// Résultat de l'acceptation d'une demande pro
class AcceptProBookingResult {
  final PaymentMethod paymentMethod;
  final double depositAmount;
  final double totalAmount;
  final String? customMessage;
  final bool saveAsDefault;

  const AcceptProBookingResult({
    required this.paymentMethod,
    required this.depositAmount,
    required this.totalAmount,
    this.customMessage,
    this.saveAsDefault = false,
  });
}

/// Bottom sheet pour accepter une demande de booking pro.
class AcceptProBookingSheet extends StatefulWidget {
  final Session session;
  final ProProfile profile;
  final double totalAmount;

  const AcceptProBookingSheet({
    super.key,
    required this.session,
    required this.profile,
    required this.totalAmount,
  });

  static Future<AcceptProBookingResult?> show(
    BuildContext context, {
    required Session session,
    required ProProfile profile,
    required double totalAmount,
  }) {
    return showModalBottomSheet<AcceptProBookingResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AcceptProBookingSheet(
        session: session,
        profile: profile,
        totalAmount: totalAmount,
      ),
    );
  }

  @override
  State<AcceptProBookingSheet> createState() => _AcceptProBookingSheetState();
}

class _AcceptProBookingSheetState extends State<AcceptProBookingSheet> {
  PaymentMethod? _selectedMethod;
  double _depositPercent = 30;
  bool _saveAsDefault = false;
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final methods = widget.profile.enabledPaymentMethods;
    _selectedMethod = methods.isNotEmpty ? methods.first : null;
    _depositPercent = widget.profile.defaultDepositPercent ?? 30;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  double get _depositAmount =>
      widget.totalAmount * (_depositPercent / 100);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(theme, l10n),
            const SizedBox(height: 24),
            BookingPaymentSelector(
              enabledMethods: widget.profile.enabledPaymentMethods,
              selectedMethod: _selectedMethod,
              depositPercent: _depositPercent,
              totalAmount: widget.totalAmount,
              messageController: _messageController,
              onMethodSelected: (m) =>
                  setState(() => _selectedMethod = m),
              onDepositChanged: (v) =>
                  setState(() => _depositPercent = v),
            ),
            const SizedBox(height: 24),
            _buildSummary(theme, l10n),
            const SizedBox(height: 24),
            _buildActions(theme, l10n),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    final session = widget.session;
    final artistName = session.artistNames.isNotEmpty
        ? session.artistNames.first
        : 'Artist';

    return Column(
      children: [
        // Drag handle
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.check,
                    size: 20, color: Colors.green),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.acceptBooking,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l10n.choosePaymentMethod,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Session info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              FaIcon(FontAwesomeIcons.calendarCheck,
                  size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.proBookingFrom(artistName),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatSessionDate(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${widget.totalAmount.toStringAsFixed(2)} €',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          _summaryRow(
            l10n.totalAmount,
            '${widget.totalAmount.toStringAsFixed(2)} €',
          ),
          const SizedBox(height: 8),
          _summaryRow(
            l10n.depositToPay,
            '${_depositAmount.toStringAsFixed(2)} €',
            isBold: true,
            valueColor: Colors.green,
            theme: theme,
          ),
          if (_selectedMethod != null) ...[
            const SizedBox(height: 8),
            _summaryRow(
              l10n.paymentBy,
              _selectedMethod!.type.label,
            ),
          ],
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _saveAsDefault,
            onChanged: (v) =>
                setState(() => _saveAsDefault = v ?? false),
            title: Text(l10n.saveAsDefault,
                style: theme.textTheme.bodyMedium),
            subtitle: Text(
              l10n.saveAsDefaultDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isBold = false, Color? valueColor, ThemeData? theme}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold && theme != null
              ? theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)
              : null,
        ),
        Text(
          value,
          style: isBold && theme != null
              ? theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildActions(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _selectedMethod != null ? _submit : null,
            icon:
                const FaIcon(FontAwesomeIcons.paperPlane, size: 14),
            label: Text(l10n.acceptAndSendInfo),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }

  void _submit() {
    if (_selectedMethod == null) return;
    Navigator.pop(
      context,
      AcceptProBookingResult(
        paymentMethod: _selectedMethod!,
        depositAmount: _depositAmount,
        totalAmount: widget.totalAmount,
        customMessage: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
        saveAsDefault: _saveAsDefault,
      ),
    );
  }

  String _formatSessionDate() {
    final d = widget.session.scheduledStart;
    final e = widget.session.scheduledEnd;
    return '${d.day}/${d.month}/${d.year} • '
        '${d.hour}:${d.minute.toString().padLeft(2, '0')} - '
        '${e.hour}:${e.minute.toString().padLeft(2, '0')}';
  }
}
