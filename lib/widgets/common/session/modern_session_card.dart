import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:useme/core/localization/intl_locale.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/session/session_date_badge.dart';
import 'package:useme/widgets/common/session/session_status_chip.dart';

/// A modern glass-style session card for artist home feed
class ModernSessionCard extends StatefulWidget {
  final Session session;
  final bool isPast;

  const ModernSessionCard({super.key, required this.session, this.isPast = false});

  @override
  State<ModernSessionCard> createState() => _ModernSessionCardState();
}

class _ModernSessionCardState extends State<ModernSessionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = intlLocale(context);
    final timeFormat = DateFormat('HH:mm', locale);
    final dateFormat = DateFormat('EEE d MMM', locale);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: widget.isPast ? 0.05 : 0.1),
                  Colors.white.withValues(alpha: widget.isPast ? 0.02 : 0.05),
                ],
              )
            : null,
        color: isDark ? null : (widget.isPast ? cs.surfaceContainerLowest : cs.surfaceContainerHigh),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: widget.isPast ? 0.05 : 0.15)
              : cs.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          SessionDateBadge(
            date: widget.session.scheduledStart,
            isPast: widget.isPast,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _getTypeColor(widget.session.types.firstOrNull ?? SessionType.other)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FaIcon(
                        _getTypeIcon(widget.session.types.firstOrNull ?? SessionType.other),
                        size: 12,
                        color: _getTypeColor(widget.session.types.firstOrNull ?? SessionType.other),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.session.typeLabel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.isPast
                              ? cs.onSurface.withValues(alpha: 0.5)
                              : cs.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.clock,
                      size: 11,
                      color: cs.onSurface.withValues(alpha: 0.45),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${dateFormat.format(widget.session.scheduledStart)} • ${timeFormat.format(widget.session.scheduledStart)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SessionStatusChip(
            status: widget.session.displayStatus,
            paymentStatus: widget.session.paymentStatus,
            l10n: l10n,
          ),
        ],
      ),
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () => context.push('/artist/sessions/${widget.session.id}'),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: isDark
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: card,
                ),
              )
            : card,
      ),
    );
  }

  IconData _getTypeIcon(SessionType type) {
    switch (type) {
      case SessionType.recording:
        return FontAwesomeIcons.microphone;
      case SessionType.mix:
      case SessionType.mixing:
        return FontAwesomeIcons.sliders;
      case SessionType.mastering:
        return FontAwesomeIcons.compactDisc;
      case SessionType.editing:
        return FontAwesomeIcons.scissors;
      default:
        return FontAwesomeIcons.music;
    }
  }

  Color _getTypeColor(SessionType type) {
    switch (type) {
      case SessionType.recording:
        return const Color(0xFF3B82F6);
      case SessionType.mix:
      case SessionType.mixing:
        return const Color(0xFF8B5CF6);
      case SessionType.mastering:
        return const Color(0xFFF59E0B);
      case SessionType.editing:
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
