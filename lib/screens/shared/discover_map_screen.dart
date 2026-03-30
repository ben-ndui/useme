import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/blocs/map/map_bloc.dart';
import 'package:useme/core/blocs/map/map_event.dart';
import 'package:useme/core/blocs/map/map_state.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/map/map_dashboard_app_bar.dart';
import 'package:useme/widgets/map/map_filter_sheet.dart';
import 'package:useme/widgets/map/studio_detail_helper.dart';
import 'package:useme/widgets/map/studio_map_view.dart';

/// Shared map discovery screen for Studio and Engineer roles.
/// Allows them to explore nearby studios and pro profiles.
class DiscoverMapScreen extends StatelessWidget {
  const DiscoverMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapBloc(),
      child: const _DiscoverMapBody(),
    );
  }
}

class _DiscoverMapBody extends StatelessWidget {
  const _DiscoverMapBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocListener<MapBloc, MapState>(
      listenWhen: (prev, curr) =>
          prev.selectedStudio != curr.selectedStudio &&
          curr.selectedStudio != null,
      listener: (context, state) {
        openStudioOrProDetail(context, state.selectedStudio!);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(context, theme, l10n),
        body: const StudioMapView(),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: MapCircleButton(
        icon: FontAwesomeIcons.arrowLeft,
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.mapLocationDot, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(l10n.exploreStudiosTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
      centerTitle: true,
      actions: [
        BlocBuilder<MapBloc, MapState>(
          buildWhen: (prev, curr) =>
              prev.hasCameraMoved != curr.hasCameraMoved ||
              prev.isLoading != curr.isLoading ||
              prev.hasActiveFilters != curr.hasActiveFilters,
          builder: (context, state) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.hasCameraMoved && !state.isLoading)
                  MapCircleButton(
                    icon: FontAwesomeIcons.magnifyingGlassLocation,
                    onPressed: () => context.read<MapBloc>().add(
                          SearchInAreaEvent(center: state.searchCenter),
                        ),
                  ),
                MapCircleButton(
                  icon: FontAwesomeIcons.sliders,
                  badge: state.hasActiveFilters,
                  onPressed: () => MapFilterSheet.show(context),
                ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
