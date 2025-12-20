import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/routing/app_routes.dart';

/// Studio Dashboard - modern home page for studio owner
class StudioDashboardPage extends StatelessWidget {
  const StudioDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(context),
        child: CustomScrollView(
          slivers: [
            _StudioAppBar(),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  _QuickAccessRow(),
                  const SizedBox(height: 24),
                  _StatsGrid(),
                  const SizedBox(height: 24),
                  _TodayTimeline(),
                  const SizedBox(height: 24),
                  _PendingRequests(),
                  const SizedBox(height: 24),
                  _RecentArtists(),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _refreshData(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      final userId = authState.user.uid;
      context.read<SessionBloc>().add(LoadSessionsEvent(studioId: userId));
      context.read<ArtistBloc>().add(LoadArtistsEvent(studioId: userId));
      context.read<ServiceBloc>().add(LoadServicesEvent(studioId: userId));
    }
  }
}

// =============================================================================
// APP BAR
// =============================================================================

class _StudioAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.now());

    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                String studioName = 'Mon Studio';
                String? photoUrl;

                if (authState is AuthAuthenticatedState) {
                  final user = authState.user as AppUser;
                  studioName = user.displayName ?? user.name ?? 'Mon Studio';
                  photoUrl = user.photoURL;
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Studio logo
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        image: photoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(photoUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: photoUrl == null
                          ? Center(
                              child: FaIcon(
                                FontAwesomeIcons.recordVinyl,
                                size: 24,
                                color: theme.colorScheme.primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),

                    // Studio info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            studioName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            today,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Notifications
                    _IconBtn(
                      icon: FontAwesomeIcons.bell,
                      onTap: () => context.push(AppRoutes.notifications),
                      badge: true,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// QUICK ACCESS
// =============================================================================

class _QuickAccessRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _QuickPill(
            icon: FontAwesomeIcons.plus,
            label: 'Session',
            isPrimary: true,
            onTap: () => context.push(AppRoutes.sessionAdd),
          ),
          _QuickPill(
            icon: FontAwesomeIcons.userPlus,
            label: 'Artiste',
            onTap: () => context.push(AppRoutes.artistAdd),
          ),
          _QuickPill(
            icon: FontAwesomeIcons.calendarDays,
            label: 'Planning',
            onTap: () => context.push(AppRoutes.sessions),
          ),
          _QuickPill(
            icon: FontAwesomeIcons.chartLine,
            label: 'Stats',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _QuickPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _QuickPill({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: isPrimary ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  icon,
                  size: 14,
                  color: isPrimary ? Colors.white : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isPrimary ? Colors.white : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// STATS GRID
// =============================================================================

class _StatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Vue d\'ensemble'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: BlocBuilder<SessionBloc, SessionState>(
                builder: (context, state) {
                  final today = state.sessions.where((s) => s.isOnDate(DateTime.now())).length;
                  return _StatCard(
                    label: 'Aujourd\'hui',
                    value: today.toString(),
                    icon: FontAwesomeIcons.calendar,
                    color: const Color(0xFF3B82F6),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BlocBuilder<SessionBloc, SessionState>(
                builder: (context, state) {
                  final pending = state.sessions.where((s) => s.status == SessionStatus.pending).length;
                  return _StatCard(
                    label: 'En attente',
                    value: pending.toString(),
                    icon: FontAwesomeIcons.hourglass,
                    color: const Color(0xFFF59E0B),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: BlocBuilder<ArtistBloc, ArtistState>(
                builder: (context, state) {
                  return _StatCard(
                    label: 'Artistes',
                    value: state.artists.length.toString(),
                    icon: FontAwesomeIcons.users,
                    color: const Color(0xFF8B5CF6),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BlocBuilder<SessionBloc, SessionState>(
                builder: (context, state) {
                  final now = DateTime.now();
                  final month = state.sessions.where((s) =>
                    s.scheduledStart.year == now.year && s.scheduledStart.month == now.month
                  ).length;
                  return _StatCard(
                    label: 'Ce mois',
                    value: month.toString(),
                    icon: FontAwesomeIcons.chartSimple,
                    color: const Color(0xFF10B981),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: FaIcon(icon, size: 18, color: color),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TODAY TIMELINE
// =============================================================================

class _TodayTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionTitle(title: 'Sessions du jour'),
            _ViewAllChip(onTap: () => context.push(AppRoutes.sessions)),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<SessionBloc, SessionState>(
          builder: (context, state) {
            final today = DateTime.now();
            final todaySessions = state.sessions
                .where((s) => s.isOnDate(today))
                .toList()
              ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));

            if (todaySessions.isEmpty) {
              return _EmptyCard(
                icon: FontAwesomeIcons.calendarCheck,
                title: 'Journée libre',
                subtitle: 'Aucune session programmée',
              );
            }

            return Column(
              children: todaySessions.take(4).map((session) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TimelineSessionCard(session: session),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _TimelineSessionCard extends StatelessWidget {
  final Session session;

  const _TimelineSessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm', 'fr_FR');
    final isNow = _isCurrentSession();

    return Material(
      color: isNow ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.push('/sessions/${session.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Time column
              SizedBox(
                width: 50,
                child: Column(
                  children: [
                    Text(
                      timeFormat.format(session.scheduledStart),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isNow ? theme.colorScheme.primary : null,
                      ),
                    ),
                    Text(
                      timeFormat.format(session.scheduledEnd),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                width: 3,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _getTypeColor(session.type),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Info
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
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        FaIcon(
                          _getTypeIcon(session.type),
                          size: 11,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          session.type.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status
              _StatusBadge(status: session.status),
            ],
          ),
        ),
      ),
    );
  }

  bool _isCurrentSession() {
    final now = DateTime.now();
    return now.isAfter(session.scheduledStart) && now.isBefore(session.scheduledEnd);
  }

  Color _getTypeColor(SessionType type) {
    switch (type) {
      case SessionType.recording:
        return const Color(0xFF3B82F6);
      case SessionType.mix:
      case SessionType.mixing:
        return const Color(0xFF8B5CF6);
      case SessionType.mastering:
        return const Color(0xFFF59E0B);
      case SessionType.editing:
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getTypeIcon(SessionType type) {
    switch (type) {
      case SessionType.recording:
        return FontAwesomeIcons.microphone;
      case SessionType.mix:
      case SessionType.mixing:
        return FontAwesomeIcons.sliders;
      case SessionType.mastering:
        return FontAwesomeIcons.compactDisc;
      case SessionType.editing:
        return FontAwesomeIcons.scissors;
      default:
        return FontAwesomeIcons.music;
    }
  }
}

// =============================================================================
// PENDING REQUESTS
// =============================================================================

class _PendingRequests extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        final pending = state.sessions.where((s) => s.status == SessionStatus.pending).toList();

        if (pending.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: 'Demandes en attente', count: pending.length),
            const SizedBox(height: 12),
            ...pending.take(3).map((session) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PendingCard(session: session),
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

  const _PendingCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEE d MMM', 'fr_FR');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
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
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${session.type.label} • ${dateFormat.format(session.scheduledStart)}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionBtn(
                icon: FontAwesomeIcons.xmark,
                color: Colors.red,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _ActionBtn(
                icon: FontAwesomeIcons.check,
                color: Colors.green,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// RECENT ARTISTS
// =============================================================================

class _RecentArtists extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArtistBloc, ArtistState>(
      builder: (context, state) {
        if (state.artists.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionTitle(title: 'Artistes récents'),
                _ViewAllChip(onTap: () => context.push(AppRoutes.artists)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.artists.take(8).length,
                itemBuilder: (context, index) {
                  final artist = state.artists[index];
                  return _ArtistChip(artist: artist);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ArtistChip extends StatelessWidget {
  final Artist artist;

  const _ArtistChip({required this.artist});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () => context.push('/artists/${artist.id}'),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage: artist.photoUrl != null ? NetworkImage(artist.photoUrl!) : null,
              child: artist.photoUrl == null
                  ? Text(
                      artist.displayName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 60,
              child: Text(
                artist.displayName.split(' ').first,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SHARED COMPONENTS
// =============================================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  final int? count;

  const _SectionTitle({required this.title, this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ],
    );
  }
}

class _ViewAllChip extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewAllChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Text(
        'Voir tout',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          FaIcon(icon, size: 28, color: theme.colorScheme.outline),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

  const _IconBtn({required this.icon, required this.onTap, this.badge = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Material(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: FaIcon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ),
        if (badge)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            ),
          ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: FaIcon(icon, size: 14, color: color),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final SessionStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      SessionStatus.pending => (Colors.orange, 'Attente'),
      SessionStatus.confirmed => (Colors.blue, 'Confirmé'),
      SessionStatus.inProgress => (Colors.green, 'En cours'),
      SessionStatus.completed => (Colors.grey, 'Terminé'),
      SessionStatus.cancelled => (Colors.red, 'Annulé'),
      SessionStatus.noShow => (Colors.red, 'Absent'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
