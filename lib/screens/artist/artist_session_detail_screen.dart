import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Session detail screen for artists to view their booked sessions
class ArtistSessionDetailScreen extends StatefulWidget {
  final String sessionId;

  const ArtistSessionDetailScreen({super.key, required this.sessionId});

  @override
  State<ArtistSessionDetailScreen> createState() => _ArtistSessionDetailScreenState();
}

class _ArtistSessionDetailScreenState extends State<ArtistSessionDetailScreen> {
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
        title: Text(l10n.sessionDetails),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: BlocBuilder<SessionBloc, SessionState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final session = state.selectedSession;
          if (session == null) {
            return Center(child: Text(l10n.noSession, style: theme.textTheme.bodyLarge));
          }

          return _ArtistSessionDetailContent(session: session, l10n: l10n);
        },
      ),
    );
  }
}

class _ArtistSessionDetailContent extends StatelessWidget {
  final Session session;
  final AppLocalizations l10n;

  const _ArtistSessionDetailContent({required this.session, required this.l10n});

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
          _StatusBadge(status: session.displayStatus, l10n: l10n),
          const SizedBox(height: 24),
          _InfoCard(
            icon: FontAwesomeIcons.calendar,
            title: l10n.dateAndTime,
            value: '${dateFormat.format(session.scheduledStart)}\n'
                '${timeFormat.format(session.scheduledStart)} - ${timeFormat.format(session.scheduledEnd)}',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: FontAwesomeIcons.clock,
            title: l10n.duration,
            value: '${session.durationMinutes ~/ 60}h${session.durationMinutes % 60 > 0 ? ' ${session.durationMinutes % 60}min' : ''}',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: FontAwesomeIcons.music,
            title: l10n.sessionType,
            value: session.typeLabel,
            theme: theme,
          ),
          const SizedBox(height: 12),
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
          if (session.hasEngineer)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _EngineerCard(session: session, l10n: l10n, theme: theme),
            ),
          if (!session.hasEngineer && session.status == SessionStatus.pending)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PendingEngineerCard(l10n: l10n, theme: theme),
            ),
          if (session.notes != null && session.notes!.isNotEmpty)
            _InfoCard(
              icon: FontAwesomeIcons.noteSticky,
              title: l10n.notesOptional,
              value: session.notes!,
              theme: theme,
            ),
          const SizedBox(height: 32),
          if (session.canBeCancelled)
            _CancelButton(session: session, l10n: l10n),
        ],
      ),
    );
  }
}

class _EngineerCard extends StatelessWidget {
  final Session session;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _EngineerCard({required this.session, required this.l10n, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(FontAwesomeIcons.headphones, size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.engineer, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(session.engineerName ?? '-', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(l10n.confirmed, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.green)),
          ),
        ],
      ),
    );
  }
}

class _PendingEngineerCard extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;

  const _PendingEngineerCard({required this.l10n, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: const FaIcon(FontAwesomeIcons.headphones, size: 18, color: Colors.orange),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.engineer, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(l10n.toBeAssigned, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.orange)),
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
    final (color, label) = _getStatusInfo();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  (Color, String) _getStatusInfo() {
    return switch (status) {
      SessionStatus.pending => (Colors.orange, l10n.pendingStatus),
      SessionStatus.confirmed => (Colors.green, l10n.confirmedStatus),
      SessionStatus.inProgress => (Colors.blue, l10n.inProgressStatus),
      SessionStatus.completed => (Colors.grey, l10n.completedStatus),
      SessionStatus.cancelled => (Colors.red, l10n.cancelledStatus),
      SessionStatus.noShow => (Colors.red, l10n.noShowStatus),
    };
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final ThemeData theme;

  const _InfoCard({required this.icon, required this.title, required this.value, required this.theme});

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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: FaIcon(icon, size: 16, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final Session session;
  final AppLocalizations l10n;

  const _CancelButton({required this.session, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showCancelConfirmation(context),
        icon: const FaIcon(FontAwesomeIcons.xmark, size: 16),
        label: Text(l10n.cancelSession),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelSession),
        content: Text(l10n.confirmCancelSession),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SessionBloc>().add(UpdateSessionStatusEvent(sessionId: session.id, status: SessionStatus.cancelled));
              context.pop();
            },
            child: Text(l10n.confirm, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
