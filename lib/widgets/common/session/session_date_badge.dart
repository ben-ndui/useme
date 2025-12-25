import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A compact date badge showing day and month
class SessionDateBadge extends StatelessWidget {
  final DateTime date;
  final bool isPast;

  const SessionDateBadge({super.key, required this.date, this.isPast = false});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final dayFormat = DateFormat('d', locale);
    final monthFormat = DateFormat('MMM', locale);

    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: isPast
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              ),
        color: isPast ? Colors.white.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            dayFormat.format(date),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isPast ? const Color(0xFFB0C4DE) : Colors.white,
            ),
          ),
          Text(
            monthFormat.format(date).toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isPast
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.8),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
