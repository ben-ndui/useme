import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/models/working_hours.dart';
import '../../core/services/availability_service.dart';
import '../../l10n/app_localizations.dart';

/// Widget pour sélectionner un créneau disponible chez un studio
class AvailabilityPicker extends StatefulWidget {
  final String studioId;
  final int durationMinutes;
  final DateTime? initialDate;
  final EnhancedTimeSlot? initialSlot;
  final void Function(DateTime date, EnhancedTimeSlot slot)? onSlotSelected;

  /// Horaires d'ouverture du studio (si null, utilise les heures par défaut 9h-22h)
  final WorkingHours? workingHours;

  const AvailabilityPicker({
    super.key,
    required this.studioId,
    this.durationMinutes = 60,
    this.initialDate,
    this.initialSlot,
    this.onSlotSelected,
    this.workingHours,
  });

  @override
  State<AvailabilityPicker> createState() => _AvailabilityPickerState();
}

class _AvailabilityPickerState extends State<AvailabilityPicker> {
  final _availabilityService = AvailabilityService();
  late DateTime _selectedDate;
  EnhancedTimeSlot? _selectedSlot;
  List<EnhancedTimeSlot> _slots = [];
  bool _isLoading = false;
  late AppLocalizations _l10n;
  late String _locale;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now().add(const Duration(days: 1));
    _selectedSlot = widget.initialSlot;
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final slots = await _availabilityService.getEnhancedSlots(
        studioId: widget.studioId,
        date: _selectedDate,
        slotDurationMinutes: widget.durationMinutes,
        workingHours: widget.workingHours,
      );
      setState(() {
        _slots = slots;
        _isLoading = false;
        if (_selectedSlot != null) {
          final stillAvailable = slots.any(
            (s) => s.start == _selectedSlot!.start && s.isAvailable && s.hasAvailableEngineer,
          );
          if (!stillAvailable) _selectedSlot = null;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _l10n = AppLocalizations.of(context)!;
    _locale = Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCalendar(theme),
        const SizedBox(height: 16),
        _buildLegend(theme),
        const SizedBox(height: 16),
        _buildSlotsSection(theme),
      ],
    );
  }

  Widget _buildCalendar(ThemeData theme) {
    return Card(
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 90)),
        focusedDay: _selectedDate,
        selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
        calendarFormat: CalendarFormat.twoWeeks,
        startingDayOfWeek: StartingDayOfWeek.monday,
        locale: _locale,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          weekendTextStyle: TextStyle(color: theme.colorScheme.error),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDate = selectedDay;
            _selectedSlot = null;
          });
          _loadSlots();
        },
      ),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem(theme, Colors.green, _l10n.available),
        _buildLegendItem(theme, Colors.orange, _l10n.limited),
        _buildLegendItem(theme, theme.colorScheme.outline, _l10n.unavailable),
      ],
    );
  }

  Widget _buildLegendItem(ThemeData theme, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildSlotsSection(ThemeData theme) {
    final dateFormat = DateFormat('EEEE d MMMM', _locale);
    final dateStr = dateFormat.format(_selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FaIcon(FontAwesomeIcons.clock, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              _l10n.slotsForDate(dateStr),
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
        else if (_slots.isEmpty)
          _buildEmptyState(theme)
        else
          _buildSlotsGrid(theme),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          FaIcon(FontAwesomeIcons.calendarXmark, size: 32, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(_l10n.noSlotAvailable, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            _l10n.tryAnotherDate,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsGrid(ThemeData theme) {
    // Grouper par niveau de disponibilité
    final fullyAvailable = _slots.where((s) => s.availabilityLevel == AvailabilityLevel.full).toList();
    final partiallyAvailable = _slots.where((s) =>
        s.availabilityLevel == AvailabilityLevel.partial ||
        s.availabilityLevel == AvailabilityLevel.limited).toList();
    final noEngineer = _slots.where((s) => s.availabilityLevel == AvailabilityLevel.noEngineer).toList();
    final unavailable = _slots.where((s) => s.availabilityLevel == AvailabilityLevel.unavailable).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fullyAvailable.isNotEmpty) ...[
          _buildSlotGroup(theme, _l10n.fullyAvailable, fullyAvailable, Colors.green),
        ],
        if (partiallyAvailable.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSlotGroup(theme, _l10n.partiallyAvailable, partiallyAvailable, Colors.orange),
        ],
        if (noEngineer.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSlotGroup(theme, _l10n.noEngineerAvailable, noEngineer, Colors.red),
        ],
        if (unavailable.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSlotGroup(theme, _l10n.studioUnavailable, unavailable, theme.colorScheme.outline),
        ],
        if (fullyAvailable.isEmpty && partiallyAvailable.isEmpty)
          _buildNoAvailableHint(theme),
      ],
    );
  }

  Widget _buildSlotGroup(ThemeData theme, String title, List<EnhancedTimeSlot> slots, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((slot) => _buildEnhancedSlotChip(theme, slot)).toList(),
        ),
      ],
    );
  }

  Widget _buildEnhancedSlotChip(ThemeData theme, EnhancedTimeSlot slot) {
    final isSelected = _selectedSlot?.start == slot.start;
    final timeFormat = DateFormat('HH:mm', _locale);
    final isSelectable = slot.isAvailable && slot.hasAvailableEngineer;

    // Couleur selon le niveau
    Color chipColor;
    switch (slot.availabilityLevel) {
      case AvailabilityLevel.full:
        chipColor = Colors.green;
        break;
      case AvailabilityLevel.partial:
      case AvailabilityLevel.limited:
        chipColor = Colors.orange;
        break;
      case AvailabilityLevel.noEngineer:
        chipColor = Colors.red;
        break;
      case AvailabilityLevel.unavailable:
        chipColor = theme.colorScheme.outline;
        break;
    }

    return InkWell(
      onTap: isSelectable ? () {
        setState(() => _selectedSlot = slot);
        widget.onSlotSelected?.call(_selectedDate, slot);
      } : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : chipColor.withValues(alpha: isSelectable ? 0.15 : 0.08),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : chipColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              FaIcon(FontAwesomeIcons.check, size: 10, color: theme.colorScheme.onPrimary),
              const SizedBox(width: 4),
            ],
            Text(
              '${timeFormat.format(slot.start)} - ${timeFormat.format(slot.end)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : isSelectable
                        ? chipColor.withValues(alpha: 1)
                        : theme.colorScheme.outline,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                decoration: !isSelectable ? TextDecoration.lineThrough : null,
              ),
            ),
            if (isSelectable && slot.availableCount > 0) ...[
              const SizedBox(width: 6),
              _buildEngineerBadge(theme, slot, isSelected),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEngineerBadge(ThemeData theme, EnhancedTimeSlot slot, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.onPrimary.withValues(alpha: 0.2)
            : theme.colorScheme.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.userGear,
            size: 9,
            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
          ),
          const SizedBox(width: 3),
          Text(
            '${slot.availableCount}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAvailableHint(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            FaIcon(FontAwesomeIcons.lightbulb, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _l10n.noEngineerTryAnotherDate,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
