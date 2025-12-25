import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/engineer/dashboard/engineer_dashboard_exports.dart';

/// Engineer dashboard - Clean dashboard with today's sessions
class EngineerDashboardPage extends StatelessWidget {
  const EngineerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticatedState) {
            context.read<SessionBloc>().add(
              LoadEngineerSessionsEvent(engineerId: authState.user.uid),
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            EngineerHeader(l10n: l10n, locale: locale),
            SliverToBoxAdapter(child: EngineerStatsRow(l10n: l10n)),
            EngineerProposedSection(l10n: l10n, locale: locale),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: _buildSectionTitle(context, l10n),
              ),
            ),
            EngineerSessionsList(l10n: l10n, locale: locale),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.todaySessions,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        ),
        BlocBuilder<SessionBloc, SessionState>(
          builder: (context, state) {
            final count = _getTodaySessions(state.sessions).length;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.primary),
              ),
            );
          },
        ),
      ],
    );
  }

  List<Session> _getTodaySessions(List<Session> sessions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return sessions.where((s) {
      final start = s.scheduledStart;
      return start.isAfter(today.subtract(const Duration(seconds: 1))) && start.isBefore(tomorrow);
    }).toList()
      ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));
  }
}
