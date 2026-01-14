import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:useme/config/useme_theme.dart';
import 'package:useme/core/blocs/map/map_bloc.dart';
import 'package:useme/core/blocs/map/map_event.dart';
import 'package:useme/core/blocs/map/map_state.dart';
import 'package:useme/core/models/discovered_studio.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/map/custom_studio_pin.dart';
import 'package:useme/widgets/map/search_in_zone_button.dart';

/// Google Maps view showing nearby studios with custom pins
class StudioMapView extends StatefulWidget {
  final Function(GoogleMapController)? onMapCreated;
  final Function(DiscoveredStudio)? onStudioTap;

  const StudioMapView({super.key, this.onMapCreated, this.onStudioTap});

  @override
  State<StudioMapView> createState() => _StudioMapViewState();
}

class _StudioMapViewState extends State<StudioMapView> {
  GoogleMapController? _mapController;
  bool _isControllerDisposed = false;
  LatLng? _currentCameraPosition;

  // Cached custom pins
  BitmapDescriptor? _partnerPin;
  BitmapDescriptor? _defaultPin;
  final Map<String, BitmapDescriptor> _studioPins = {};

  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(const InitMapEvent());
    _loadDefaultPins();
  }

  @override
  void dispose() {
    _isControllerDisposed = true;
    _mapController = null;
    super.dispose();
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

  void _safeAnimateCamera(LatLng location, double zoom) {
    if (_isControllerDisposed || _mapController == null || !mounted) return;
    try {
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, zoom));
    } catch (e) {
      // Controller was disposed, ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapBloc, MapState>(
      listenWhen: (previous, current) {
        if (!mounted || _isControllerDisposed) return false;
        // Listen when search completes (searchCenter changed and not searching)
        final searchCompleted = previous.isSearchingAddress && !current.isSearchingAddress;
        // Or when studios loaded
        final studiosLoaded = previous.isLoading && !current.isLoading;
        // Or when new studios are available
        final newStudios = previous.nearbyStudios.length != current.nearbyStudios.length;
        return searchCompleted || studiosLoaded || newStudios;
      },
      listener: (context, state) {
        // Avoid using controller after widget is disposed
        if (!mounted || _isControllerDisposed) return;

        // Animate to search center when a search completes
        if (_mapController != null && !state.isSearchingAddress) {
          _safeAnimateCamera(state.searchCenter, 13);
        }
        // Load custom pins for new studios
        if (mounted) _loadStudioPins(state.nearbyStudios);
      },
      builder: (context, state) {
        if (state.isLoading && state.nearbyStudios.isEmpty) {
          return _buildLoadingMap(state);
        }

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: state.userLocation,
                zoom: 14,
              ),
              markers: _buildMarkers(state),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
                widget.onMapCreated?.call(controller);
              },
              onCameraMove: (position) {
                _currentCameraPosition = position.target;
              },
              onCameraIdle: () {
                if (_currentCameraPosition != null) {
                  context.read<MapBloc>().add(
                        UpdateSearchCenterEvent(center: _currentCameraPosition!),
                      );
                }
              },
              onTap: (_) {
                context.read<MapBloc>().add(const DeselectStudioEvent());
              },
            ),
            // Search in zone button (centered below app bar)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 0,
              right: 0,
              child: Center(
                child: SearchInZoneButton(
                  center: _currentCameraPosition ?? state.searchCenter,
                ),
              ),
            ),
            // Refresh button
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              right: 16,
              child: _buildRefreshButton(context, state),
            ),
            // Location button
            Positioned(
              bottom: 180,
              right: 16,
              child: _buildLocationButton(context, state),
            ),
          ],
        );
      },
    );
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
            setState(() {
              _studioPins[studio.id] = pin;
            });
          }
        } catch (e) {
          // Use default pin
        }
      }
    }
  }

  Widget _buildLoadingMap(MapState state) {
    return Container(
      color: Colors.grey.shade200,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: state.userLocation,
              zoom: 14,
            ),
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              widget.onMapCreated?.call(controller);
            },
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(AppLocalizations.of(context)!.searchingStudios),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers(MapState state) {
    final markers = <Marker>{};

    for (final studio in state.filteredStudios) {
      // Get custom pin or fallback to cached default
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
          infoWindow: InfoWindow(
            title: studio.name,
            snippet: '${studio.formattedDistance}${studio.isPartner ? ' • ${AppLocalizations.of(context)!.partnerLabel}' : ''}',
          ),
          icon: icon,
          onTap: () {
            context.read<MapBloc>().add(SelectStudioEvent(studio: studio));
            widget.onStudioTap?.call(studio);
          },
        ),
      );
    }

    return markers;
  }

  Widget _buildRefreshButton(BuildContext context, MapState state) {
    return FloatingActionButton.small(
      heroTag: 'refresh',
      backgroundColor: Colors.white,
      onPressed: state.isLoading
          ? null
          : () => context.read<MapBloc>().add(const RefreshStudiosEvent()),
      child: state.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.refresh, color: UseMeTheme.primaryColor),
    );
  }

  Widget _buildLocationButton(BuildContext context, MapState state) {
    return FloatingActionButton.small(
      heroTag: 'location',
      backgroundColor: Colors.white,
      onPressed: () => _safeAnimateCamera(state.userLocation, 15),
      child: Icon(Icons.my_location, color: UseMeTheme.primaryColor),
    );
  }
}
