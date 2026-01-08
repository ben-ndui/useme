import 'package:flutter/material.dart';
import 'package:useme/widgets/artist/home/home_exports.dart';
import 'package:useme/widgets/artist/nearby_studios_carousel.dart';
import 'package:useme/widgets/artist/studio_detail_bottom_sheet.dart';

/// Main feed content for artist home (inside draggable sheet - dark blue bg)
class ArtistHomeFeed extends StatelessWidget {
  final bool isWideLayout;

  const ArtistHomeFeed({super.key, this.isWideLayout = false});

  @override
  Widget build(BuildContext context) {
    final spacing = isWideLayout ? 32.0 : 28.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WelcomeHeader(isWideLayout: isWideLayout),
        SizedBox(height: spacing),
        NearbyStudiosCarousel(
          onStudioTap: (studio) => StudioDetailBottomSheet.show(context, studio),
          isWideLayout: isWideLayout,
        ),
        SizedBox(height: spacing),
        QuickActionsSection(isWideLayout: isWideLayout),
        SizedBox(height: spacing),
        UpcomingSessionsSection(isWideLayout: isWideLayout),
        SizedBox(height: spacing),
        RecentActivitySection(isWideLayout: isWideLayout),
        SizedBox(height: isWideLayout ? 24 : 100),
      ],
    );
  }
}
