import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:useme/config/useme_theme.dart';
import 'package:useme/core/blocs/map/map_bloc.dart';
import 'package:useme/core/blocs/map/map_event.dart';
import 'package:useme/core/blocs/map/map_state.dart';
import 'package:useme/core/models/discovered_studio.dart';
import 'package:useme/widgets/auth/studio_preview_bottom_sheet.dart';
import 'package:useme/widgets/map/custom_studio_pin.dart';

/// Simplified map background for auth screens showing nearby studios
class AuthMapBackground extends StatefulWidget {
  const AuthMapBackground({super.key});

  @override
  State<AuthMapBackground> createState() => _AuthMapBackgroundState();
}

class _AuthMapBackgroundState extends State<AuthMapBackground> {
  GoogleMapController? _mapController;
  BitmapDescriptor? _partnerPin;
  BitmapDescriptor? _defaultPin;
  final Map<String, BitmapDescriptor> _studioPins = {};

  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(const InitMapEvent());
    _loadDefaultPins();
  }

  Future<void> _loadDefaultPins() async {
    _partnerPin = await CustomStudioPin.createPinWithImage(
      imageUrl: null,
      pinColor: Colors.green,
    );
    _defaultPin = await CustomStudioPin.createPinWithImage(
      imageUrl: null,
      pinColor: UseMeTheme.primaryColor,
    );
    if (mounted) setState(() {});
  }

  Future<void> _loadStudioPins(List<DiscoveredStudio> studios) async {
    for (final studio in studios) {
      if (!_studioPins.containsKey(studio.id) && studio.photoUrl != null) {
        try {
          final pin = await CustomStudioPin.createPinWithImage(
            imageUrl: studio.photoUrl,
            pinColor: studio.isPartner ? Colors.green : UseMeTheme.primaryColor,
          );
          if (mounted) {
            setState(() => _studioPins[studio.id] = pin);
          }
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapBloc, MapState>(
      listener: (context, state) {
        if (_mapController != null && !state.isLoading) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(state.userLocation, 13),
          );
        }
        _loadStudioPins(state.nearbyStudios);
      },
      builder: (context, state) {
        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: state.userLocation,
                zoom: 13,
              ),
              markers: _buildMarkers(context, state),
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              onMapCreated: (controller) => _mapController = controller,
            ),
            // Subtle overlay gradient to blend with form
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 150,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      UseMeTheme.primaryColor.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Set<Marker> _buildMarkers(BuildContext context, MapState state) {
    final markers = <Marker>{};

    for (final studio in state.nearbyStudios) {
      BitmapDescriptor icon;
      if (_studioPins.containsKey(studio.id)) {
        icon = _studioPins[studio.id]!;
      } else if (studio.isPartner && _partnerPin != null) {
        icon = _partnerPin!;
      } else if (_defaultPin != null) {
        icon = _defaultPin!;
      } else {
        icon = studio.isPartner
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      }

      markers.add(
        Marker(
          markerId: MarkerId(studio.id),
          position: studio.position,
          icon: icon,
          onTap: () => _showStudioPreview(context, studio),
        ),
      );
    }

    return markers;
  }

  void _showStudioPreview(BuildContext context, DiscoveredStudio studio) {
    StudioPreviewBottomSheet.show(context, studio);
  }
}
