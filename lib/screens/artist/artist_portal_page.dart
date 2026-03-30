import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/config/responsive_config.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/blocs/map/map_bloc.dart';
import 'package:useme/core/blocs/map/map_state.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/artist/artist_home_feed.dart';
import 'package:useme/widgets/artist/studio_selector_bottom_sheet.dart';
import 'package:useme/widgets/common/smooth_draggable_widget.dart';
import 'package:useme/widgets/map/floating_nav_widget.dart';
import 'package:useme/widgets/map/map_dashboard_app_bar.dart';
import 'package:useme/widgets/map/studio_detail_helper.dart';
import 'package:useme/widgets/map/studio_map_view.dart';

/// Artist portal - Dashboard with Map + Collapsible Feed
class ArtistPortalPage extends StatefulWidget {
  const ArtistPortalPage({super.key});

  @override
  State<ArtistPortalPage> createState() => _ArtistPortalPageState();
}

class _ArtistPortalPageState extends State<ArtistPortalPage> {
  @override
  void initState() {
    super.initState();
    _loadArtistData();
  }

  void _loadArtistData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      context.read<SessionBloc>().add(
            LoadArtistSessionsEvent(artistId: authState.user.uid),
          );
      context.read<ProProfileBloc>().add(const SearchProsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // On tablet, the scaffold already has a NavigationRail — no bottom nav
    final isWide = context.isTabletOrLarger;
    final bottomPadding = isWide ? 16.0 : Responsive.fabBottomOffset;

    return BlocProvider(
      create: (context) => MapBloc(),
      child: BlocListener<MapBloc, MapState>(
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
          titleIcon: FontAwesomeIcons.music,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: const StudioMapView(),
            ),
            const FloatingNavWidget(),
            SlideInUp(
              duration: const Duration(milliseconds: 600),
              child: SmoothDraggableWidget(
                initial: 0.20,
                minSize: 0.20,
                maxSize: 1.0,
                bottomPadding: bottomPadding,
                floatingBottomPadding: bottomPadding,
                floatButtons: [
                  Container(
                    margin: EdgeInsets.only(bottom: isWide ? 8 : 10),
                    child: FloatingActionButton.extended(
                      heroTag: 'book',
                      onPressed: () =>
                          StudioSelectorBottomSheet.showAndNavigate(context),
                      icon: const FaIcon(FontAwesomeIcons.calendarPlus,
                          size: 16),
                      label: Text(l10n.book),
                    ),
                  ),
                ],
                bodyContent: const ArtistHomeFeed(),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

}
