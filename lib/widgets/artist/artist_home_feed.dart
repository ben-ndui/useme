import 'package:flutter/material.dart';
import 'package:useme/widgets/artist/home/home_exports.dart';
import 'package:useme/widgets/artist/nearby_studios_carousel.dart';
import 'package:useme/widgets/artist/studio_detail_bottom_sheet.dart';

/// Main feed content for artist home (inside draggable sheet - dark blue bg)
class ArtistHomeFeed extends StatelessWidget {
  const ArtistHomeFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const WelcomeHeader(),
        const SizedBox(height: 28),
        NearbyStudiosCarousel(
          onStudioTap: (studio) => StudioDetailBottomSheet.show(context, studio),
        ),
        const SizedBox(height: 28),
        const QuickActionsSection(),
        const SizedBox(height: 28),
        const UpcomingSessionsSection(),
        const SizedBox(height: 28),
        const RecentActivitySection(),
        const SizedBox(height: 100),
      ],
    );
  }
}
