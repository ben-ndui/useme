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
import 'package:useme/widgets/common/app_loader.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';
import 'package:useme/widgets/studio/accept_booking_sheet.dart';

/// Session detail screen for studios to view and manage session requests
class SessionDetailScreen extends StatefulWidget {
  final String sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SessionBloc>().add(LoadSessionByIdEvent(sessionId: widget.sessionId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessionRequest),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: BlocConsumer<SessionBloc, SessionState>(
        listener: (context, state) {
          if (state is SessionStatusUpdatedState) {
            final message = state.newStatus == SessionStatus.confirmed
                ? l10n.sessionAccepted
                : state.newStatus == SessionStatus.cancelled
                    ? l10n.sessionDeclined
                    : null;
            if (message != null) {
              AppSnackBar.success(context, message);
              context.pop();
            }
          } else if (state is SessionErrorState) {
            AppSnackBar.error(context, state.errorMessage ?? l10n.errorOccurred);
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const AppLoader();
          }

          final session = state.selectedSession;
          if (session == null) {
            return Center(
              child: Text(l10n.noSession, style: theme.textTheme.bodyLarge),
            );
          }

          return _SessionDetailContent(session: session, l10n: l10n);
        },
      ),
    );
  }
}

class _SessionDetailContent extends StatelessWidget {
  final Session session;
  final AppLocalizations l10n;

  const _SessionDetailContent({required this.session, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat('EEEE d MMMM yyyy', locale);
    final timeFormat = DateFormat('HH:mm', locale);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge (use displayStatus for time-based updates)
          _StatusBadge(status: session.displayStatus, l10n: l10n),
          const SizedBox(height: 24),

          // Artist info
          _InfoCard(
            icon: FontAwesomeIcons.user,
            title: l10n.artist,
            value: session.artistName,
            theme: theme,
          ),
          const SizedBox(height: 12),

          // Date & Time
          _InfoCard(
            icon: FontAwesomeIcons.calendar,
            title: l10n.dateAndTime,
            value: '${dateFormat.format(session.scheduledStart)}\n'
                '${timeFormat.format(session.scheduledStart)} - ${timeFormat.format(session.scheduledEnd)}',
            theme: theme,
          ),
          const SizedBox(height: 12),

          // Duration
          _InfoCard(
            icon: FontAwesomeIcons.clock,
            title: l10n.duration,
            value: '${session.durationMinutes ~/ 60}h${session.durationMinutes % 60 > 0 ? ' ${session.durationMinutes % 60}min' : ''}',
            theme: theme,
          ),
          const SizedBox(height: 12),

          // Session type
          _InfoCard(
            icon: FontAwesomeIcons.music,
            title: l10n.sessionType,
            value: session.typeLabel,
            theme: theme,
          ),
          const SizedBox(height: 12),

          // Room (if assigned)
          if (session.hasRoom)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _InfoCard(
                icon: FontAwesomeIcons.doorOpen,
                title: l10n.rooms,
                value: session.roomName ?? '-',
                theme: theme,
              ),
            ),

          // Engineer (if assigned)
          if (session.hasEngineer)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _InfoCard(
                icon: FontAwesomeIcons.headphones,
                title: l10n.engineer,
                value: session.engineerName ?? '-',
                theme: theme,
              ),
            ),

          // Notes
          if (session.notes != null && session.notes!.isNotEmpty)
            _InfoCard(
              icon: FontAwesomeIcons.noteSticky,
              title: l10n.notesOptional,
              value: session.notes!,
              theme: theme,
            ),

          const SizedBox(height: 32),

          // Action buttons based on status
          _ActionButtons(session: session, l10n: l10n),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final ThemeData theme;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          FaIcon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final SessionStatus status;
  final AppLocalizations l10n;

  const _StatusBadge({required this.status, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      SessionStatus.pending => (Colors.orange, l10n.waitingStatus),
      SessionStatus.confirmed => (Colors.blue, l10n.confirmedStatus),
      SessionStatus.inProgress => (Colors.green, l10n.inProgressStatus),
      SessionStatus.completed => (Colors.grey, l10n.completedStatus),
      SessionStatus.cancelled => (Colors.red, l10n.cancelledStatus),
      SessionStatus.noShow => (Colors.red, l10n.noShowStatus),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Session session;
  final AppLocalizations l10n;

  const _ActionButtons({required this.session, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // For pending sessions: Accept / Decline (only if session is not past)
    if (session.isPending && session.canBeCancelled) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _confirmAccept(context),
              icon: const FaIcon(FontAwesomeIcons.check, size: 16),
              label: Text(l10n.accept),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmDecline(context),
              icon: FaIcon(FontAwesomeIcons.xmark, size: 16, color: theme.colorScheme.error),
              label: Text(l10n.decline, style: TextStyle(color: theme.colorScheme.error)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: theme.colorScheme.error),
              ),
            ),
          ),
        ],
      );
    }

    // For confirmed sessions: Cancel (only if session can be cancelled)
    if (session.isConfirmed && session.canBeCancelled) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _confirmCancel(context),
          icon: FaIcon(FontAwesomeIcons.ban, size: 16, color: theme.colorScheme.error),
          label: Text(l10n.cancelSession, style: TextStyle(color: theme.colorScheme.error)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: theme.colorScheme.error),
          ),
        ),
      );
    }

    // For other statuses, no action buttons
    return const SizedBox.shrink();
  }

  Future<void> _confirmAccept(BuildContext context) async {
    // Calculer le montant total (basé sur la durée - à adapter selon ton modèle)
    // TODO: Récupérer le tarif horaire du service sélectionné
    final totalAmount = session.durationHours * 50.0; // Placeholder 50€/h

    // Afficher le bottom sheet de paiement
    final result = await AcceptBookingSheet.show(
      context,
      session: session,
      totalAmount: totalAmount,
    );

    if (result == null || !context.mounted) return;

    // Utiliser le service pour accepter la réservation
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;

    final studioId = authState.user.uid;

    // Sauvegarder comme défaut si demandé
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
      // Ouvrir la conversation créée
      if (response.data != null) {
        context.push('/conversations/${response.data}');
      } else {
        context.pop();
      }
    } else {
      AppSnackBar.error(context, response.message);
    }
  }

  void _confirmDecline(BuildContext context) {
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
            },
            style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
            child: Text(l10n.decline),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelSession),
        content: Text(l10n.confirmCancelSession),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.back),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SessionBloc>().add(UpdateSessionStatusEvent(
                sessionId: session.id,
                status: SessionStatus.cancelled,
              ));
            },
            style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}
