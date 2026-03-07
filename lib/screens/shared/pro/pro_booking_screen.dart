import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/pro_profile.dart';
import 'package:useme/core/models/session.dart';
import 'package:useme/core/services/session_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Screen to book a pro's services.
class ProBookingScreen extends StatefulWidget {
  final AppUser proUser;

  const ProBookingScreen({super.key, required this.proUser});

  @override
  State<ProBookingScreen> createState() => _ProBookingScreenState();
}

class _ProBookingScreenState extends State<ProBookingScreen> {
  final _notesController = TextEditingController();
  final _sessionService = SessionService();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _durationHours = 2;
  bool _isRemote = false;
  bool _isSubmitting = false;

  ProProfile get _profile => widget.proUser.proProfile!;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.proBookingTitle(_profile.displayName)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProHeader(theme),
          const SizedBox(height: 24),
          _buildInfoCard(theme, l10n),
          const SizedBox(height: 24),
          _buildDatePicker(theme, l10n),
          const SizedBox(height: 24),
          _buildTimePicker(theme, l10n),
          const SizedBox(height: 24),
          _buildDurationSelector(theme, l10n),
          if (_profile.remote) ...[
            const SizedBox(height: 16),
            _buildRemoteSwitch(l10n),
          ],
          const SizedBox(height: 24),
          _buildNotesField(l10n),
          const SizedBox(height: 24),
          if (_selectedDate != null && _selectedTime != null)
            _buildSummary(theme, l10n),
          const SizedBox(height: 16),
          _buildSubmitButton(theme, l10n),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: theme.colorScheme.primaryContainer,
            image: widget.proUser.photoURL != null
                ? DecorationImage(
                    image: NetworkImage(widget.proUser.photoURL!),
                    fit: BoxFit.cover,
                    onError: (_, __) {},
                  )
                : null,
          ),
          child: Center(
            child: Text(
              _profile.displayName.isNotEmpty
                  ? _profile.displayName[0].toUpperCase()
                  : '?',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _profile.displayName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _profile.proTypesLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        if (_profile.hasRate)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _profile.formattedRate,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          FaIcon(FontAwesomeIcons.circleInfo,
              size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(l10n.proBookingDesc,
                style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(theme, l10n.proBookingDate),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.calendarDay,
                    size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? DateFormat.yMMMMEEEEd().format(_selectedDate!)
                      : l10n.proBookingSelectDate,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _selectedDate != null
                        ? null
                        : theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(theme, l10n.proBookingTime),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _pickTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.clock,
                    size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  _selectedTime != null
                      ? _selectedTime!.format(context)
                      : l10n.proBookingSelectTime,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _selectedTime != null
                        ? null
                        : theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelector(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(theme, l10n.proBookingDuration),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [1, 2, 3, 4, 6, 8].map((hours) {
            final isSelected = _durationHours == hours;
            return ChoiceChip(
              label: Text('${hours}h'),
              selected: isSelected,
              onSelected: (_) => setState(() => _durationHours = hours),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRemoteSwitch(AppLocalizations l10n) {
    return SwitchListTile.adaptive(
      title: Text(l10n.proBookingRemote),
      secondary: const FaIcon(FontAwesomeIcons.wifi, size: 18),
      value: _isRemote,
      onChanged: (v) => setState(() => _isRemote = v),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildNotesField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(Theme.of(context), l10n.proBookingNotes),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(hintText: l10n.proBookingNotesHint),
        ),
      ],
    );
  }

  Widget _buildSummary(ThemeData theme, AppLocalizations l10n) {
    final start = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    final end = start.add(Duration(hours: _durationHours));
    final dateFormat = DateFormat.yMMMd();
    final timeFormat = DateFormat.Hm();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.proBookingSummary,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _summaryRow(
            theme,
            FontAwesomeIcons.user,
            _profile.displayName,
          ),
          const SizedBox(height: 8),
          _summaryRow(
            theme,
            FontAwesomeIcons.calendarDay,
            dateFormat.format(start),
          ),
          const SizedBox(height: 8),
          _summaryRow(
            theme,
            FontAwesomeIcons.clock,
            '${timeFormat.format(start)} - ${timeFormat.format(end)} (${_durationHours}h)',
          ),
          if (_isRemote) ...[
            const SizedBox(height: 8),
            _summaryRow(theme, FontAwesomeIcons.wifi, l10n.proBookingRemote),
          ],
          if (_profile.hasRate) ...[
            const SizedBox(height: 8),
            _summaryRow(
              theme,
              FontAwesomeIcons.euroSign,
              '~${(_profile.hourlyRate! * _durationHours).toStringAsFixed(0)} ${_profile.currency}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        FaIcon(icon, size: 14, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Text(text, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildSubmitButton(ThemeData theme, AppLocalizations l10n) {
    final canSubmit =
        _selectedDate != null && _selectedTime != null && !_isSubmitting;

    return FilledButton(
      onPressed: canSubmit ? () => _submit(l10n) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(l10n.proBookingSend),
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _submit(AppLocalizations l10n) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;
    if (_selectedDate == null || _selectedTime == null) return;

    setState(() => _isSubmitting = true);

    try {
      final start = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      final end = start.add(Duration(hours: _durationHours));

      final session = Session(
        id: '',
        studioId: '',
        proId: widget.proUser.uid,
        proName: _profile.displayName,
        artistIds: [authState.user.uid],
        artistNames: [authState.user.name ?? 'Artist'],
        types: [SessionType.other],
        status: SessionStatus.pending,
        scheduledStart: start,
        scheduledEnd: end,
        durationMinutes: _durationHours * 60,
        notes: _notesController.text.isNotEmpty
            ? _notesController.text
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final response = await _sessionService.createSession(session);

      if (mounted) {
        if (response.code == 200) {
          AppSnackBar.success(context, l10n.proBookingSent);
          context.pop();
        } else {
          AppSnackBar.error(context, response.message);
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
