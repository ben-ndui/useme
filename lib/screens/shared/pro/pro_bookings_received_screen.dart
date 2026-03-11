import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/config/responsive_config.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/session.dart';
import 'package:useme/core/services/booking_acceptance_service.dart';
import 'package:useme/core/services/pro_profile_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/app_loader.dart';
import 'package:useme/widgets/common/payment_tracking_card.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';
import 'package:useme/widgets/pro/accept_pro_booking_sheet.dart';

/// Screen showing booking requests received by a pro.
class ProBookingsReceivedScreen extends StatelessWidget {
  const ProBookingsReceivedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.proBookingsReceived)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth),
          child: BlocConsumer<SessionBloc, SessionState>(
        listenWhen: (prev, curr) =>
            curr is SessionStatusUpdatedState ||
            curr is PaymentStatusUpdatedState,
        listener: (context, state) {
          if (state is SessionStatusUpdatedState) {
            final msg = state.newStatus == SessionStatus.confirmed
                ? l10n.proBookingAccepted
                : l10n.proBookingDeclined;
            AppSnackBar.success(context, msg);
          } else if (state is PaymentStatusUpdatedState) {
            final msg = state.newPaymentStatus == PaymentStatus.depositPaid
                ? l10n.depositReceivedSuccess
                : l10n.fullyPaidSuccess;
            AppSnackBar.success(context, msg);
          }
        },
        builder: (context, state) {
          if (state.isLoading) return const AppLoader();

          final sessions = state.sessions
              .where((s) => s.isProSession)
              .toList()
            ..sort((a, b) => b.scheduledStart.compareTo(a.scheduledStart));

          if (sessions.isEmpty) {
            return _buildEmpty(context, l10n);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _BookingCard(session: sessions[i]),
          );
        },
      ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.calendarXmark,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.proBookingsEmpty,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.proBookingsEmptyDesc,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Session session;

  const _BookingCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMMMd();
    final timeFormat = DateFormat.Hm();
    final artistName = session.artistNames.isNotEmpty
        ? session.artistNames.first
        : 'Artist';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.proBookingFrom(artistName),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _StatusChip(status: session.displayStatus),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(
              theme,
              FontAwesomeIcons.calendarDay,
              dateFormat.format(session.scheduledStart),
            ),
            const SizedBox(height: 6),
            _infoRow(
              theme,
              FontAwesomeIcons.clock,
              '${timeFormat.format(session.scheduledStart)} - '
                  '${timeFormat.format(session.scheduledEnd)} '
                  '(${session.durationMinutes ~/ 60}h)',
            ),
            if (session.notes != null) ...[
              const SizedBox(height: 6),
              _infoRow(
                theme,
                FontAwesomeIcons.noteSticky,
                session.notes!,
              ),
            ],
            if (session.hasPaymentTracking) ...[
              const SizedBox(height: 12),
              PaymentTrackingCard(
                session: session,
                canManage: true,
                onMarkDepositReceived: () =>
                    _updatePayment(context, PaymentStatus.depositPaid),
                onMarkFullyPaid: () =>
                    _updatePayment(context, PaymentStatus.fullyPaid),
              ),
            ],
            if (session.isPending) ...[
              const SizedBox(height: 16),
              _buildActions(context, l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        FaIcon(icon, size: 14, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _decline(context),
            icon: const FaIcon(FontAwesomeIcons.xmark, size: 14),
            label: Text(l10n.proBookingDecline),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _accept(context),
            icon: const FaIcon(FontAwesomeIcons.check, size: 14),
            label: Text(l10n.proBookingAccept),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _updatePayment(BuildContext context, PaymentStatus status) {
    context.read<SessionBloc>().add(UpdatePaymentStatusEvent(
          sessionId: session.id,
          paymentStatus: status,
        ));
  }

  void _decline(BuildContext context) {
    context.read<SessionBloc>().add(UpdateSessionStatusEvent(
          sessionId: session.id,
          status: SessionStatus.cancelled,
        ));
  }

  Future<void> _accept(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;
    final user = authState.user as AppUser;
    final profile = user.proProfile;
    if (profile == null) return;

    final rate = profile.hourlyRate ?? 0;
    final totalAmount = rate * (session.durationMinutes / 60);

    // Si le pro n'a pas de méthode de paiement, accepter directement
    if (profile.enabledPaymentMethods.isEmpty) {
      if (!context.mounted) return;
      context.read<SessionBloc>().add(UpdateSessionStatusEvent(
            sessionId: session.id,
            status: SessionStatus.confirmed,
          ));
      return;
    }

    final result = await AcceptProBookingSheet.show(
      context,
      session: session,
      profile: profile,
      totalAmount: totalAmount,
    );
    if (result == null || !context.mounted) return;

    // Sauvegarder le pourcentage par défaut si demandé
    if (result.saveAsDefault) {
      final depositPercent =
          (result.depositAmount / result.totalAmount * 100).round().toDouble();
      await ProProfileService().updateProProfile(
        userId: user.uid,
        profile: profile.copyWith(defaultDepositPercent: depositPercent),
      );
    }

    // Accepter la booking et envoyer le message de paiement
    final artistId = session.artistIds.isNotEmpty
        ? session.artistIds.first
        : '';
    if (artistId.isEmpty) return;

    final service = BookingAcceptanceService();
    await service.acceptProBooking(
      session: session,
      proUser: user,
      artistId: artistId,
      paymentMethod: result.paymentMethod,
      totalAmount: result.totalAmount,
      depositAmount: result.depositAmount,
      customMessage: result.customMessage,
    );

    if (!context.mounted) return;
    // Recharger les sessions pour refléter le changement
    context.read<SessionBloc>().add(
          LoadProSessionsEvent(proId: user.uid),
        );
    AppSnackBar.success(
      context,
      AppLocalizations.of(context)!.proBookingAccepted,
    );
  }
}

class _StatusChip extends StatelessWidget {
  final SessionStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (label, color) = switch (status) {
      SessionStatus.pending => (l10n.proBookingPending, Colors.orange),
      SessionStatus.confirmed => (l10n.proBookingConfirmed, Colors.green),
      SessionStatus.cancelled => (l10n.proBookingStatusCancelled, Colors.red),
      _ => (status.name, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
