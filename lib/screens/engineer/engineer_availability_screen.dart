import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/services/services_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/app_loader.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';
import 'package:useme/widgets/engineer/add_time_off_bottom_sheet.dart';
import 'package:useme/widgets/engineer/time_off_card.dart';
import 'package:useme/widgets/engineer/working_hours_editor.dart';

/// Écran de gestion des disponibilités de l'ingénieur
class EngineerAvailabilityScreen extends StatelessWidget {
  const EngineerAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) {
      return Scaffold(body: Center(child: Text(l10n.notConnected)));
    }

    final engineerId = authState.user.uid;

    return BlocProvider(
      create: (_) => EngineerAvailabilityBloc(
        service: EngineerAvailabilityService(),
      )..add(LoadEngineerAvailabilityEvent(engineerId: engineerId)),
      child: _AvailabilityContent(engineerId: engineerId),
    );
  }
}

class _AvailabilityContent extends StatelessWidget {
  final String engineerId;

  const _AvailabilityContent({required this.engineerId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myAvailabilities),
        centerTitle: true,
      ),
      body: BlocConsumer<EngineerAvailabilityBloc, EngineerAvailabilityState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            AppSnackBar.success(context, state.successMessage!);
          }
          if (state.errorMessage != null) {
            AppSnackBar.error(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.workingHours == null) {
            return const AppLoader();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Working Hours Section
              _buildSectionHeader(
                context,
                icon: FontAwesomeIcons.clock,
                title: l10n.workingHours,
              ),
              const SizedBox(height: 12),

              if (state.workingHours != null)
                WorkingHoursEditor(
                  workingHours: state.workingHours!,
                  onDayChanged: (weekday, schedule) {
                    context.read<EngineerAvailabilityBloc>().add(
                      UpdateDayScheduleEvent(
                        engineerId: engineerId,
                        weekday: weekday,
                        schedule: schedule,
                      ),
                    );
                  },
                ),

              const SizedBox(height: 32),

              // Time Offs Section
              _buildSectionHeader(
                context,
                icon: FontAwesomeIcons.calendarXmark,
                title: l10n.unavailabilities,
                trailing: TextButton.icon(
                  onPressed: () => _addTimeOff(context),
                  icon: const FaIcon(FontAwesomeIcons.plus, size: 14),
                  label: Text(l10n.add),
                ),
              ),
              const SizedBox(height: 12),

              if (state.timeOffs.isEmpty)
                _buildEmptyTimeOffs(context, l10n)
              else
                ...state.timeOffs.map((timeOff) => TimeOffCard(
                  timeOff: timeOff,
                  onDelete: () {
                    context.read<EngineerAvailabilityBloc>().add(
                      DeleteTimeOffEvent(timeOffId: timeOff.id),
                    );
                  },
                )),

              // Spacer for floating nav
              SizedBox(height: MediaQuery.of(context).padding.bottom + 100),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: FaIcon(icon, size: 14, color: theme.colorScheme.primary),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildEmptyTimeOffs(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          FaIcon(
            FontAwesomeIcons.calendarCheck,
            size: 40,
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noTimeOff,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addTimeOffHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _addTimeOff(BuildContext context) async {
    final timeOff = await AddTimeOffBottomSheet.show(context, engineerId);

    if (timeOff != null && context.mounted) {
      context.read<EngineerAvailabilityBloc>().add(
        AddTimeOffEvent(timeOff: timeOff),
      );
    }
  }
}
