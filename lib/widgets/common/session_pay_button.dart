import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uzme/core/blocs/blocs_exports.dart';
import 'package:uzme/core/models/models_exports.dart';
import 'package:uzme/core/services/session_payment_service.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/widgets/common/snackbar/app_snackbar.dart';

/// Pay buttons shown on artist session detail when payment is due.
///
/// When deposit is pending: shows "Pay deposit" + "Pay full amount".
/// When deposit is paid: shows "Pay remaining".
/// Not shown on web or when studio didn't choose stripeInApp.
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
    if (kIsWeb) return const SizedBox.shrink();

    if (session.paymentMethodLabel != PaymentMethodType.stripeInApp.label) {
      return const SizedBox.shrink();
    }

    final canPay = session.canPayDeposit || session.canPayRemaining;
    if (!canPay) return const SizedBox.shrink();

    return BlocProvider(
      create: (_) => SessionPaymentBloc(),
      child: _PayButtonBody(session: session, userId: userId),
    );
  }
}

class _PayButtonBody extends StatelessWidget {
  final Session session;
  final String userId;

  const _PayButtonBody({required this.session, required this.userId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocListener<SessionPaymentBloc, SessionPaymentState>(
      listener: (context, state) {
        if (state is SessionPaymentReadyState) {
          context.read<SessionPaymentBloc>().add(
                PresentPaymentSheetEvent(paymentIntent: state.paymentIntent),
              );
        } else if (state is SessionPaymentSuccessState) {
          AppSnackBar.success(context, l10n.paymentSuccessful);
          SessionPaymentService().confirmPayment(
            sessionId: state.sessionId,
            paymentIntentId: state.paymentIntentId,
            isDeposit: state.isDeposit,
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
              if (session.canPayDeposit) ...[
                // Primary: pay deposit
                _PayAction(
                  label: l10n.payDepositAmount(
                    '${session.depositAmount!.toStringAsFixed(2)} €',
                  ),
                  isLoading: isLoading,
                  isPrimary: true,
                  onPressed: () => _pay(
                    context,
                    amountCents: (session.depositAmount! * 100).round(),
                    isDeposit: true,
                  ),
                ),
                const SizedBox(height: 10),
                // Secondary: pay full amount
                _PayAction(
                  label: l10n.payRemainingAmount(
                    '${session.totalAmount!.toStringAsFixed(2)} €',
                  ),
                  isLoading: isLoading,
                  isPrimary: false,
                  onPressed: () => _pay(
                    context,
                    amountCents: (session.totalAmount! * 100).round(),
                    isDeposit: false,
                  ),
                ),
              ] else if (session.canPayRemaining) ...[
                // Pay remaining balance
                _PayAction(
                  label: l10n.payRemainingAmount(
                    '${session.remainingAmount.toStringAsFixed(2)} €',
                  ),
                  isLoading: isLoading,
                  isPrimary: true,
                  onPressed: () => _pay(
                    context,
                    amountCents: (session.remainingAmount * 100).round(),
                    isDeposit: false,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                l10n.securePayment,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _pay(
    BuildContext context, {
    required int amountCents,
    required bool isDeposit,
  }) {
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

class _PayAction extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _PayAction({
    required this.label,
    required this.isLoading,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: isLoading ? null : onPressed,
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
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: const FaIcon(FontAwesomeIcons.creditCard, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
