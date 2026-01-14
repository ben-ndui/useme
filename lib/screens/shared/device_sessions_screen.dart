import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/app_loader.dart';

/// Device sessions screen with localization.
class LocalDeviceSessionsScreen extends StatelessWidget {
  const LocalDeviceSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticatedState) {
          return const Scaffold(body: AppLoader.compact());
        }

        final userId = state.user.uid;
        final service = BaseDeviceSessionService();

        return DeviceSessionsScreen(
          userId: userId,
          service: service,
          strings: DeviceSessionsScreenStrings(
            title: l10n.connectedDevices,
            disconnectAllOthers: l10n.disconnectAllOthers,
            disconnectConfirmTitle: l10n.disconnectDeviceTitle,
            disconnectConfirmMessage: l10n.disconnectDeviceConfirm,
            disconnectAllConfirmMessage: l10n.disconnectAllConfirm,
            cancel: l10n.cancel,
            confirm: l10n.confirm,
            deviceDisconnected: l10n.deviceDisconnected,
            allDevicesDisconnected: l10n.allDevicesDisconnected,
            noDevices: l10n.noConnectedDevices,
            tileStrings: DeviceSessionTileStrings(
              thisDevice: l10n.thisDevice,
              activeNow: l10n.activeNow,
              activeAgo: (time) => l10n.activeAgo(time),
              disconnect: l10n.disconnectDevice,
            ),
          ),
          loadingBuilder: (context, isLoading) => const AppLoader.compact(),
        );
      },
    );
  }
}
