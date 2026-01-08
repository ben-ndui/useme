import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/glass/glass_exports.dart';
import 'package:useme/widgets/common/session/session_exports.dart';

/// Section displaying recent/past sessions
class RecentActivitySection extends StatelessWidget {
  final bool isWideLayout;

  const RecentActivitySection({super.key, this.isWideLayout = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final padding = isWideLayout ? 24.0 : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassSectionHeader(
            title: l10n.recentActivity,
            icon: FontAwesomeIcons.clockRotateLeft,
          ),
          const SizedBox(height: 16),
          BlocBuilder<SessionBloc, SessionState>(
            builder: (context, state) {
              final past = _getPastSessions(state.sessions);
              if (past.isEmpty) {
                return GlassEmptyState(
                  icon: FontAwesomeIcons.music,
                  title: l10n.noHistory,
                  subtitle: l10n.completedSessionsHere,
                );
              }

              return Column(
                children: past.take(2).map((session) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ModernSessionCard(session: session, isPast: true),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Session> _getPastSessions(List<Session> sessions) {
    final now = DateTime.now();
    return sessions.where((s) {
      return s.scheduledStart.isBefore(now) || s.status == SessionStatus.completed;
    }).toList()
      ..sort((a, b) => b.scheduledStart.compareTo(a.scheduledStart));
  }
}
