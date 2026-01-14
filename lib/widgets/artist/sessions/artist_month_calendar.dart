import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:useme/core/models/session.dart';

/// Month calendar widget for artist sessions
class ArtistMonthCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime displayedMonth;
  final List<Session> sessions;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const ArtistMonthCalendar({
    super.key,
    required this.selectedDate,
    required this.displayedMonth,
    required this.sessions,
    required this.onDateSelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final monthFormat = DateFormat('MMMM yyyy', locale);

    return Column(
      children: [
        _buildHeader(colorScheme, monthFormat),
        const SizedBox(height: 12),
        _buildWeekdayHeaders(colorScheme, locale),
        const SizedBox(height: 8),
        _buildMonthGrid(colorScheme),
      ],
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, DateFormat monthFormat) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPreviousMonth,
            icon: Icon(Icons.chevron_left, color: colorScheme.onSurfaceVariant),
            style: IconButton.styleFrom(backgroundColor: colorScheme.surfaceContainerHighest),
          ),
          Text(
            monthFormat.format(displayedMonth).toUpperCase(),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, letterSpacing: 1),
          ),
          IconButton(
            onPressed: onNextMonth,
            icon: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            style: IconButton.styleFrom(backgroundColor: colorScheme.surfaceContainerHighest),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders(ColorScheme colorScheme, String locale) {
    final dayFormat = DateFormat('E', locale);
    // Start from Monday
    final days = List.generate(7, (i) => DateTime(2024, 1, i + 1)); // Jan 1, 2024 is Monday

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: days.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                dayFormat.format(day).substring(0, 2).toUpperCase(),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthGrid(ColorScheme colorScheme) {
    final firstDayOfMonth = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final lastDayOfMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 0);

    // Week starts on Monday (weekday 1)
    int startWeekday = firstDayOfMonth.weekday - 1; // 0 = Monday
    if (startWeekday < 0) startWeekday = 6;

    final daysInMonth = lastDayOfMonth.day;
    final totalCells = ((startWeekday + daysInMonth) / 7).ceil() * 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: totalCells,
        itemBuilder: (context, index) {
          final dayNumber = index - startWeekday + 1;

          if (dayNumber < 1 || dayNumber > daysInMonth) {
            return const SizedBox.shrink();
          }

          final date = DateTime(displayedMonth.year, displayedMonth.month, dayNumber);
          return _buildDayCell(colorScheme, date);
        },
      ),
    );
  }

  Widget _buildDayCell(ColorScheme colorScheme, DateTime date) {
    final isSelected = _isSameDay(date, selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    final sessionCount = _getSessionCountForDay(date);

    return GestureDetector(
      onTap: () => onDateSelected(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : (isToday ? colorScheme.primaryContainer.withValues(alpha: 0.5) : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? colorScheme.onPrimary
                    : (isToday ? colorScheme.primary : colorScheme.onSurface),
              ),
            ),
            if (sessionCount > 0)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  int _getSessionCountForDay(DateTime date) {
    return sessions.where((s) => _isSameDay(s.scheduledStart, date)).length;
  }
}
