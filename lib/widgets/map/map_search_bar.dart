import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/config/useme_theme.dart';
import 'package:useme/core/blocs/map/map_bloc.dart';
import 'package:useme/core/blocs/map/map_event.dart';
import 'package:useme/core/blocs/map/map_state.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Floating search bar on the map for address/city search
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

    return BlocListener<MapBloc, MapState>(
      listenWhen: (prev, curr) =>
          prev.isSearchingAddress && !curr.isSearchingAddress,
      listener: (context, state) {
        if (state.searchQuery != null) _collapse();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: _isExpanded ? MediaQuery.of(context).size.width - 60 : 60,
        height: 60,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: UseMeTheme.primaryColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _isExpanded ? _buildExpandedBar(l10n) : _buildCollapsedButton(),
      ),
    );
  }

  Widget _buildCollapsedButton() {
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
        child: const Center(
          child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 18),
        ),
      ),
    );
  }

  Widget _buildExpandedBar(AppLocalizations l10n) {
    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (prev, curr) =>
          prev.isSearchingAddress != curr.isSearchingAddress,
      builder: (context, state) {
        return Row(
          children: [
            const SizedBox(width: 16),
            if (state.isSearchingAddress)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const FaIcon(FontAwesomeIcons.magnifyingGlass, size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: UseMeTheme.secondaryColor.withValues(alpha: 0.2),
                  hintText: l10n.searchAddressHint,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent)
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: FaIcon(FontAwesomeIcons.xmark, size: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
