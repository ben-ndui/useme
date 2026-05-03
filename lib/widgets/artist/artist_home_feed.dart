import 'package:flutter/material.dart';
import 'package:uzme/widgets/artist/home/home_exports.dart';
import 'package:uzme/widgets/artist/nearby_studios_carousel.dart';
import 'package:uzme/widgets/artist/studio_detail_bottom_sheet.dart';
import 'package:uzme/widgets/common/dashboard/glass_color_scheme.dart';
import 'package:uzme/widgets/pro/pro_detail_bottom_sheet.dart';
import 'package:uzme/widgets/pro/pro_discovery_carousel.dart';

/// Main feed content for artist home (inside draggable sheet)
class ArtistHomeFeed extends StatelessWidget {
  final bool isWideLayout;

  const ArtistHomeFeed({super.key, this.isWideLayout = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseScheme = Theme.of(context).colorScheme;
    final spacing = isWideLayout ? 32.0 : 28.0;

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: isDark ? glassColorScheme(baseScheme) : baseScheme,
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WelcomeHeader(isWideLayout: isWideLayout),
        SizedBox(height: spacing),
        PendingPaymentBanner(isWideLayout: isWideLayout),
        NearbyStudiosCarousel(
          onStudioTap: (studio) => StudioDetailBottomSheet.show(context, studio),
          isWideLayout: isWideLayout,
        ),
        SizedBox(height: spacing),
        ProDiscoveryCarousel(
          onProTap: (user) => ProDetailBottomSheet.show(context, user),
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
      ));
  }
}
