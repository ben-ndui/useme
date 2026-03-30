import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/config/responsive_config.dart';
import 'package:useme/core/blocs/map/map_bloc.dart';
import 'package:useme/core/blocs/map/map_state.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/common/smooth_draggable_widget.dart';
import 'package:useme/widgets/map/floating_nav_widget.dart';
import 'package:useme/widgets/map/map_dashboard_app_bar.dart';
import 'package:useme/widgets/map/studio_detail_helper.dart';
import 'package:useme/widgets/map/studio_map_view.dart';
import 'package:useme/widgets/studio/dashboard/studio_home_feed.dart';

/// Studio Dashboard - Map + Collapsible Feed
class StudioDashboardPage extends StatelessWidget {
  const StudioDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapBloc(),
      child: const _StudioDashboardBody(),
    );
  }
}

class _StudioDashboardBody extends StatelessWidget {
  const _StudioDashboardBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isWide = context.isTabletOrLarger;
    final bottomPadding = isWide ? 16.0 : Responsive.fabBottomOffset;

    return BlocListener<MapBloc, MapState>(
      listenWhen: (prev, curr) =>
          prev.selectedStudio != curr.selectedStudio &&
          curr.selectedStudio != null,
      listener: (context, state) {
        openStudioOrProDetail(context, state.selectedStudio!);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: buildMapDashboardAppBar(
          context: context,
          titleIcon: FontAwesomeIcons.recordVinyl,
        ),
        body: Stack(
          children: [
            const Positioned.fill(child: StudioMapView()),
            const FloatingNavWidget(),
            SlideInUp(
              duration: const Duration(milliseconds: 600),
              child: SmoothDraggableWidget(
                initial: 0.55,
                minSize: 0.20,
                maxSize: 1.0,
                bottomPadding: bottomPadding,
                floatingBottomPadding: bottomPadding,
                floatButtons: [
                  Container(
                    margin: EdgeInsets.only(bottom: isWide ? 8 : 10),
                    child: FloatingActionButton.extended(
                      heroTag: 'addSession',
                      onPressed: () => context.push(AppRoutes.sessionAdd),
                      icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
                      label: Text(l10n.session),
                    ),
                  ),
                ],
                bodyContent: const StudioHomeFeed(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
