import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/services/studio_claim_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';
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
  String? _userId;
  AppUser? _currentUser;
  bool _initialized = false;

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
      context.read<CalendarBloc>().add(LoadCalendarStatusEvent(userId: _userId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          // Studio configuration
          StudioConfigSection(userId: _userId),
          const Divider(height: 32),

          // Visibility
          SettingsSectionHeader(title: l10n.visibility),
          StudioVisibilitySection(
            currentUser: _currentUser,
            onUnclaimRequested: () => _showUnclaimDialog(context, l10n),
            onClaimSuccess: _loadUserId,
          ),
          const Divider(height: 32),

          // Calendar & Availability
          _buildCalendarSection(l10n),
          const Divider(height: 32),

          // Application settings
          AppSettingsSection(userId: _userId),
          const Divider(height: 32),

          // Subscription
          const SettingsSectionHeader(title: 'Abonnement'),
          SubscriptionSection(
            user: _currentUser,
            showComingSoonOverlay: !(_currentUser?.isSuperAdmin == true ||
                _currentUser?.hasDevMasterAccess == true),
          ),
          const Divider(height: 32),

          // Account
          const AccountSettingsSection(),

          // Admin sections (SuperAdmin + DevMaster)
          AdminSettingsSection(currentUser: _currentUser),

          // Version
          const SizedBox(height: 32),
          Center(
            child: Text(
              l10n.version('1.0.0'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCalendarSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(title: l10n.calendar),
        if (_userId != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StudioWorkingHoursSection(userId: _userId!),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AllowNoEngineerToggle(userId: _userId!),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CalendarConnectionSection(userId: _userId!),
          ),
        ],
      ],
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
