import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/notification_bell.dart';

/// Engineer dashboard header with greeting and avatar
class EngineerHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final String locale;

  const EngineerHeader({super.key, required this.l10n, required this.locale});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateFormat('EEEE d MMMM', locale).format(DateTime.now());

    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final userId = state is AuthAuthenticatedState ? state.user.uid : '';
              return NotificationBell(
                userId: userId,
                onTap: () => context.push('/notifications'),
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primaryContainer, colorScheme.surface],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  String userName = l10n.engineer;
                  String? photoURL;
                  if (authState is AuthAuthenticatedState) {
                    final user = authState.user as AppUser;
                    userName = user.displayName ?? user.name ?? l10n.engineer;
                    photoURL = user.photoURL;
                  }

                  return Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [colorScheme.primary, colorScheme.tertiary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: photoURL != null && photoURL.isNotEmpty
                            ? ClipOval(child: Image.network(photoURL, fit: BoxFit.cover))
                            : const Center(
                                child: FaIcon(FontAwesomeIcons.headphones, color: Colors.white, size: 22),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getGreeting(),
                              style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userName,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                FaIcon(FontAwesomeIcons.calendar, size: 12, color: colorScheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  today,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '${l10n.goodMorning} 👋';
    if (hour < 18) return '${l10n.goodAfternoon} 👋';
    return '${l10n.goodEvening} 👋';
  }
}
