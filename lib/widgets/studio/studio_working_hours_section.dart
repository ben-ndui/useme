import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';
import 'package:useme/widgets/engineer/working_hours_editor.dart';

/// Section pour gérer les horaires d'ouverture du studio
class StudioWorkingHoursSection extends StatefulWidget {
  final String userId;

  const StudioWorkingHoursSection({super.key, required this.userId});

  @override
  State<StudioWorkingHoursSection> createState() => _StudioWorkingHoursSectionState();
}

class _StudioWorkingHoursSectionState extends State<StudioWorkingHoursSection> {
  late WorkingHours _workingHours;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadWorkingHours();
  }

  void _loadWorkingHours() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      final user = authState.user;
      if (user is AppUser && user.studioProfile != null) {
        _workingHours = user.studioProfile!.workingHours ?? WorkingHours.defaultSchedule();
      } else {
        _workingHours = WorkingHours.defaultSchedule();
      }
    } else {
      _workingHours = WorkingHours.defaultSchedule();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.clock,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.openingHours,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        l10n.openingHoursSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_isEditing)
                  IconButton(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: FaIcon(
                      FontAwesomeIcons.penToSquare,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Content
            if (_isEditing) ...[
              WorkingHoursEditor(
                workingHours: _workingHours,
                onDayChanged: (weekday, schedule) {
                  setState(() {
                    _workingHours = _workingHours.copyWithDay(weekday, schedule);
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving
                        ? null
                        : () {
                            _loadWorkingHours();
                            setState(() => _isEditing = false);
                          },
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _saveWorkingHours,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const FaIcon(FontAwesomeIcons.check, size: 14),
                    label: Text(l10n.save),
                  ),
                ],
              ),
            ] else
              _buildSummary(theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(ThemeData theme, AppLocalizations l10n) {
    final enabledDays = <String>[];
    for (int i = 1; i <= 7; i++) {
      final schedule = _workingHours.getScheduleForDay(i);
      if (schedule.enabled) {
        enabledDays.add('${WorkingHours.getDayName(i).substring(0, 3)} ${schedule.start}-${schedule.end}');
      }
    }

    if (enabledDays.isEmpty) {
      return Text(
        l10n.noOpeningHoursConfigured,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.outline,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: enabledDays
          .map((day) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  day,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ))
          .toList(),
    );
  }

  Future<void> _saveWorkingHours() async {
    setState(() => _isSaving = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticatedState) return;

      final user = authState.user;
      if (user is! AppUser || user.studioProfile == null) return;

      // Mettre à jour le profil studio dans Firestore
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'studioProfile.workingHours': _workingHours.toMap(),
      });

      // Recharger l'utilisateur
      if (mounted) {
        context.read<AuthBloc>().add(const ReloadUserEvent());
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        AppSnackBar.success(context, AppLocalizations.of(context)!.openingHoursSaved);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppSnackBar.error(context, '${AppLocalizations.of(context)!.errorOccurred}: $e');
      }
    }
  }
}
