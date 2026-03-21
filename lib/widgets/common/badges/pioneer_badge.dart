import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Gold glassmorphism badge for Pioneer users (#1 to #5).
/// Use [compact] mode for map pins and lists, full mode for detail screens.
class PioneerBadge extends StatelessWidget {
  final int pioneerNumber;
  final bool compact;

  const PioneerBadge({
    super.key,
    required this.pioneerNumber,
    this.compact = false,
  });

  static const _gold = Color(0xFFFFD700);
  static const _darkGold = Color(0xFFFFA500);

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompact();
    return _buildFull();
  }

  Widget _buildCompact() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_gold, _darkGold],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FaIcon(FontAwesomeIcons.crown, size: 10, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                '#$pioneerNumber',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFull() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_gold, _darkGold],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FaIcon(FontAwesomeIcons.crown, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                'Pioneer #$pioneerNumber',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
