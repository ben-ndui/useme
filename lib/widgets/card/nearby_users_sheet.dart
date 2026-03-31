import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/card_config/card_config_exports.dart';
import 'package:useme/core/blocs/network/network_exports.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/card_config.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/card/holo_card.dart';
import 'package:useme/widgets/card/scanned_contact_sheet.dart';

/// Bottom sheet showing nearby UZME users with their HoloCards.
class NearbyUsersSheet extends StatefulWidget {
  const NearbyUsersSheet({super.key});

  static Future<void> show(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final networkBloc = context.read<NetworkBloc>();
    final cardConfigBloc = context.read<CardConfigBloc>();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: authBloc),
            BlocProvider.value(value: networkBloc),
            BlocProvider.value(value: cardConfigBloc),
          ],
          child: const NearbyUsersSheet(),
        );
      },
    );
  }

  @override
  State<NearbyUsersSheet> createState() => _NearbyUsersSheetState();
}

class _NearbyUsersSheetState extends State<NearbyUsersSheet> {
  List<_NearbyUser> _nearbyUsers = [];
  bool _isLoading = true;
  String? _error;

  static const double _radiusMeters = 10000; // 10 km

  @override
  void initState() {
    super.initState();
    _loadNearbyUsers();
  }

  Future<void> _loadNearbyUsers() async {
    // Capture bloc ref before async gap
    final authState = context.read<AuthBloc>().state;
    final currentUid = authState is AuthAuthenticatedState
        ? authState.user.uid
        : '';

    try {
      // Get current position
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          setState(() {
            _error = 'locationDenied';
            _isLoading = false;
          });
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Query users with location (pro profiles + studio profiles)
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get(const GetOptions(source: Source.serverAndCache));

      final results = <_NearbyUser>[];

      for (final doc in snapshot.docs) {
        if (doc.id == currentUid) continue;
        final data = doc.data();

        // Check pro profile location
        GeoPoint? location;
        if (data['proProfile'] is Map &&
            (data['proProfile'] as Map)['location'] != null) {
          final loc = (data['proProfile'] as Map)['location'];
          if (loc is GeoPoint) location = loc;
        }

        // Check studio profile location
        if (location == null &&
            data['studioProfile'] is Map &&
            (data['studioProfile'] as Map)['location'] != null) {
          final loc = (data['studioProfile'] as Map)['location'];
          if (loc is GeoPoint) location = loc;
        }

        if (location == null) continue;

        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          location.latitude,
          location.longitude,
        );

        if (distance > _radiusMeters) continue;

        final user = AppUser.fromMap(data, doc.id);
        final cardConfigData = data['cardConfig'];
        final cardConfig = cardConfigData is Map<String, dynamic>
            ? CardConfig.fromMap(cardConfigData)
            : const CardConfig();

        results.add(_NearbyUser(
          user: user,
          cardConfig: cardConfig,
          distanceMeters: distance,
        ));
      }

      // Sort by distance
      results.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

      if (mounted) {
        setState(() {
          _nearbyUsers = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.sizeOf(context).height * 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                cs.surfaceContainerHigh,
                cs.surface.withValues(alpha: 0.95),
              ],
            ),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(color: cs.outlineVariant, width: 1),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: cs.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.locationDot,
                      size: 14, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    l10n.nearbyUsers,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.nearbyRadius,
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // Content
              Expanded(child: _buildContent(l10n, cs)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, ColorScheme cs) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(FontAwesomeIcons.locationCrosshairs,
                  size: 40, color: cs.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                l10n.locationRequired,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_nearbyUsers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(FontAwesomeIcons.userGroup,
                  size: 40, color: cs.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                l10n.noNearbyUsers,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _nearbyUsers.length,
      itemBuilder: (context, index) {
        final nearby = _nearbyUsers[index];
        final distanceKm = (nearby.distanceMeters / 1000).toStringAsFixed(1);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
              ScannedContactSheet.show(context, nearby.user.uid);
            },
            child: Column(
              children: [
                HoloCard(
                    user: nearby.user, cardConfig: nearby.cardConfig),
                const SizedBox(height: 6),
                Text(
                  '$distanceKm km',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NearbyUser {
  final AppUser user;
  final CardConfig cardConfig;
  final double distanceMeters;

  const _NearbyUser({
    required this.user,
    required this.cardConfig,
    required this.distanceMeters,
  });
}
