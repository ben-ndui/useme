import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/data/tips_data.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/services/studio_claim_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/screens/common/tips_screen.dart';
import 'package:useme/widgets/common/settings/settings_exports.dart';
import 'package:useme/widgets/studio/calendar_connection_section.dart';
import 'package:useme/widgets/studio/settings/studio_settings_exports.dart';
import 'package:useme/widgets/studio/studio_working_hours_section.dart';

/// Studio settings page
class StudioSettingsPage extends StatefulWidget {
  const StudioSettingsPage({super.key});

  @override
  State<StudioSettingsPage> createState() => _StudioSettingsPageState();
}

class _StudioSettingsPageState extends State<StudioSettingsPage> {
  late final CalendarBloc _calendarBloc;
  String? _userId;
  AppUser? _currentUser;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _calendarBloc = CalendarBloc();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadUserId();
    }
  }

  void _loadUserId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      setState(() {
        _userId = authState.user.uid;
        _currentUser = authState.user is AppUser ? authState.user as AppUser : null;
      });
      _calendarBloc.add(LoadCalendarStatusEvent(userId: _userId!));
    }
  }

  @override
  void dispose() {
    _calendarBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _calendarBloc,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.settings)),
        body: ListView(
          children: [
            // Studio section
            SettingsSectionHeader(title: l10n.studio),
            SettingsTile(
              icon: FontAwesomeIcons.buildingUser,
              title: l10n.studioProfile,
              subtitle: l10n.nameAddressContact,
              onTap: () => context.push(AppRoutes.profile),
            ),
            SettingsTile(
              icon: FontAwesomeIcons.tags,
              title: l10n.services,
              subtitle: l10n.serviceCatalog,
              onTap: () => context.push(AppRoutes.services),
            ),
            SettingsTile(
              icon: FontAwesomeIcons.doorOpen,
              title: l10n.rooms,
              subtitle: l10n.createRoomsHint,
              onTap: () => context.push(AppRoutes.rooms),
            ),
            SettingsTile(
              icon: FontAwesomeIcons.userTie,
              title: l10n.team,
              subtitle: l10n.manageEngineers,
              onTap: () => context.push(AppRoutes.teamManagement),
            ),
            SettingsTile(
              icon: FontAwesomeIcons.creditCard,
              title: l10n.paymentMethods,
              subtitle: l10n.paymentMethodsSubtitle,
              onTap: () => context.push(AppRoutes.paymentMethods),
            ),

            const Divider(height: 32),

            // Visibility section
            SettingsSectionHeader(title: l10n.visibility),
            StudioVisibilitySection(
              currentUser: _currentUser,
              onUnclaimRequested: () => _showUnclaimDialog(context, l10n),
              onClaimSuccess: _loadUserId,
            ),

            const Divider(height: 32),

            // Calendar & Availability section
            SettingsSectionHeader(title: l10n.calendar),
            if (_userId != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StudioWorkingHoursSection(userId: _userId!),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CalendarConnectionSection(userId: _userId!),
              ),
            ],

            const Divider(height: 32),

            // App section
            SettingsSectionHeader(title: l10n.application),
            SettingsNotificationTile(userId: _userId),
            const SettingsRememberEmailTile(),
            const SettingsThemeTile(),
            const SettingsLanguageTile(),
            SettingsTile(
              icon: FontAwesomeIcons.lightbulb,
              title: l10n.userGuide,
              subtitle: l10n.tipsAndAdvice,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TipsScreen(
                    title: l10n.studioGuide,
                    sections: TipsData.studioTips(l10n),
                  ),
                ),
              ),
            ),

            const Divider(height: 32),

            // Subscription section
            const SettingsSectionHeader(title: 'Abonnement'),
            SubscriptionSection(user: _currentUser),

            const Divider(height: 32),

            // Account section
            SettingsSectionHeader(title: l10n.account),
            SettingsTile(
              icon: FontAwesomeIcons.userGear,
              title: l10n.account,
              subtitle: l10n.emailPassword,
              onTap: () => context.push(AppRoutes.account),
            ),
            SettingsTile(
              icon: FontAwesomeIcons.circleInfo,
              title: l10n.about,
              subtitle: l10n.versionLegal,
              onTap: () => context.push(AppRoutes.about),
            ),
            const SettingsLogoutTile(),

            // Super Admin section (only visible to superAdmin)
            if (_currentUser?.isSuperAdmin == true) ...[
              const Divider(height: 32),
              const SettingsSectionHeader(title: 'Administration'),
              SettingsTile(
                icon: FontAwesomeIcons.buildingCircleCheck,
                title: l10n.studioClaims,
                subtitle: l10n.studioClaimsSubtitle,
                onTap: () => context.push(AppRoutes.studioClaims),
              ),
              SettingsTile(
                icon: FontAwesomeIcons.tags,
                title: 'Abonnements',
                subtitle: 'Configurer les tiers et limites',
                onTap: () => context.push('/admin/subscription-tiers'),
              ),
              SettingsTile(
                icon: FontAwesomeIcons.mobile,
                title: 'Screenshots Store',
                subtitle: 'Générer les captures App Store',
                onTap: () => context.push(AppRoutes.storeScreenshots),
              ),
            ],

            // DevMaster section (only visible to devMaster)
            if (_currentUser?.hasDevMasterAccess == true || _currentUser?.hasAdminRights == true) ...[
              const Divider(height: 32),
              const SettingsSectionHeader(title: 'DevMaster'),
              SettingsTile(
                icon: FontAwesomeIcons.stripe,
                title: 'Configuration Stripe',
                subtitle: 'Clés API et Price IDs',
                onTap: () => context.push('/admin/stripe-config'),
              ),
            ],

            const SizedBox(height: 32),

            // App version
            Center(
              child: Text(
                l10n.version('1.0.0'),
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showUnclaimDialog(BuildContext context, AppLocalizations l10n) {
    final studioName = _currentUser?.studioProfile?.name ?? '';
    final authBloc = context.read<AuthBloc>();
    final sessionBloc = context.read<SessionBloc>();
    final artistBloc = context.read<ArtistBloc>();
    final serviceBloc = context.read<ServiceBloc>();
    final router = GoRouter.of(context);
    final isSuperAdmin = _currentUser?.isSuperAdmin ?? false;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.unclaimStudioTitle),
        content: Text(l10n.unclaimStudioMessage(studioName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (_userId != null) {
                await StudioClaimService().unclaimStudio(_userId!);

                sessionBloc.add(const ClearSessionsEvent());
                artistBloc.add(const ClearArtistsEvent());
                serviceBloc.add(const ClearServicesEvent());

                authBloc.add(const ReloadUserEvent());

                if (isSuperAdmin) {
                  _loadUserId();
                } else {
                  router.go(AppRoutes.artistPortal);
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.unclaim),
          ),
        ],
      ),
    );
  }
}
