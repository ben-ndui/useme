import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/card_config/card_config_exports.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/services/card_export_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/card/card_export_template.dart';

/// Bottom sheet for choosing an export format and sharing the card.
class CardExportSheet extends StatefulWidget {
  const CardExportSheet({super.key});

  /// Show the export sheet. Captures BLoC refs eagerly so the caller
  /// can safely `Navigator.pop` before invoking this.
  static Future<void> show(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final cardConfigBloc = context.read<CardConfigBloc>();

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
          child: const CardExportSheet(),
        );
      },
    );
  }

  @override
  State<CardExportSheet> createState() => _CardExportSheetState();
}

class _CardExportSheetState extends State<CardExportSheet> {
  CardExportFormat _selectedFormat = CardExportFormat.story;
  bool _isExporting = false;

  final _repaintKey = GlobalKey();
  final _exportService = CardExportService();

  Future<void> _export(AppUser user) async {
    setState(() => _isExporting = true);

    // Wait for the next frame so the RepaintBoundary is painted
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final boundary = _repaintKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;

    if (boundary == null) {
      setState(() => _isExporting = false);
      return;
    }

    final bytes = await _exportService.capture(boundary, _selectedFormat);
    if (bytes != null) {
      final name = user.stageName ?? user.displayName ?? 'UZME';
      await _exportService.share(
        bytes,
        text: '$name sur UZME 🎵 uzme.app/u/${user.uid}',
      );
    }

    if (mounted) setState(() => _isExporting = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticatedState) {
          return const SizedBox.shrink();
        }
        final user = authState.user as AppUser;
        final cardConfig =
            context.watch<CardConfigBloc>().state.config;

        return ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.75,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cs.surfaceContainerHigh,
                    cs.surface.withValues(alpha: 0.95),
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
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
                    l10n.exportCard,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Format selector
                  _buildFormatSelector(l10n, cs),
                  const SizedBox(height: 16),

                  // Preview
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: RepaintBoundary(
                          key: _repaintKey,
                          child: CardExportTemplate(
                            user: user,
                            cardConfig: cardConfig,
                            format: _selectedFormat,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Export button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isExporting ? null : () => _export(user),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.surfaceContainerHighest,
                          foregroundColor: cs.onSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: cs.outlineVariant),
                          ),
                          elevation: 0,
                        ),
                        icon: _isExporting
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.onSurface,
                                ),
                              )
                            : const FaIcon(FontAwesomeIcons.arrowUpFromBracket,
                                size: 16),
                        label: Text(
                          _isExporting ? l10n.exporting : l10n.shareImage,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.paddingOf(context).bottom + 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormatSelector(AppLocalizations l10n, ColorScheme cs) {
    final formats = [
      (CardExportFormat.story, FontAwesomeIcons.mobileScreen,
          l10n.formatStory),
      (CardExportFormat.post, FontAwesomeIcons.square,
          l10n.formatPost),
      (CardExportFormat.landscape, FontAwesomeIcons.display,
          l10n.formatLandscape),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: formats.map((item) {
          final (format, icon, label) = item;
          final isSelected = _selectedFormat == format;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFormat = format),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? cs.surfaceContainerHighest
                      : cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? cs.outline : cs.outlineVariant,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    FaIcon(icon,
                        size: 18,
                        color: isSelected
                            ? cs.onSurface
                            : cs.onSurfaceVariant),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? cs.onSurface
                            : cs.onSurfaceVariant,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${format.width}x${format.height}',
                      style: TextStyle(
                        fontSize: 9,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
