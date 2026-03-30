import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/widgets/card/holo_card_theme.dart';
import 'package:useme/widgets/common/badges/pioneer_badge.dart';

/// Interior content layout for the holographic card.
/// Credit-card aspect ratio with user info + QR code.
class HoloCardContent extends StatelessWidget {
  final AppUser user;
  final HoloCardTheme theme;

  const HoloCardContent({
    super.key,
    required this.user,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopRow(),
          _buildCenter(),
          _buildBottomRow(),
        ],
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // UZME logo
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [theme.accentColor, Colors.white],
          ).createShader(bounds),
          child: const Text(
            'UZME',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 8,
            ),
          ),
        ),
        if (user.isPioneer)
          const PioneerBadge(pioneerNumber: 0, compact: true),
      ],
    );
  }

  Widget _buildCenter() {
    final isStudio = user.isStudio || user.isSuperAdmin;
    final displayName = isStudio
        ? user.studioDisplayName
        : (user.stageName ?? user.displayName ?? user.name ?? '');
    final location = isStudio
        ? user.studioProfile?.address
        : user.city;
    final photoUrl = user.displayPhotoUrl;
    final initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Row(
      children: [
        _buildAvatar(photoUrl, initial),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              _buildRoleBadge(),
              if (location != null && location.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    FaIcon(FontAwesomeIcons.locationDot,
                        size: 10,
                        color: Colors.white.withValues(alpha: 0.5)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String? photoUrl, String initial) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.glowColor.withValues(alpha: 0.3),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: photoUrl != null
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                width: 64,
                height: 64,
                errorBuilder: (_, __, ___) => _initialsFallback(initial),
              )
            : _initialsFallback(initial),
      ),
    );
  }

  Widget _buildRoleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        theme.roleLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: theme.accentColor,
        ),
      ),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Badges
        Row(
          children: [
            if (user.isPartner) _buildMiniBadge(FontAwesomeIcons.solidCircleCheck, 'Partner'),
            if (user.isPro) ...[
              if (user.isPartner) const SizedBox(width: 8),
              _buildMiniBadge(FontAwesomeIcons.briefcase, 'Pro'),
            ],
          ],
        ),
        // QR Code
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: QrImageView(
            data: 'https://uzme.app/u/${user.uid}',
            version: QrVersions.auto,
            size: 58,
            padding: EdgeInsets.all(2),
            backgroundColor: Colors.white,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: theme.primaryColor,
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: theme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 10, color: theme.accentColor),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _initialsFallback(String initial) {
    return Container(
      color: theme.primaryColor.withValues(alpha: 0.5),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
