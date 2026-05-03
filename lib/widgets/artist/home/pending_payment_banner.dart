import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:uzme/core/blocs/blocs_exports.dart';
import 'package:uzme/core/models/models_exports.dart';
import 'package:uzme/l10n/app_localizations.dart';

/// Banner shown on artist home feed when sessions have pending payments.
/// Tapping navigates directly to the session detail to pay.
class PendingPaymentBanner extends StatelessWidget {
  final bool isWideLayout;

  const PendingPaymentBanner({super.key, this.isWideLayout = false});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const SizedBox.shrink();

    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        final pending = _getPendingPaymentSessions(state.sessions);
        if (pending.isEmpty) return const SizedBox.shrink();

        final padding = isWideLayout ? 24.0 : 16.0;
        return Padding(
          padding: EdgeInsets.fromLTRB(padding, 0, padding, 12),
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
    const accent = Colors.amber;

    final isDeposit = session.canPayDeposit;
    final amount = isDeposit
        ? session.depositAmount ?? 0
        : session.remainingAmount;
    final label = isDeposit
        ? l10n.payDepositAmount('${amount.toStringAsFixed(2)} €')
        : l10n.payRemainingAmount('${amount.toStringAsFixed(2)} €');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            Widget card = Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/artist/sessions/${session.id}'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent.withValues(alpha: isDark ? 0.18 : 0.12),
                        accent.withValues(alpha: isDark ? 0.06 : 0.04),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: FaIcon(FontAwesomeIcons.creditCard, size: 16, color: accent),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.typeLabel,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              label,
                              style: const TextStyle(fontSize: 12, color: accent, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const FaIcon(FontAwesomeIcons.arrowRight, size: 13, color: accent),
                    ],
                  ),
                ),
              ),
            );
            return isDark
                ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: card,
                  )
                : card;
          },
        ),
      ),
    );
  }
}
