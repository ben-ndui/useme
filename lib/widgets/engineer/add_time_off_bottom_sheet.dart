import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Bottom sheet pour ajouter une indisponibilité
class AddTimeOffBottomSheet extends StatefulWidget {
  final String engineerId;

  const AddTimeOffBottomSheet({super.key, required this.engineerId});

  @override
  State<AddTimeOffBottomSheet> createState() => _AddTimeOffBottomSheetState();

  static Future<TimeOff?> show(BuildContext context, String engineerId) {
    return showModalBottomSheet<TimeOff>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddTimeOffBottomSheet(engineerId: engineerId),
    );
  }
}

class _AddTimeOffBottomSheetState extends State<AddTimeOffBottomSheet> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String? _selectedReason;
  final _customReasonController = TextEditingController();

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat('EEE d MMMM yyyy', locale);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              l10n.addTimeOff,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // Date start
            _buildDateRow(
              context,
              label: l10n.fromDate,
              date: _startDate,
              format: dateFormat,
              onTap: () => _pickDate(context, locale, _startDate, (date) {
                setState(() {
                  _startDate = date;
                  if (_endDate.isBefore(_startDate)) {
                    _endDate = _startDate;
                  }
                });
              }),
            ),

            const SizedBox(height: 12),

            // Date end
            _buildDateRow(
              context,
              label: l10n.toDate,
              date: _endDate,
              format: dateFormat,
              onTap: () => _pickDate(context, locale, _endDate, (date) {
                setState(() => _endDate = date);
              }, firstDate: _startDate),
            ),

            const SizedBox(height: 24),

            // Reason suggestions
            Text(
              l10n.reasonOptional,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TimeOff.commonReasons.map((reason) {
                final isSelected = _selectedReason == reason;
                return FilterChip(
                  label: Text(reason),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedReason = selected ? reason : null;
                      if (selected) _customReasonController.clear();
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Custom reason
            TextField(
              controller: _customReasonController,
              decoration: InputDecoration(
                hintText: l10n.enterCustomReason,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() => _selectedReason = null);
                }
              },
            ),

            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
                label: Text(l10n.add),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(
    BuildContext context, {
    required String label,
    required DateTime date,
    required DateFormat format,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.calendarDay,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const Spacer(),
            Text(
              format.format(date),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            FaIcon(
              FontAwesomeIcons.chevronDown,
              size: 12,
              color: theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    String locale,
    DateTime initialDate,
    Function(DateTime) onPicked, {
    DateTime? firstDate,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      locale: Locale(locale),
    );

    if (picked != null) {
      onPicked(picked);
    }
  }

  void _submit() {
    final reason = _customReasonController.text.isNotEmpty
        ? _customReasonController.text
        : _selectedReason;

    // Ajuster les dates pour couvrir toute la journée
    final startOfDay = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
    );
    final endOfDay = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      23,
      59,
      59,
    );

    final timeOff = TimeOff(
      id: '',
      engineerId: widget.engineerId,
      start: startOfDay,
      end: endOfDay,
      reason: reason,
      createdAt: DateTime.now(),
    );

    Navigator.pop(context, timeOff);
  }
}
