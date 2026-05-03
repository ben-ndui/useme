import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uzme/config/responsive_config.dart';
import 'package:uzme/core/blocs/blocs_exports.dart';
import 'package:uzme/widgets/common/app_loader.dart';
import 'package:uzme/widgets/common/glass/glass_exports.dart';
import 'package:uzme/core/models/pro_profile.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/widgets/pro/pro_card.dart';
import 'package:uzme/widgets/pro/pro_detail_bottom_sheet.dart';
import 'package:uzme/widgets/pro/pro_filter_sheet.dart';

/// Screen to discover and search for professionals.
class ProDiscoveryScreen extends StatefulWidget {
  const ProDiscoveryScreen({super.key});

  @override
  State<ProDiscoveryScreen> createState() => _ProDiscoveryScreenState();
}

class _ProDiscoveryScreenState extends State<ProDiscoveryScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  List<ProType> _filterTypes = [];
  String? _filterCity;
  bool _filterRemoteOnly = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) => _search());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _search);
  }

  void _search() {
    context.read<ProProfileBloc>().add(SearchProsEvent(
          types: _filterTypes.isNotEmpty ? _filterTypes : null,
          city: _filterCity,
          remoteOnly: _filterRemoteOnly,
          textQuery: _searchController.text.trim().isNotEmpty
              ? _searchController.text.trim()
              : null,
        ));
  }

  void _onFilterApplied(ProFilterParams params) {
    setState(() {
      _filterTypes = params.types;
      _filterCity = params.city;
      _filterRemoteOnly = params.remoteOnly;
    });
    _search();
  }

  bool get _hasActiveFilters =>
      _filterTypes.isNotEmpty || _filterCity != null || _filterRemoteOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.proDiscoveryTitle),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.sliders, size: 18),
                onPressed: () => ProFilterSheet.show(
                  context,
                  selectedTypes: _filterTypes,
                  city: _filterCity,
                  remoteOnly: _filterRemoteOnly,
                  onApply: _onFilterApplied,
                ),
              ),
              if (_hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth),
          child: Column(
            children: [
              _buildSearchBar(theme, l10n),
              if (_hasActiveFilters) _buildActiveFilters(theme, l10n),
              Expanded(child: _buildResults(theme, l10n)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: l10n.proSearchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    _search();
                  },
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildActiveFilters(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ..._filterTypes.map((type) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Chip(
                    label: Text(type.label, style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() => _filterTypes.remove(type));
                      _search();
                    },
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )),
            if (_filterCity != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Chip(
                  avatar: const Icon(Icons.location_city, size: 14),
                  label: Text(_filterCity!, style: const TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setState(() => _filterCity = null);
                    _search();
                  },
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            if (_filterRemoteOnly)
              Chip(
                avatar: const FaIcon(FontAwesomeIcons.wifi, size: 12),
                label: Text(l10n.remote, style: const TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() => _filterRemoteOnly = false);
                  _search();
                },
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(ThemeData theme, AppLocalizations l10n) {
    return BlocBuilder<ProProfileBloc, ProProfileState>(
      buildWhen: (prev, curr) =>
          prev.searchResults != curr.searchResults ||
          prev.isSearching != curr.isSearching,
      builder: (context, state) {
        if (state.isSearching) {
          return const Center(child: AppLoader());
        }

        final results = state.searchResults;

        if (results.isEmpty) {
          return GlassEmptyState(
            icon: FontAwesomeIcons.userSlash,
            title: l10n.proDiscoveryEmpty,
            subtitle: l10n.proDiscoveryEmptyDesc,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                l10n.proResultCount(results.length),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final user = results[index];
                  return ProCard(
                    user: user,
                    onTap: () => ProDetailBottomSheet.show(context, user),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
