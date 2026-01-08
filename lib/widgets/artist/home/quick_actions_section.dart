import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/artist/studio_selector_bottom_sheet.dart';

/// Quick actions horizontal scrollable section
class QuickActionsSection extends StatelessWidget {
  final bool isWideLayout;

  const QuickActionsSection({super.key, this.isWideLayout = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final padding = isWideLayout ? 24.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Text(
            l10n.quickAccess,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: padding),
            children: [
              QuickActionPill(
                icon: FontAwesomeIcons.plus,
                label: l10n.book,
                onTap: () => StudioSelectorBottomSheet.showAndNavigate(context),
              ),
              QuickActionPill(
                icon: FontAwesomeIcons.calendarDays,
                label: l10n.sessionsLabel,
                onTap: () => context.push('/artist/sessions'),
              ),
              QuickActionPill(
                icon: FontAwesomeIcons.solidMessage,
                label: l10n.messages,
                onTap: () => context.push('/messages'),
              ),
              QuickActionPill(
                icon: FontAwesomeIcons.solidHeart,
                label: l10n.favoritesLabel,
                onTap: () => context.push('/artist/favorites'),
              ),
              QuickActionPill(
                icon: FontAwesomeIcons.sliders,
                label: l10n.preferencesLabel,
                onTap: () => context.push('/artist/settings'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A pill-shaped quick action button
class QuickActionPill extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickActionPill({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<QuickActionPill> createState() => _QuickActionPillState();
}

class _QuickActionPillState extends State<QuickActionPill> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: _isPressed ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                widget.icon,
                size: 14,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
