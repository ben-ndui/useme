import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/engineer/dashboard/engineer_proposed_tile.dart';

/// Proposed sessions section for engineer dashboard
class EngineerProposedSection extends StatelessWidget {
  final AppLocalizations l10n;
  final String locale;

  const EngineerProposedSection({super.key, required this.l10n, required this.locale});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticatedState) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        final engineerId = authState.user.uid;

        return BlocBuilder<SessionBloc, SessionState>(
          builder: (context, state) {
            final proposedSessions = state.sessions.where((s) {
              return s.isEngineerProposed(engineerId) && !s.isEngineerAssigned(engineerId);
            }).toList();

            if (proposedSessions.isEmpty) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }

            return SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: _buildProposedHeader(proposedSessions.length),
                  ),
                  ...proposedSessions.map((s) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: EngineerProposedTile(
                      session: s,
                      engineerId: engineerId,
                      engineer: authState.user as AppUser,
                      locale: locale,
                    ),
                  )),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProposedHeader(int count) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const FaIcon(FontAwesomeIcons.bell, size: 12, color: Colors.purple),
              const SizedBox(width: 8),
              Text(
                l10n.proposedSessions,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.purple),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.purple),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
