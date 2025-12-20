import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';

/// Engineer dashboard - Clean dashboard with today's sessions
class EngineerDashboardPage extends StatelessWidget {
  const EngineerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticatedState) {
            context.read<SessionBloc>().add(
              LoadEngineerSessionsEvent(engineerId: authState.user.uid),
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            _buildSliverHeader(context),
            SliverToBoxAdapter(child: _buildStatsRow(context)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: _buildSectionTitle(context, 'Sessions du jour'),
              ),
            ),
            _buildSessionsList(context),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.now());

    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: FaIcon(FontAwesomeIcons.bell, size: 18, color: colorScheme.onSurfaceVariant),
            onPressed: () => context.push('/notifications'),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer,
                colorScheme.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  String userName = 'Ingénieur';
                  String? photoURL;
                  if (authState is AuthAuthenticatedState) {
                    final user = authState.user as AppUser;
                    userName = user.displayName ?? user.name ?? 'Ingénieur';
                    photoURL = user.photoURL;
                  }

                  return Row(
                    children: [
                      // Avatar
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [colorScheme.primary, colorScheme.tertiary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: photoURL != null && photoURL.isNotEmpty
                            ? ClipOval(child: Image.network(photoURL, fit: BoxFit.cover))
                            : Center(
                                child: FaIcon(FontAwesomeIcons.headphones, color: Colors.white, size: 22),
                              ),
                      ),
                      const SizedBox(width: 16),
                      // Greeting
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getGreeting(),
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userName,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                FaIcon(FontAwesomeIcons.calendar, size: 12, color: colorScheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  today,
                                  style: TextStyle(fontSize: 13, color: colorScheme.primary, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour 👋';
    if (hour < 18) return 'Bon après-midi 👋';
    return 'Bonsoir 👋';
  }

  Widget _buildStatsRow(BuildContext context) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        final todayCount = _getTodaySessions(state.sessions).length;
        final upcomingCount = _getUpcomingSessions(state.sessions).length;
        final inProgressCount = state.sessions.where((s) => s.status == SessionStatus.inProgress).length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(child: _StatCard(label: 'Aujourd\'hui', value: '$todayCount', icon: FontAwesomeIcons.calendarDay, color: Colors.blue)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(label: 'À venir', value: '$upcomingCount', icon: FontAwesomeIcons.calendarWeek, color: Colors.orange)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(label: 'En cours', value: '$inProgressCount', icon: FontAwesomeIcons.play, color: Colors.green)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
        BlocBuilder<SessionBloc, SessionState>(
          builder: (context, state) {
            final count = _getTodaySessions(state.sessions).length;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.primary)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSessionsList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const SliverToBoxAdapter(
            child: Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
          );
        }

        final todaySessions = _getTodaySessions(state.sessions);
        final upcomingSessions = _getUpcomingSessions(state.sessions).take(3).toList();

        if (todaySessions.isEmpty && upcomingSessions.isEmpty) {
          return SliverToBoxAdapter(child: _buildEmptyState(colorScheme));
        }

        final allItems = <_SessionItem>[];

        // Today's sessions
        for (final s in todaySessions) {
          allItems.add(_SessionItem(session: s, showDate: false));
        }

        // If no today sessions, show message
        if (todaySessions.isEmpty) {
          allItems.add(_SessionItem(session: null, showDate: false, isNoSessionCard: true));
        }

        // Upcoming sessions header + items
        if (upcomingSessions.isNotEmpty) {
          allItems.add(_SessionItem(session: null, showDate: false, isHeader: true, headerTitle: 'À venir', headerCount: upcomingSessions.length));
          for (final s in upcomingSessions) {
            allItems.add(_SessionItem(session: s, showDate: true));
          }
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = allItems[index];

                if (item.isHeader) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 12),
                    child: _buildUpcomingHeader(colorScheme, item.headerTitle!, item.headerCount!),
                  );
                }

                if (item.isNoSessionCard) {
                  return _buildNoSessionsToday(colorScheme);
                }

                return _EngineerSessionTile(session: item.session!, showDate: item.showDate);
              },
              childCount: allItems.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingHeader(ColorScheme colorScheme, String title, int count) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.orange)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                child: Text('$count', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.orange)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoSessionsToday(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: BoxShape.circle),
            child: FaIcon(FontAwesomeIcons.mugHot, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pas de session aujourd\'hui', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                const SizedBox(height: 2),
                Text('Profitez de votre journée !', style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: BoxShape.circle),
            child: FaIcon(FontAwesomeIcons.calendarXmark, size: 36, color: colorScheme.primary),
          ),
          const SizedBox(height: 20),
          Text('Aucune session prévue', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
          const SizedBox(height: 6),
          Text('Vous n\'avez pas de sessions assignées', style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  List<Session> _getTodaySessions(List<Session> sessions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return sessions.where((s) {
      final start = s.scheduledStart;
      return start.isAfter(today.subtract(const Duration(seconds: 1))) && start.isBefore(tomorrow);
    }).toList()..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));
  }

  List<Session> _getUpcomingSessions(List<Session> sessions) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

    return sessions.where((s) => s.scheduledStart.isAfter(tomorrow)).toList()
      ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));
  }
}

class _SessionItem {
  final Session? session;
  final bool showDate;
  final bool isHeader;
  final bool isNoSessionCard;
  final String? headerTitle;
  final int? headerCount;

  _SessionItem({
    this.session,
    this.showDate = false,
    this.isHeader = false,
    this.isNoSessionCard = false,
    this.headerTitle,
    this.headerCount,
  });
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: FaIcon(icon, size: 14, color: color),
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _EngineerSessionTile extends StatelessWidget {
  final Session session;
  final bool showDate;

  const _EngineerSessionTile({required this.session, this.showDate = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeFormat = DateFormat('HH:mm', 'fr_FR');
    final dateFormat = DateFormat('EEE d MMM', 'fr_FR');

    return GestureDetector(
      onTap: () => context.push('/engineer/sessions/${session.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getStatusColor(session.status).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: FaIcon(_getTypeIcon(session.type), size: 18, color: _getStatusColor(session.status))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.artistName,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      FaIcon(FontAwesomeIcons.clock, size: 10, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        showDate
                            ? '${dateFormat.format(session.scheduledStart)} • ${timeFormat.format(session.scheduledStart)}'
                            : '${timeFormat.format(session.scheduledStart)} - ${timeFormat.format(session.scheduledEnd)}',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildAction(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(ColorScheme colorScheme) {
    if (session.status == SessionStatus.confirmed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(10)),
        child: Text('Go', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onPrimary)),
      );
    }
    if (session.status == SessionStatus.inProgress) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
        child: const FaIcon(FontAwesomeIcons.play, size: 14, color: Colors.white),
      );
    }
    return FaIcon(FontAwesomeIcons.chevronRight, size: 14, color: colorScheme.onSurfaceVariant);
  }

  Color _getStatusColor(SessionStatus status) {
    return switch (status) {
      SessionStatus.pending => Colors.orange,
      SessionStatus.confirmed => Colors.blue,
      SessionStatus.inProgress => Colors.green,
      SessionStatus.completed => Colors.grey,
      SessionStatus.cancelled || SessionStatus.noShow => Colors.red,
    };
  }

  IconData _getTypeIcon(SessionType type) {
    return switch (type) {
      SessionType.recording => FontAwesomeIcons.microphone,
      SessionType.mix || SessionType.mixing => FontAwesomeIcons.sliders,
      SessionType.mastering => FontAwesomeIcons.compactDisc,
      SessionType.editing => FontAwesomeIcons.scissors,
      _ => FontAwesomeIcons.music,
    };
  }
}
