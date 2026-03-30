import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/config/responsive_config.dart';
import 'package:useme/core/localization/intl_locale.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/dashboard/glass_color_scheme.dart';
import 'package:useme/widgets/studio/dashboard/studio_dashboard_exports.dart';

/// Feed content for studio dashboard (inside draggable sheet)
class StudioHomeFeed extends StatelessWidget {
  const StudioHomeFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = intlLocale(context);
    final padding = context.horizontalPadding;
    final spacing = context.itemSpacing;
    final baseScheme = Theme.of(context).colorScheme;

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: glassColorScheme(baseScheme),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StudioFeedHeader(l10n: l10n, locale: locale),
            SizedBox(height: spacing),
            StudioQuickAccess(l10n: l10n),
            SizedBox(height: spacing),
            StudioStatsGrid(l10n: l10n),
            SizedBox(height: spacing),
            StudioTodayTimeline(l10n: l10n, locale: locale),
            SizedBox(height: spacing),
            StudioPendingRequests(l10n: l10n, locale: locale),
            SizedBox(height: spacing),
            StudioRecentArtists(l10n: l10n),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

}

/// Premium glass header for studio feed
class _StudioFeedHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final String locale;

  const _StudioFeedHeader({required this.l10n, required this.locale});

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE d MMMM', locale).format(DateTime.now());

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String studioName = l10n.myStudio;
        String? photoUrl;

        if (authState is AuthAuthenticatedState) {
          final user = authState.user as AppUser;
          studioName = user.displayName ?? user.name ?? l10n.myStudio;
          photoUrl = user.photoURL;
        }

        return Row(
          children: [
            _buildAvatar(photoUrl),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Color(0xFFB0C4DE)],
                    ).createShader(bounds),
                    child: Text(
                      studioName,
                      style: const TextStyle(
                        fontSize: 20,
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

  Widget _buildAvatar(String? photoUrl) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
        color: Colors.white.withValues(alpha: 0.1),
        image: photoUrl != null
            ? DecorationImage(
                image: NetworkImage(photoUrl), fit: BoxFit.cover)
            : null,
      ),
      child: photoUrl == null
          ? const Center(
              child: FaIcon(FontAwesomeIcons.recordVinyl,
                  size: 22, color: Colors.white),
            )
          : null,
    );
  }
}
