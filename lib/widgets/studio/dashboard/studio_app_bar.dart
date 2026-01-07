import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/common/notification_bell.dart';

/// Studio dashboard app bar with logo and studio info
class StudioAppBar extends StatelessWidget {
  final AppLocalizations l10n;
  final String locale;

  const StudioAppBar({super.key, required this.l10n, required this.locale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateFormat('EEEE d MMMM', locale).format(DateTime.now());

    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                String studioName = l10n.myStudio;
                String? photoUrl;

                if (authState is AuthAuthenticatedState) {
                  final user = authState.user as AppUser;
                  studioName = user.displayName ?? user.name ?? l10n.myStudio;
                  photoUrl = user.photoURL;
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        image: photoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(photoUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: photoUrl == null
                          ? Center(
                              child: FaIcon(
                                FontAwesomeIcons.recordVinyl,
                                size: 24,
                                color: theme.colorScheme.primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            studioName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            today,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    NotificationBell(
                      userId: authState is AuthAuthenticatedState
                          ? authState.user.uid
                          : '',
                      onTap: () => context.push(AppRoutes.notifications),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
