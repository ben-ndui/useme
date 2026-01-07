import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/notification_bell.dart';

/// Welcome header with user info and notification button
class WelcomeHeader extends StatefulWidget {
  const WelcomeHeader({super.key});

  @override
  State<WelcomeHeader> createState() => _WelcomeHeaderState();
}

class _WelcomeHeaderState extends State<WelcomeHeader>
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
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final today = DateFormat('EEEE d MMMM', locale).format(DateTime.now());

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
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: _buildAnimatedAvatar(photoUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(l10n),
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
              NotificationBell(
                userId: authState is AuthAuthenticatedState
                    ? authState.user.uid
                    : '',
                onTap: () => context.push('/notifications'),
                useGlassStyle: true,
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

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 18) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }
}
