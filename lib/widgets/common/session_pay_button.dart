import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Pay button shown on artist session detail when a deposit or
/// remaining amount can be paid via Stripe.
///
/// Not shown on web (PaymentSheet unsupported) or when no payment is due.
class SessionPayButton extends StatelessWidget {
  final Session session;
  final String userId;

  const SessionPayButton({
    super.key,
    required this.session,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    // PaymentSheet not available on web
    if (kIsWeb) return const SizedBox.shrink();

    final canPay = session.canPayDeposit || session.canPayRemaining;
    if (!canPay) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final isDeposit = session.canPayDeposit;
    final amountEur = isDeposit
        ? session.depositAmount!
        : session.remainingAmount;
    final amountCents = (amountEur * 100).round();
    final label = isDeposit
        ? l10n.payDepositAmount('${amountEur.toStringAsFixed(2)} €')
        : l10n.payRemainingAmount('${amountEur.toStringAsFixed(2)} €');

    return BlocProvider(
      create: (_) => SessionPaymentBloc(),
      child: _PayButtonBody(
        session: session,
        userId: userId,
        label: label,
        amountCents: amountCents,
        isDeposit: isDeposit,
      ),
    );
  }
}

class _PayButtonBody extends StatelessWidget {
  final Session session;
  final String userId;
  final String label;
  final int amountCents;
  final bool isDeposit;

  const _PayButtonBody({
    required this.session,
    required this.userId,
    required this.label,
    required this.amountCents,
    required this.isDeposit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<SessionPaymentBloc, SessionPaymentState>(
      listener: (context, state) {
        if (state is SessionPaymentReadyState) {
          context.read<SessionPaymentBloc>().add(
                PresentPaymentSheetEvent(paymentIntent: state.paymentIntent),
              );
        } else if (state is SessionPaymentSuccessState) {
          AppSnackBar.success(context, l10n.paymentSuccessful);
          // Reload session to get updated payment status from Firestore
          context.read<SessionBloc>().add(
                LoadSessionByIdEvent(sessionId: session.id),
              );
        } else if (state is SessionPaymentFailedState) {
          AppSnackBar.error(context, state.errorMessage);
        } else if (state is SessionPaymentCancelledState) {
          AppSnackBar.info(context, l10n.paymentCancelled);
        }
      },
      child: BlocBuilder<SessionPaymentBloc, SessionPaymentState>(
        builder: (context, state) {
          final isLoading = state is SessionPaymentLoadingState;

          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => _initPayment(context),
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const FaIcon(FontAwesomeIcons.creditCard, size: 16),
                  label: Text(label),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.securePayment,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _initPayment(BuildContext context) {
    context.read<SessionPaymentBloc>().add(
          InitiateSessionPaymentEvent(
            sessionId: session.id,
            studioId: session.studioId,
            userId: userId,
            amountCents: amountCents,
            isDeposit: isDeposit,
          ),
        );
  }
}
