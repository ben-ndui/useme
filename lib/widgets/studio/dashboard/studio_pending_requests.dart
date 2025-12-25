import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/core/services/booking_acceptance_service.dart';
import 'package:useme/core/services/payment_config_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/dashboard/dashboard_exports.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';
import 'package:useme/widgets/studio/accept_booking_sheet.dart';

/// Pending requests section for studio dashboard
class StudioPendingRequests extends StatelessWidget {
  final AppLocalizations l10n;
  final String locale;

  const StudioPendingRequests({super.key, required this.l10n, required this.locale});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        final pending = state.sessions
            .where((s) => s.status == SessionStatus.pending)
            .toList();

        if (pending.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardSectionTitle(title: l10n.pendingRequests, count: pending.length),
            const SizedBox(height: 12),
            ...pending.take(3).map((session) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PendingCard(session: session, locale: locale),
              );
            }),
          ],
        );
      },
    );
  }
}

class _PendingCard extends StatelessWidget {
  final Session session;
  final String locale;

  const _PendingCard({required this.session, required this.locale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('EEE d MMM', locale);

    return Material(
      color: Colors.orange.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.push('/sessions/${session.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: FaIcon(FontAwesomeIcons.clock, size: 18, color: Colors.orange),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.artistName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${session.typeLabel} • ${dateFormat.format(session.scheduledStart)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DashboardActionButton(
                    icon: FontAwesomeIcons.xmark,
                    color: Colors.red,
                    onTap: () => _confirmDecline(context, l10n),
                  ),
                  const SizedBox(width: 8),
                  DashboardActionButton(
                    icon: FontAwesomeIcons.check,
                    color: Colors.green,
                    onTap: () => _confirmAccept(context, l10n),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAccept(BuildContext context, AppLocalizations l10n) async {
    final totalAmount = session.durationHours * 50.0;

    final result = await AcceptBookingSheet.show(
      context,
      session: session,
      totalAmount: totalAmount,
    );

    if (result == null || !context.mounted) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;

    final studioId = authState.user.uid;

    if (result.saveAsDefault) {
      final paymentService = PaymentConfigService();
      final depositPercent = (result.depositAmount / result.totalAmount) * 100;
      await paymentService.updateDefaultPaymentMethod(
        studioId: studioId,
        type: result.paymentMethod.type,
        depositPercent: depositPercent,
      );
    }

    final acceptanceService = BookingAcceptanceService();
    final response = await acceptanceService.acceptBooking(
      session: session,
      studio: authState.user as AppUser,
      artistId: session.artistId,
      paymentMethod: result.paymentMethod,
      totalAmount: result.totalAmount,
      depositAmount: result.depositAmount,
      customMessage: result.customMessage,
      selectedEngineers: result.selectedEngineers,
      proposeToEngineers: result.proposeToEngineers,
    );

    if (!context.mounted) return;

    if (response.isSuccess) {
      AppSnackBar.success(context, l10n.sessionAccepted);
      if (response.data != null) {
        context.push('/conversations/${response.data}');
      }
    } else {
      AppSnackBar.error(context, response.message);
    }
  }

  void _confirmDecline(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.declineSession),
        content: Text(l10n.confirmDeclineSession),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SessionBloc>().add(UpdateSessionStatusEvent(
                sessionId: session.id,
                status: SessionStatus.cancelled,
              ));
              AppSnackBar.info(context, l10n.sessionDeclined);
            },
            style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
            child: Text(l10n.decline),
          ),
        ],
      ),
    );
  }
}
