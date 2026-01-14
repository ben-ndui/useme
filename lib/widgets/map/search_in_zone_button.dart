import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:useme/config/useme_theme.dart';
import 'package:useme/core/blocs/map/map_bloc.dart';
import 'package:useme/core/blocs/map/map_event.dart';
import 'package:useme/core/blocs/map/map_state.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Button that appears when user moves the map, allowing search in new area
class SearchInZoneButton extends StatelessWidget {
  final LatLng center;

  const SearchInZoneButton({super.key, required this.center});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (prev, curr) =>
          prev.hasCameraMoved != curr.hasCameraMoved || prev.isLoading != curr.isLoading,
      builder: (context, state) {
        if (!state.hasCameraMoved || state.isLoading) {
          return const SizedBox.shrink();
        }

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: child,
          ),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(24),
            color: UseMeTheme.primaryColor,
            child: InkWell(
              onTap: () {
                context.read<MapBloc>().add(SearchInAreaEvent(center: center));
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.searchInThisZone,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
