import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Banner shown on artist home feed when sessions have pending payments.
/// Tapping navigates directly to the session detail to pay.
class PendingPaymentBanner extends StatelessWidget {
  final bool isWideLayout;

  const PendingPaymentBanner({super.key, this.isWideLayout = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        final pending = _getPendingPaymentSessions(state.sessions);
        if (pending.isEmpty) return const SizedBox.shrink();

        final padding = isWideLayout ? 24.0 : 16.0;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            children: pending
                .map((s) => _PaymentCard(session: s))
                .toList(),
          ),
        );
      },
    );
  }

  List<Session> _getPendingPaymentSessions(List<Session> sessions) {
    return sessions.where((s) {
      final isStripe =
          s.paymentMethodLabel == PaymentMethodType.stripeInApp.label;
      return isStripe && (s.canPayDeposit || s.canPayRemaining);
    }).toList();
  }
}

class _PaymentCard extends StatelessWidget {
  final Session session;

  const _PaymentCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final isDeposit = session.canPayDeposit;
    final amount = isDeposit
        ? session.depositAmount ?? 0
        : session.remainingAmount;
    final label = isDeposit
        ? l10n.payDepositAmount('${amount.toStringAsFixed(2)} €')
        : l10n.payRemainingAmount('${amount.toStringAsFixed(2)} €');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/artist/sessions/${session.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.15),
                  theme.colorScheme.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.creditCard,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.typeLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                FaIcon(
                  FontAwesomeIcons.arrowRight,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
