import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/models_exports.dart';

/// Éditeur d'horaires de travail hebdomadaires
class WorkingHoursEditor extends StatelessWidget {
  final WorkingHours workingHours;
  final Function(int weekday, DaySchedule schedule) onDayChanged;

  const WorkingHoursEditor({
    super.key,
    required this.workingHours,
    required this.onDayChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(7, (index) {
        final weekday = index + 1;
        final schedule = workingHours.getScheduleForDay(weekday);
        final dayName = WorkingHours.getDayName(weekday);

        return _DayScheduleRow(
          dayName: dayName,
          schedule: schedule,
          onChanged: (newSchedule) => onDayChanged(weekday, newSchedule),
        );
      }),
    );
  }
}

class _DayScheduleRow extends StatelessWidget {
  final String dayName;
  final DaySchedule schedule;
  final Function(DaySchedule) onChanged;

  const _DayScheduleRow({
    required this.dayName,
    required this.schedule,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Toggle enabled
          Switch.adaptive(
            value: schedule.enabled,
            onChanged: (enabled) {
              onChanged(schedule.copyWith(enabled: enabled));
            },
          ),

          // Day name
          SizedBox(
            width: 80,
            child: Text(
              dayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: schedule.enabled ? null : theme.colorScheme.outline,
              ),
            ),
          ),

          const Spacer(),

          // Hours or "Repos"
          if (schedule.enabled) ...[
            _TimeButton(
              time: schedule.start,
              onTap: () => _pickTime(context, schedule.start, (time) {
                onChanged(schedule.copyWith(start: time));
              }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FaIcon(
                FontAwesomeIcons.arrowRight,
                size: 12,
                color: theme.colorScheme.outline,
              ),
            ),
            _TimeButton(
              time: schedule.end,
              onTap: () => _pickTime(context, schedule.end, (time) {
                onChanged(schedule.copyWith(end: time));
              }),
            ),
          ] else
            Text(
              'Repos',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    String currentTime,
    Function(String) onPicked,
  ) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onPicked(formattedTime);
    }
  }
}

class _TimeButton extends StatelessWidget {
  final String time;
  final VoidCallback onTap;

  const _TimeButton({required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          time,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
