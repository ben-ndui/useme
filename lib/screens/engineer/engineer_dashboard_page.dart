import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uzme/config/responsive_config.dart';
import 'package:uzme/core/blocs/map/map_bloc.dart';
import 'package:uzme/core/blocs/map/map_state.dart';
import 'package:uzme/widgets/common/smooth_draggable_widget.dart';
import 'package:uzme/widgets/engineer/dashboard/engineer_home_feed.dart';
import 'package:uzme/widgets/map/floating_nav_widget.dart';
import 'package:uzme/widgets/map/map_dashboard_app_bar.dart';
import 'package:uzme/widgets/map/studio_detail_helper.dart';
import 'package:uzme/widgets/map/studio_map_view.dart';

/// Engineer Dashboard - Map + Collapsible Feed
class EngineerDashboardPage extends StatelessWidget {
  const EngineerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapBloc(),
      child: const _EngineerDashboardBody(),
    );
  }
}

class _EngineerDashboardBody extends StatelessWidget {
  const _EngineerDashboardBody();

  @override
  Widget build(BuildContext context) {
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
          titleIcon: FontAwesomeIcons.headphones,
        ),
        body: Stack(
          children: [
            const Positioned.fill(child: StudioMapView()),
            const FloatingNavWidget(),
            SlideInUp(
              duration: const Duration(milliseconds: 600),
              child: SmoothDraggableWidget(
                initial: 0.45,
                minSize: 0.20,
                maxSize: 1.0,
                bottomPadding: bottomPadding,
                floatingBottomPadding: bottomPadding,
                bodyContent: const EngineerHomeFeed(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
