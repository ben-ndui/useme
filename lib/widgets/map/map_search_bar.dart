import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uzme/core/blocs/map/map_bloc.dart';
import 'package:uzme/core/blocs/map/map_event.dart';
import 'package:uzme/core/blocs/map/map_state.dart';
import 'package:uzme/l10n/app_localizations.dart';

/// Floating glassmorphic search bar on the map for address/city search
class MapSearchBar extends StatefulWidget {
  const MapSearchBar({super.key});

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    context.read<MapBloc>().add(SearchByAddressEvent(address: query));
    _focusNode.unfocus();
    setState(() => _isExpanded = false);
  }

  void _collapse() {
    _controller.clear();
    _focusNode.unfocus();
    setState(() => _isExpanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Glass surface colors
    final bgColor = isDark
        ? cs.surfaceContainerHigh.withValues(alpha: 0.85)
        : cs.surface.withValues(alpha: 0.92);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : cs.outlineVariant;
    final iconColor = cs.onSurface.withValues(alpha: 0.7);

    return BlocListener<MapBloc, MapState>(
      listenWhen: (prev, curr) =>
          prev.isSearchingAddress && !curr.isSearchingAddress,
      listener: (context, state) {
        if (state.searchQuery != null) _collapse();
      },
      child: LayoutBuilder(
        builder: (context, outerConstraints) {
          final maxWidth = outerConstraints.maxWidth;
          return Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: _isExpanded ? maxWidth : 48,
              height: 48,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor, width: 0.8),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth <= 80) {
                          return _buildCollapsedButton(iconColor);
                        }
                        return _buildExpandedBar(l10n, cs, iconColor);
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCollapsedButton(Color iconColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _isExpanded = true);
          Future.delayed(
            const Duration(milliseconds: 300),
            () => _focusNode.requestFocus(),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Center(
          child: FaIcon(FontAwesomeIcons.magnifyingGlass,
              size: 17, color: iconColor),
        ),
      ),
    );
  }

  Widget _buildExpandedBar(
      AppLocalizations l10n, ColorScheme cs, Color iconColor) {
    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (prev, curr) =>
          prev.isSearchingAddress != curr.isSearchingAddress,
      builder: (context, state) {
        return Row(
          children: [
            const SizedBox(width: 14),
            if (state.isSearchingAddress)
              SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: cs.primary),
              )
            else
              FaIcon(FontAwesomeIcons.magnifyingGlass,
                  size: 15, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: TextStyle(fontSize: 15, color: cs.onSurface),
                decoration: InputDecoration(
                  filled: false,
                  hintText: l10n.searchAddressHint,
                  hintStyle: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.4),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
                  isDense: true,
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _submit(),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _collapse,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: FaIcon(FontAwesomeIcons.xmark,
                      size: 14, color: iconColor),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
