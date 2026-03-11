import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/favorite.dart';
import 'package:useme/widgets/favorite/favorite_button.dart';

/// Card for displaying a pro in the discovery carousel.
class ProCarouselCard extends StatelessWidget {
  final AppUser user;
  final VoidCallback onTap;

  const ProCarouselCard({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final profile = user.proProfile!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildBackground(profile),
              _buildGradient(),
              _buildContent(profile),
              _buildFavoriteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(dynamic profile) {
    if (user.displayPhotoUrl != null) {
      return Image.network(
        user.displayPhotoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(profile),
      );
    }
    return _buildPlaceholder(profile);
  }

  Widget _buildPlaceholder(dynamic profile) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A5F), Color(0xFF4A90D9)],
        ),
      ),
      child: Center(
        child: Text(
          profile.displayName.isNotEmpty
              ? profile.displayName[0].toUpperCase()
              : '?',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.8),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildContent(dynamic profile) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            profile.displayName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            profile.proTypesLabel,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFB0C4DE),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (profile.city != null)
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FaIcon(FontAwesomeIcons.locationDot,
                            size: 9, color: Colors.white),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            profile.city!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (profile.remote) ...[
                if (profile.city != null) const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const FaIcon(FontAwesomeIcons.wifi,
                      size: 9, color: Colors.greenAccent),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Positioned(
      top: 10,
      right: 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FavoriteButtonCompact(
              targetId: user.uid,
              type: FavoriteType.pro,
              targetName: user.proProfile!.displayName,
              targetPhotoUrl: user.displayPhotoUrl,
              targetAddress: user.proProfile!.city,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}
