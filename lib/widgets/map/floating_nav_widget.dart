import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/blocs/map/map_bloc.dart';
import 'package:useme/core/blocs/map/map_event.dart';
import 'package:useme/core/blocs/map/map_state.dart';
import 'package:useme/core/models/navigation/navigation_exports.dart';

/// Floating glassmorphism widget showing route info + travel mode picker.
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
        return _DraggableNavCard(
          directions: state.directions,
          travelMode: state.travelMode,
          isLoading: state.isLoadingDirections,
        );
      },
    );
  }
}

class _DraggableNavCard extends StatefulWidget {
  final DirectionsResult? directions;
  final TravelMode travelMode;
  final bool isLoading;

  const _DraggableNavCard({
    this.directions,
    required this.travelMode,
    required this.isLoading,
  });

  @override
  State<_DraggableNavCard> createState() => _DraggableNavCardState();
}

class _DraggableNavCardState extends State<_DraggableNavCard> {
  Offset _position = const Offset(16, 0);
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final h = MediaQuery.of(context).size.height;
      _position = Offset(16, h - 320);
      _initialized = true;
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() => _position += details.delta);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: 190,
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
                  // Drag handle
                  Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  _Header(theme: theme),
                  if (widget.directions != null) ...[
                    const SizedBox(height: 8),
                    _Info(
                      directions: widget.directions!,
                      theme: theme,
                    ),
                  ],
                  if (widget.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  _TravelModes(
                    current: widget.travelMode,
                    theme: theme,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ThemeData theme;

  const _Header({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FaIcon(FontAwesomeIcons.route,
            size: 14, color: theme.colorScheme.primary),
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
        InkWell(
          onTap: () =>
              context.read<MapBloc>().add(const ClearDirectionsEvent()),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FaIcon(FontAwesomeIcons.xmark,
                size: 12, color: theme.colorScheme.error),
          ),
        ),
      ],
    );
  }
}

class _Info extends StatelessWidget {
  final DirectionsResult directions;
  final ThemeData theme;

  const _Info({required this.directions, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FaIcon(FontAwesomeIcons.locationArrow,
                size: 12, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              directions.distance,
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
            const FaIcon(FontAwesomeIcons.clock,
                size: 12, color: Colors.amber),
            const SizedBox(width: 6),
            Text(
              directions.duration,
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
}

class _TravelModes extends StatelessWidget {
  final TravelMode current;
  final ThemeData theme;

  const _TravelModes({required this.current, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: TravelMode.values.map((mode) {
        final isActive = current == mode;
        return InkWell(
          onTap: () => context.read<MapBloc>().add(
                ChangeTravelModeEvent(travelMode: mode.apiValue),
              ),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(
              _iconFor(mode),
              size: 16,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _iconFor(TravelMode mode) {
    switch (mode) {
      case TravelMode.walking:
        return FontAwesomeIcons.personWalking;
      case TravelMode.bicycling:
        return FontAwesomeIcons.bicycle;
      case TravelMode.driving:
        return FontAwesomeIcons.car;
      case TravelMode.transit:
        return FontAwesomeIcons.trainSubway;
    }
  }
}
