import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/localization/intl_locale.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/notification_bell.dart';

/// Welcome header with user info and notification button
class WelcomeHeader extends StatefulWidget {
  final bool isWideLayout;

  const WelcomeHeader({super.key, this.isWideLayout = false});

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
    final locale = intlLocale(context);
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

        final padding = widget.isWideLayout ? 24.0 : 16.0;
        final cs = Theme.of(context).colorScheme;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
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
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.calendarDay,
                          size: 11,
                          color: cs.onSurface.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          today,
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        if (city != null) ...[
                          const SizedBox(width: 10),
                          FaIcon(
                            FontAwesomeIcons.locationDot,
                            size: 10,
                            color: cs.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            city,
                            style: TextStyle(
                              fontSize: 13,
                              color: cs.onSurface.withValues(alpha: 0.5),
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
        final cs = Theme.of(context).colorScheme;
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.surface,
            ),
            child: ClipOval(
              child: Container(
                width: 56,
                height: 56,
                color: cs.surfaceContainerHigh,
                child: photoUrl != null && photoUrl.isNotEmpty
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        width: 56,
                        height: 56,
                        errorBuilder: (_, __, ___) => Center(
                          child: FaIcon(FontAwesomeIcons.user,
                              size: 22, color: cs.onSurfaceVariant),
                        ),
                      )
                    : Center(
                        child: FaIcon(FontAwesomeIcons.user,
                            size: 22, color: cs.onSurfaceVariant),
                      ),
              ),
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
