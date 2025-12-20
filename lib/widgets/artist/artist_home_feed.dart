import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/widgets/artist/nearby_studios_carousel.dart';

/// Main feed content for artist home (inside draggable sheet - dark blue bg)
class ArtistHomeFeed extends StatelessWidget {
  const ArtistHomeFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WelcomeHeader(),
        const SizedBox(height: 28),
        const NearbyStudiosCarousel(),
        const SizedBox(height: 28),
        _QuickActionsSection(),
        const SizedBox(height: 28),
        _UpcomingSessionsSection(),
        const SizedBox(height: 28),
        _RecentActivitySection(),
        const SizedBox(height: 40),
      ],
    );
  }
}

// =============================================================================
// WELCOME HEADER
// =============================================================================

class _WelcomeHeader extends StatefulWidget {
  @override
  State<_WelcomeHeader> createState() => _WelcomeHeaderState();
}

class _WelcomeHeaderState extends State<_WelcomeHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.now());

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String userName = 'Artiste';
        String? photoUrl;
        String? city;

        if (authState is AuthAuthenticatedState) {
          final user = authState.user as AppUser;
          userName = user.stageName ?? user.displayName ?? user.name ?? 'Artiste';
          photoUrl = user.photoURL;
          city = user.city;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Avatar with animated gradient ring
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: _buildAnimatedAvatar(photoUrl),
              ),
              const SizedBox(width: 16),

              // Greeting & Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Color(0xFFB0C4DE)],
                      ).createShader(bounds),
                      child: Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.calendarDay,
                          size: 11,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          today,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        if (city != null) ...[
                          const SizedBox(width: 10),
                          FaIcon(
                            FontAwesomeIcons.locationDot,
                            size: 10,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            city,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Notification bell with real count
              BlocBuilder<MessagingBloc, MessagingState>(
                builder: (context, msgState) {
                  int unreadCount = 0;
                  if (msgState is ConversationsLoadedState) {
                    unreadCount = msgState.totalUnreadCount;
                  }
                  return _NotificationButton(
                    unreadCount: unreadCount,
                    onTap: () => context.push('/notifications'),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedAvatar(String? photoUrl) {
    return AnimatedBuilder(
      animation: _ringController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              startAngle: _ringController.value * 6.28,
              colors: const [
                Color(0xFF3B82F6),
                Color(0xFF8B5CF6),
                Color(0xFFF59E0B),
                Color(0xFF10B981),
                Color(0xFF3B82F6),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF1E3A5F),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? const FaIcon(FontAwesomeIcons.user, size: 22, color: Colors.white)
                  : null,
            ),
          ),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '🌙';
    if (hour < 12) return '☀️';
    if (hour < 18) return '🎵';
    if (hour < 21) return '🌅';
    return '🌙';
  }
}

class _NotificationButton extends StatefulWidget {
  final int unreadCount;
  final VoidCallback onTap;

  const _NotificationButton({required this.unreadCount, required this.onTap});

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    if (widget.unreadCount > 0) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _NotificationButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.unreadCount > 0 && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (widget.unreadCount == 0) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final glowOpacity = widget.unreadCount > 0
                ? 0.3 + (_pulseController.value * 0.2)
                : 0.0;
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: widget.unreadCount > 0
                              ? const Color(0xFFF43F5E).withValues(alpha: glowOpacity)
                              : Colors.white.withValues(alpha: 0.2),
                          width: widget.unreadCount > 0 ? 2 : 1,
                        ),
                        boxShadow: widget.unreadCount > 0
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFF43F5E).withValues(alpha: glowOpacity),
                                  blurRadius: 12,
                                  spreadRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      child: const Center(
                        child: FaIcon(FontAwesomeIcons.bell, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                if (widget.unreadCount > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                        ),
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF43F5E).withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.unreadCount > 9 ? '9+' : '${widget.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// QUICK ACTIONS
// =============================================================================

class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Accès rapide',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _QuickActionPill(
                icon: FontAwesomeIcons.plus,
                label: 'Réserver',
                onTap: () => context.push('/artist/request'),
              ),
              _QuickActionPill(
                icon: FontAwesomeIcons.calendarDays,
                label: 'Sessions',
                onTap: () => context.push('/artist/sessions'),
              ),
              _QuickActionPill(
                icon: FontAwesomeIcons.solidMessage,
                label: 'Messages',
                onTap: () => context.push('/messages'),
              ),
              _QuickActionPill(
                icon: FontAwesomeIcons.solidHeart,
                label: 'Favoris',
                onTap: () => context.push('/artist/favorites'),
              ),
              _QuickActionPill(
                icon: FontAwesomeIcons.sliders,
                label: 'Préférences',
                onTap: () => context.push('/artist/settings'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionPill extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_QuickActionPill> createState() => _QuickActionPillState();
}

class _QuickActionPillState extends State<_QuickActionPill> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: _isPressed ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                widget.icon,
                size: 14,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// UPCOMING SESSIONS
// =============================================================================

class _UpcomingSessionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SectionHeader(
                  title: 'Sessions à venir',
                  icon: FontAwesomeIcons.calendarDays,
                ),
              ),
              _GlassChip(
                label: 'Voir tout',
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
                return _EmptyStateCard(
                  icon: FontAwesomeIcons.calendarXmark,
                  title: 'Aucune session prévue',
                  subtitle: 'Réserve ta prochaine session en studio',
                  actionLabel: 'Réserver',
                  onAction: () => context.push('/artist/request'),
                );
              }

              return Column(
                children: upcoming.take(3).map((session) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ModernSessionCard(session: session),
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
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ShimmerSessionCard(),
        );
      }),
    );
  }
}

// =============================================================================
// RECENT ACTIVITY
// =============================================================================

class _RecentActivitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Activité récente',
            icon: FontAwesomeIcons.clockRotateLeft,
          ),
          const SizedBox(height: 16),
          BlocBuilder<SessionBloc, SessionState>(
            builder: (context, state) {
              final past = _getPastSessions(state.sessions);
              if (past.isEmpty) {
                return _EmptyStateCard(
                  icon: FontAwesomeIcons.music,
                  title: 'Pas encore d\'historique',
                  subtitle: 'Tes sessions terminées apparaîtront ici',
                );
              }

              return Column(
                children: past.take(2).map((session) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ModernSessionCard(session: session, isPast: true),
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

// =============================================================================
// MODERN SESSION CARD
// =============================================================================

class _ModernSessionCard extends StatefulWidget {
  final Session session;
  final bool isPast;

  const _ModernSessionCard({required this.session, this.isPast = false});

  @override
  State<_ModernSessionCard> createState() => _ModernSessionCardState();
}

class _ModernSessionCardState extends State<_ModernSessionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm', 'fr_FR');
    final dateFormat = DateFormat('EEE d MMM', 'fr_FR');

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () => context.push('/artist/sessions/${widget.session.id}'),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: widget.isPast ? 0.05 : 0.1),
                    Colors.white.withValues(alpha: widget.isPast ? 0.02 : 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: widget.isPast ? 0.05 : 0.15),
                ),
              ),
              child: Row(
                children: [
                  // Date badge
                  _DateBadge(
                    date: widget.session.scheduledStart,
                    isPast: widget.isPast,
                  ),
                  const SizedBox(width: 16),

                  // Session info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _getTypeColor(widget.session.type)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: FaIcon(
                                _getTypeIcon(widget.session.type),
                                size: 12,
                                color: _getTypeColor(widget.session.type),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.session.type.label,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: widget.isPast
                                      ? const Color(0xFFB0C4DE)
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.clock,
                              size: 11,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${dateFormat.format(widget.session.scheduledStart)} • ${timeFormat.format(widget.session.scheduledStart)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status chip
                  _StatusChip(status: widget.session.status),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
}

class _DateBadge extends StatelessWidget {
  final DateTime date;
  final bool isPast;

  const _DateBadge({required this.date, this.isPast = false});

  @override
  Widget build(BuildContext context) {
    final dayFormat = DateFormat('d', 'fr_FR');
    final monthFormat = DateFormat('MMM', 'fr_FR');

    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: isPast
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              ),
        color: isPast ? Colors.white.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            dayFormat.format(date),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isPast ? const Color(0xFFB0C4DE) : Colors.white,
            ),
          ),
          Text(
            monthFormat.format(date).toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isPast
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.8),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final SessionStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (status) {
      SessionStatus.pending => (Colors.orange, FontAwesomeIcons.hourglass, 'Attente'),
      SessionStatus.confirmed => (Colors.blue, FontAwesomeIcons.circleCheck, 'Confirmée'),
      SessionStatus.inProgress => (Colors.green, FontAwesomeIcons.play, 'En cours'),
      SessionStatus.completed => (Colors.grey, FontAwesomeIcons.check, 'Terminée'),
      SessionStatus.cancelled => (Colors.red, FontAwesomeIcons.xmark, 'Annulée'),
      SessionStatus.noShow => (Colors.red, FontAwesomeIcons.userXmark, 'Absent'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 10, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SHARED COMPONENTS
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FaIcon(icon, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}


class _GlassChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _GlassChip({required this.label, required this.onTap});

  @override
  State<_GlassChip> createState() => _GlassChipState();
}

class _GlassChipState extends State<_GlassChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              const FaIcon(FontAwesomeIcons.chevronRight, size: 10, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: FaIcon(icon, size: 24, color: const Color(0xFFB0C4DE)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFFB0C4DE)),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            _ActionButton(label: actionLabel!, onTap: onAction!),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.onTap});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerSessionCard extends StatefulWidget {
  @override
  State<_ShimmerSessionCard> createState() => _ShimmerSessionCardState();
}

class _ShimmerSessionCardState extends State<_ShimmerSessionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
          ),
        );
      },
    );
  }
}
