import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/blocs/map/map_bloc.dart';
import 'package:useme/widgets/artist/artist_home_feed.dart';
import 'package:useme/widgets/common/smooth_draggable_widget.dart';
import 'package:useme/widgets/map/studio_map_view.dart';

/// Artist portal - Dashboard with Map + Collapsible Feed (Viba style)
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => MapBloc(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  FontAwesomeIcons.music,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Use Me',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: IconButton(
                icon: const FaIcon(FontAwesomeIcons.bell, size: 18),
                onPressed: () => context.push('/notifications'),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Map in background (full screen)
            const Positioned.fill(
              child: StudioMapView(),
            ),

            // Collapsible feed overlay with Viba blue gradient
            SlideInUp(
              duration: const Duration(milliseconds: 600),
              child: SmoothDraggableWidget(
                initial: 0.20,
                minSize: 0.20,
                maxSize: 1.0,
                // Uses default Viba blue gradient
                bottomPadding: 100,
                floatButtons: [
                  FloatingActionButton.extended(
                    heroTag: 'book',
                    onPressed: () => context.push('/artist/request'),
                    icon: const FaIcon(FontAwesomeIcons.calendarPlus, size: 16),
                    label: const Text('Réserver'),
                  ),
                ],
                bodyContent: const ArtistHomeFeed(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
