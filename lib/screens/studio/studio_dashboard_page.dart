import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/config/responsive_config.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/studio/dashboard/studio_dashboard_exports.dart';

/// Studio Dashboard - modern home page for studio owner
class StudioDashboardPage extends StatelessWidget {
  const StudioDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final padding = context.horizontalPadding;
    final spacing = context.itemSpacing;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(context),
        child: CustomScrollView(
          slivers: [
            StudioAppBar(l10n: l10n, locale: locale),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: Responsive.maxContentWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
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
                ),
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
