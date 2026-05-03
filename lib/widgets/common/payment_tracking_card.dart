import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uzme/core/models/session.dart';
import 'package:uzme/l10n/app_localizations.dart';

/// Card showing payment tracking status on a session.
///
/// For pro/studio: shows action buttons to mark payments received.
/// For artist: read-only view of payment progress.
class PaymentTrackingCard extends StatelessWidget {
  final Session session;
  final bool canManage;
  final VoidCallback? onMarkDepositReceived;
  final VoidCallback? onMarkFullyPaid;

  const PaymentTrackingCard({
    super.key,
    required this.session,
    this.canManage = false,
    this.onMarkDepositReceived,
    this.onMarkFullyPaid,
  });

  @override
  Widget build(BuildContext context) {
    if (!session.hasPaymentTracking) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final fmt = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, l10n),
            const SizedBox(height: 12),
            _buildAmounts(theme, l10n, fmt),
            const SizedBox(height: 12),
            _buildStatusSteps(theme, l10n),
            if (canManage) ...[
              const SizedBox(height: 16),
              _buildActions(theme, l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        FaIcon(FontAwesomeIcons.moneyCheck,
            size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Text(
          l10n.paymentTracking,
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        _PaymentStatusBadge(status: session.paymentStatus),
      ],
    );
  }

  Widget _buildAmounts(
      ThemeData theme, AppLocalizations l10n, NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _amountRow(
            l10n.totalAmount,
            fmt.format(session.totalAmount ?? 0),
            theme,
          ),
          const SizedBox(height: 6),
          _amountRow(
            l10n.depositOf(fmt.format(session.depositAmount ?? 0)),
            session.isDepositPaid ? '✅' : '⏳',
            theme,
            highlight: true,
          ),
          if (session.isDepositPaid && !session.isFullyPaid) ...[
            const SizedBox(height: 6),
            _amountRow(
              l10n.remainingToPay(
                  fmt.format(session.remainingAmount)),
              '⏳',
              theme,
            ),
          ],
          if (session.paymentMethodLabel != null) ...[
            const SizedBox(height: 6),
            _amountRow(
              l10n.paymentBy,
              session.paymentMethodLabel!,
              theme,
            ),
          ],
        ],
      ),
    );
  }

  Widget _amountRow(String label, String value, ThemeData theme,
      {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        Text(
          value,
          style: highlight
              ? theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)
              : theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildStatusSteps(ThemeData theme, AppLocalizations l10n) {
    final dateFormat = DateFormat.yMMMd();
    final steps = <Widget>[];

    // Step 1: Deposit
    final depositDone = session.isDepositPaid;
    steps.add(_statusStep(
      theme,
      icon: FontAwesomeIcons.handHoldingDollar,
      label: l10n.paymentStatusDepositPaid,
      done: depositDone,
      subtitle: depositDone && session.depositPaidAt != null
          ? l10n.paidOn(dateFormat.format(session.depositPaidAt!))
          : null,
    ));

    // Step 2: Full payment
    steps.add(_statusStep(
      theme,
      icon: FontAwesomeIcons.circleCheck,
      label: l10n.paymentStatusFullyPaid,
      done: session.isFullyPaid,
      subtitle: session.isFullyPaid && session.fullyPaidAt != null
          ? l10n.paidOn(dateFormat.format(session.fullyPaidAt!))
          : null,
    ));

    return Row(children: steps.expand((w) => [Expanded(child: w)]).toList());
  }

  Widget _statusStep(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required bool done,
    String? subtitle,
  }) {
    final color = done ? Colors.green : theme.colorScheme.outline;
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: done ? 0.15 : 0.08),
          ),
          child: Center(
            child: FaIcon(icon, size: 14, color: color),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
            textAlign: TextAlign.center),
        if (subtitle != null)
          Text(subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
                fontSize: 10,
              ),
              textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildActions(ThemeData theme, AppLocalizations l10n) {
    if (session.isFullyPaid) return const SizedBox.shrink();

    if (!session.isDepositPaid) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onMarkDepositReceived,
          icon: const FaIcon(FontAwesomeIcons.check, size: 14),
          label: Text(l10n.markDepositReceived),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onMarkFullyPaid,
        icon: const FaIcon(FontAwesomeIcons.circleCheck, size: 14),
        label: Text(l10n.markFullyPaid),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _PaymentStatusBadge extends StatelessWidget {
  final PaymentStatus status;

  const _PaymentStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (label, color) = switch (status) {
      PaymentStatus.none => (l10n.paymentStatusNone, Colors.grey),
      PaymentStatus.depositPending =>
        (l10n.paymentStatusDepositPending, Colors.orange),
      PaymentStatus.depositPaid =>
        (l10n.paymentStatusDepositPaid, Colors.blue),
      PaymentStatus.fullyPaid =>
        (l10n.paymentStatusFullyPaid, Colors.green),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
