import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Animated notification button with unread count badge
class NotificationButton extends StatefulWidget {
  final int unreadCount;
  final VoidCallback onTap;

  const NotificationButton({super.key, required this.unreadCount, required this.onTap});

  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    if (widget.unreadCount > 0) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant NotificationButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.unreadCount > 0 && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (widget.unreadCount == 0) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final glowOpacity = widget.unreadCount > 0
                ? 0.3 + (_pulseController.value * 0.2)
                : 0.0;
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: widget.unreadCount > 0
                              ? const Color(0xFFF43F5E).withValues(alpha: glowOpacity)
                              : Colors.white.withValues(alpha: 0.2),
                          width: widget.unreadCount > 0 ? 2 : 1,
                        ),
                        boxShadow: widget.unreadCount > 0
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFF43F5E).withValues(alpha: glowOpacity),
                                  blurRadius: 12,
                                  spreadRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      child: const Center(
                        child: FaIcon(FontAwesomeIcons.bell, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                if (widget.unreadCount > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                        ),
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF43F5E).withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.unreadCount > 9 ? '9+' : '${widget.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
