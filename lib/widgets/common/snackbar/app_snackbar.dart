import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Types of snackbar notifications
enum SnackBarType {
  success,
  error,
  warning,
  info,
}

/// A custom snackbar that follows the app's design language
class AppSnackBar {
  AppSnackBar._();

  /// Shows a styled snackbar with the given message and type
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final config = _getTypeConfig(type);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _SnackBarContent(
          message: message,
          icon: config.icon,
          iconColor: config.iconColor,
          backgroundColor: config.backgroundColor,
          borderColor: config.borderColor,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// Shows a success snackbar
  static void success(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.success);
  }

  /// Shows an error snackbar
  static void error(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.error);
  }

  /// Shows a warning snackbar
  static void warning(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.warning);
  }

  /// Shows an info snackbar
  static void info(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.info);
  }

  static _SnackBarConfig _getTypeConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarConfig(
          icon: FontAwesomeIcons.circleCheck,
          iconColor: const Color(0xFF22C55E),
          backgroundColor: const Color(0xFF22C55E).withValues(alpha: 0.15),
          borderColor: const Color(0xFF22C55E).withValues(alpha: 0.3),
        );
      case SnackBarType.error:
        return _SnackBarConfig(
          icon: FontAwesomeIcons.circleExclamation,
          iconColor: const Color(0xFFEF4444),
          backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.15),
          borderColor: const Color(0xFFEF4444).withValues(alpha: 0.3),
        );
      case SnackBarType.warning:
        return _SnackBarConfig(
          icon: FontAwesomeIcons.triangleExclamation,
          iconColor: const Color(0xFFF59E0B),
          backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
          borderColor: const Color(0xFFF59E0B).withValues(alpha: 0.3),
        );
      case SnackBarType.info:
        return _SnackBarConfig(
          icon: FontAwesomeIcons.circleInfo,
          iconColor: const Color(0xFF3B82F6),
          backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.15),
          borderColor: const Color(0xFF3B82F6).withValues(alpha: 0.3),
        );
    }
  }
}

class _SnackBarConfig {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;

  const _SnackBarConfig({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}

class _SnackBarContent extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SnackBarContent({
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: FaIcon(icon, size: 16, color: iconColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                onAction!();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  actionLabel!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
