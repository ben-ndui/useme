import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/pro/pro_carousel_card.dart';

/// Horizontal carousel showing available pros on the artist home feed.
class ProDiscoveryCarousel extends StatelessWidget {
  final Function(AppUser) onProTap;
  final bool isWideLayout;

  const ProDiscoveryCarousel({
    super.key,
    required this.onProTap,
    this.isWideLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ProProfileBloc, ProProfileState>(
      buildWhen: (prev, curr) =>
          prev.searchResults != curr.searchResults ||
          prev.isSearching != curr.isSearching,
      builder: (context, state) {
        if (state.isSearching && state.searchResults.isEmpty) {
          return const SizedBox.shrink();
        }

        if (state.searchResults.isEmpty) {
          return const SizedBox.shrink();
        }

        final padding = isWideLayout ? 24.0 : 16.0;
        final pros = state.searchResults.take(10).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, pros.length, l10n, padding),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: padding),
                itemCount: pros.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < pros.length - 1 ? 12 : 0,
                    ),
                    child: ProCarouselCard(
                      user: pros[index],
                      onTap: () => onProTap(pros[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    int count,
    AppLocalizations l10n,
    double padding,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const FaIcon(
              FontAwesomeIcons.briefcase,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.proDiscoveryTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  l10n.proDiscoverySubtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB0C4DE),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push(AppRoutes.proDiscovery),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.seeAll,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const FaIcon(
                    FontAwesomeIcons.arrowRight,
                    size: 10,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
