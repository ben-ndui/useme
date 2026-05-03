import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:uzme/config/useme_theme.dart';
import 'package:uzme/core/blocs/map/map_bloc.dart';
import 'package:uzme/core/blocs/map/map_event.dart';
import 'package:uzme/core/blocs/map/map_state.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/widgets/map/map_filter_sheet.dart';

/// Shared transparent AppBar for map-based dashboard pages.
/// Used by Artist, Studio, and Engineer dashboards.
AppBar buildMapDashboardAppBar({
  required BuildContext context,
  required IconData titleIcon,
}) {
  final theme = Theme.of(context);
  final l10n = AppLocalizations.of(context)!;

  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    automaticallyImplyLeading: false,
    title: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(titleIcon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(l10n.appName,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
      MapCircleButton(
        icon: FontAwesomeIcons.bell,
        onPressed: () => context.push('/notifications'),
      ),
      const SizedBox(width: 8),
    ],
  );
}

/// Circle button with optional badge dot for map AppBars.
class MapCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool badge;

  const MapCircleButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Stack(
        children: [
          IconButton(
            icon: FaIcon(icon, size: 18),
            onPressed: onPressed,
          ),
          if (badge)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: UseMeTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
