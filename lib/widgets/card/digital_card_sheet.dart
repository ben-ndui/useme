import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:uzme/core/blocs/card_config/card_config_exports.dart';
import 'package:uzme/core/models/app_user.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/routing/app_routes.dart';
import 'package:uzme/core/services/card_stats_service.dart';
import 'package:uzme/core/services/nfc_share_service.dart';
import 'package:uzme/widgets/card/card_export_sheet.dart';
import 'package:uzme/widgets/card/holo_card.dart';
import 'package:uzme/widgets/card/qr_fullscreen_sheet.dart';

/// Glassmorphic bottom sheet displaying the holographic card.
/// Opens over the current screen with a dark blurred backdrop.
class DigitalCardSheet extends StatelessWidget {
  const DigitalCardSheet({super.key});

  static Future<void> show(BuildContext context) {
    // Capture refs eagerly before any async gap
    final authBloc = context.read<AuthBloc>();
    final cardConfigBloc = context.read<CardConfigBloc>();

    // Load card config when opening
    final authState = authBloc.state;
    if (authState is AuthAuthenticatedState) {
      cardConfigBloc.add(
        LoadCardConfigEvent(userId: authState.user.uid),
      );
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: authBloc),
            BlocProvider.value(value: cardConfigBloc),
          ],
          child: const DigitalCardSheet(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme
        .of(context)
        .colorScheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticatedState) return const SizedBox.shrink();
        final user = state.user as AppUser;

        return BlocBuilder<CardConfigBloc, CardConfigState>(
          builder: (context, cardState) {
            return ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(32)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: MediaQuery
                      .sizeOf(context)
                      .height * 0.58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        cs.surfaceContainerHigh,
                        cs.surface.withValues(alpha: 0.95),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32)),
                    border: Border(
                      top: BorderSide(
                        color: cs.outlineVariant,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          color: cs.outline,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        l10n.myCard,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),

                      // Card
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 24),
                            child: HoloCard(
                              user: user,
                              cardConfig: cardState.config,
                            ),
                          ),
                        ),
                      ),

                      // Stats
                      _CardStatsRow(userId: user.uid),
                      const SizedBox(height: 8),

                      // Actions
                      _buildActions(context, user, l10n, cs),
                      SizedBox(
                          height:
                          MediaQuery
                              .paddingOf(context)
                              .bottom + 16),
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

  Widget _buildActions(BuildContext context,
      AppUser user,
      AppLocalizations l10n,
      ColorScheme cs,) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: FontAwesomeIcons.qrcode,
            label: l10n.shareQr,
            onTap: () {
              Navigator.pop(context);
              QrFullscreenSheet.show(context, user);
            },
          ),
          _ActionButton(
            icon: FontAwesomeIcons.arrowUpFromBracket,
            label: l10n.exportCard,
            onTap: () {
              Navigator.pop(context);
              CardExportSheet.show(context);
            },
          ),
          _ActionButton(
            icon: FontAwesomeIcons.palette,
            label: l10n.customizeCard,
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.cardCustomize);
            },
          ),
          _ActionButton(
            icon: FontAwesomeIcons.camera,
            label: l10n.scan,
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.qrScanner);
            },
          ),
          _NfcButton(userId: user.uid),
        ],
      ),
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
    final cs = Theme
        .of(context)
        .colorScheme;

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

/// Compact stats row showing scan & view counts.
class _CardStatsRow extends StatelessWidget {
  final String userId;

  const _CardStatsRow({required this.userId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FutureBuilder<CardStats>(
      future: CardStatsService().load(userId),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? const CardStats();
        if (stats.scanCount == 0 && stats.viewCount == 0) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.qrcode,
                  size: 12, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                '${stats.scanCount}',
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 20),
              FaIcon(FontAwesomeIcons.eye,
                  size: 12, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                '${stats.viewCount}',
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// NFC action button — only visible if NFC is available on device.
class _NfcButton extends StatefulWidget {
  final String userId;

  const _NfcButton({required this.userId});

  @override
  State<_NfcButton> createState() => _NfcButtonState();
}

class _NfcButtonState extends State<_NfcButton> {
  bool? _nfcAvailable;

  @override
  void initState() {
    super.initState();
    NfcShareService().isAvailable().then((available) {
      if (mounted) setState(() => _nfcAvailable = available);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_nfcAvailable != true) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    return _ActionButton(
      icon: FontAwesomeIcons.nfcSymbol,
      label: l10n.nfc,
      onTap: () {
        Navigator.pop(context);
        NfcShareService().writeProfileUrl(
          userId: widget.userId,
          onSuccess: () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.nfcWritten)),
              );
            }
          },
          onError: (msg) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(msg)),
              );
            }
          },
        );
      },
    );
  }
}
