import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:uzme/core/blocs/card_config/card_config_exports.dart';
import 'package:uzme/core/models/app_user.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/routing/app_routes.dart';
import 'package:uzme/widgets/card/card_export_sheet.dart';
import 'package:uzme/widgets/card/holo_card.dart';
import 'package:uzme/widgets/card/nearby_users_sheet.dart';
import 'package:uzme/widgets/card/qr_fullscreen_sheet.dart';
import 'package:uzme/widgets/common/app_loader.dart';

/// Screen displaying the user's holographic digital business card.
class DigitalCardScreen extends StatelessWidget {
  const DigitalCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticatedState) {
          return const AppLoader.fullScreen();
        }

        final user = state.user as AppUser;

        return BlocBuilder<CardConfigBloc, CardConfigState>(
          builder: (context, cardState) {
            return Scaffold(
              backgroundColor: cs.surface,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(l10n.myCard,
                    style: TextStyle(color: cs.onSurface)),
                iconTheme: IconThemeData(color: cs.onSurface),
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HoloCard(
                        user: user,
                        cardConfig: cardState.config,
                      ),
                      const SizedBox(height: 40),
                      _buildActions(context, user, l10n),
                      const SizedBox(height: 16),
                      Text(
                        l10n.tiltToExplore,
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActions(
      BuildContext context, AppUser user, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: FontAwesomeIcons.qrcode,
          label: l10n.shareQr,
          onTap: () => QrFullscreenSheet.show(context, user),
        ),
        const SizedBox(width: 20),
        _ActionButton(
          icon: FontAwesomeIcons.arrowUpFromBracket,
          label: l10n.exportCard,
          onTap: () => CardExportSheet.show(context),
        ),
        const SizedBox(width: 20),
        _ActionButton(
          icon: FontAwesomeIcons.palette,
          label: l10n.customizeCard,
          onTap: () => context.push(AppRoutes.cardCustomize),
        ),
        const SizedBox(width: 20),
        _ActionButton(
          icon: FontAwesomeIcons.camera,
          label: l10n.scan,
          onTap: () => context.push(AppRoutes.qrScanner),
        ),
        const SizedBox(width: 20),
        _ActionButton(
          icon: FontAwesomeIcons.locationDot,
          label: l10n.nearby,
          onTap: () => NearbyUsersSheet.show(context),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Center(
              child: FaIcon(icon, size: 20, color: cs.onSurface),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
