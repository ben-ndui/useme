import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/blocs/map/map_bloc.dart';
import 'package:useme/core/blocs/map/map_event.dart';
import 'package:useme/core/blocs/map/map_state.dart';
import 'package:useme/core/models/navigation/navigation_exports.dart';

/// Floating glassmorphism widget showing route info + travel mode picker.
/// Appears when directions are active on the map.
class FloatingNavWidget extends StatelessWidget {
  const FloatingNavWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (prev, curr) =>
          prev.directions != curr.directions ||
          prev.travelMode != curr.travelMode ||
          prev.isLoadingDirections != curr.isLoadingDirections,
      builder: (context, state) {
        if (!state.hasDirections && !state.isLoadingDirections) {
          return const SizedBox.shrink();
        }

        return _NavCard(
          directions: state.directions,
          travelMode: state.travelMode,
          isLoading: state.isLoadingDirections,
        );
      },
    );
  }
}

class _NavCard extends StatefulWidget {
  final DirectionsResult? directions;
  final TravelMode travelMode;
  final bool isLoading;

  const _NavCard({
    this.directions,
    required this.travelMode,
    required this.isLoading,
  });

  @override
  State<_NavCard> createState() => _NavCardState();
}

class _NavCardState extends State<_NavCard> {
  Offset _position = const Offset(16, 0);
  bool _initialized = false;

  DirectionsResult? get directions => widget.directions;
  TravelMode get travelMode => widget.travelMode;
  bool get isLoading => widget.isLoading;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final screenHeight = MediaQuery.of(context).size.height;
      _position = Offset(16, screenHeight - 300);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
        },
        child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outlineVariant
                    .withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, theme),
                if (directions != null) ...[
                  const SizedBox(height: 8),
                  _buildInfo(theme),
                ],
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                _buildTravelModes(context, theme),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        FaIcon(
          FontAwesomeIcons.route,
          size: 14,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Itinéraire',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => context.read<MapBloc>().add(
                const ClearDirectionsEvent(),
              ),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FaIcon(
              FontAwesomeIcons.xmark,
              size: 12,
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FaIcon(
              FontAwesomeIcons.locationArrow,
              size: 12,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              directions!.distance,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            FaIcon(
              FontAwesomeIcons.clock,
              size: 12,
              color: Colors.amber,
            ),
            const SizedBox(width: 6),
            Text(
              directions!.duration,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTravelModes(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _modeButton(
          context,
          theme,
          icon: FontAwesomeIcons.personWalking,
          mode: TravelMode.walking,
        ),
        _modeButton(
          context,
          theme,
          icon: FontAwesomeIcons.bicycle,
          mode: TravelMode.bicycling,
        ),
        _modeButton(
          context,
          theme,
          icon: FontAwesomeIcons.car,
          mode: TravelMode.driving,
        ),
        _modeButton(
          context,
          theme,
          icon: FontAwesomeIcons.trainSubway,
          mode: TravelMode.transit,
        ),
      ],
    );
  }

  Widget _modeButton(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required TravelMode mode,
  }) {
    final isActive = travelMode == mode;
    return GestureDetector(
      onTap: () => context.read<MapBloc>().add(
            ChangeTravelModeEvent(travelMode: mode.apiValue),
          ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: FaIcon(
          icon,
          size: 16,
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
