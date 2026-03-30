import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/config/responsive_config.dart';
import 'package:useme/core/localization/intl_locale.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/common/dashboard/dashboard_exports.dart';
import 'package:useme/widgets/engineer/dashboard/engineer_dashboard_exports.dart';

/// Feed content for engineer dashboard (inside draggable sheet)
class EngineerHomeFeed extends StatelessWidget {
  const EngineerHomeFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = intlLocale(context);
    final spacing = context.itemSpacing;
    final baseScheme = Theme.of(context).colorScheme;

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: glassColorScheme(baseScheme),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
            child: _EngineerFeedHeader(l10n: l10n, locale: locale),
          ),
          SizedBox(height: spacing),
          EngineerStatsRow(l10n: l10n),
          SizedBox(height: spacing),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
            child: DashboardQuickPill(
              icon: FontAwesomeIcons.idCard,
              label: l10n.myCard,
              onTap: () => context.push(AppRoutes.digitalCard),
            ),
          ),
          SizedBox(height: spacing),
          EngineerProposedSection(l10n: l10n, locale: locale),
          EngineerSessionsList(l10n: l10n, locale: locale),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

}

/// Premium glass header for engineer feed
class _EngineerFeedHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final String locale;

  const _EngineerFeedHeader({required this.l10n, required this.locale});

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE d MMMM', locale).format(DateTime.now());

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String userName = l10n.engineer;
        String? photoURL;
        if (authState is AuthAuthenticatedState) {
          final user = authState.user as AppUser;
          userName = user.displayName ?? user.name ?? l10n.engineer;
          photoURL = user.photoURL;
        }

        return Row(
          children: [
            _buildAvatar(photoURL),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getGreeting(),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Color(0xFFB0C4DE)],
                    ).createShader(bounds),
                    child: Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      FaIcon(FontAwesomeIcons.calendarDay,
                          size: 11, color: Colors.white.withValues(alpha: 0.5)),
                      const SizedBox(width: 6),
                      Text(today,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.6),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatar(String? photoURL) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00CEC9).withValues(alpha: 0.3),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF00CEC9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipOval(
        child: photoURL != null && photoURL.isNotEmpty
            ? Image.network(
                photoURL,
                fit: BoxFit.cover,
                width: 52,
                height: 52,
                errorBuilder: (_, __, ___) => _avatarFallback(),
              )
            : _avatarFallback(),
      ),
    );
  }

  static Widget _avatarFallback() {
    return const Center(
      child: FaIcon(FontAwesomeIcons.headphones,
          color: Colors.white, size: 22),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 18) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }
}
