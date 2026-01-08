import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/artist/studio_selector_bottom_sheet.dart';
import 'package:useme/widgets/common/glass/glass_exports.dart';
import 'package:useme/widgets/common/session/session_exports.dart';

/// Section displaying upcoming sessions
class UpcomingSessionsSection extends StatelessWidget {
  final bool isWideLayout;

  const UpcomingSessionsSection({super.key, this.isWideLayout = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final padding = isWideLayout ? 24.0 : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GlassSectionHeader(
                  title: l10n.upcomingSessions,
                  icon: FontAwesomeIcons.calendarDays,
                ),
              ),
              GlassChip(
                label: l10n.viewAll,
                onTap: () => context.push('/artist/sessions'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<SessionBloc, SessionState>(
            builder: (context, state) {
              if (state.isLoading) {
                return _buildShimmerList(3);
              }

              final upcoming = _getUpcomingSessions(state.sessions);
              if (upcoming.isEmpty) {
                return GlassEmptyState(
                  icon: FontAwesomeIcons.calendarXmark,
                  title: l10n.noUpcomingSessions,
                  subtitle: l10n.bookNextSession,
                  actionLabel: l10n.book,
                  onAction: () => StudioSelectorBottomSheet.showAndNavigate(context),
                );
              }

              return Column(
                children: upcoming.take(3).map((session) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ModernSessionCard(session: session),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Session> _getUpcomingSessions(List<Session> sessions) {
    final now = DateTime.now();
    return sessions.where((s) {
      return s.scheduledStart.isAfter(now) &&
          s.status != SessionStatus.completed &&
          s.status != SessionStatus.cancelled;
    }).toList()
      ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));
  }

  Widget _buildShimmerList(int count) {
    return Column(
      children: List.generate(count, (index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: SessionShimmerCard(),
        );
      }),
    );
  }
}
