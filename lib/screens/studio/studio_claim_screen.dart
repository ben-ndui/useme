import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/discovered_studio.dart';
import 'package:useme/core/models/studio_profile.dart';
import 'package:useme/core/services/location_service.dart';
import 'package:useme/core/services/studio_claim_service.dart';
import 'package:useme/core/services/studio_claim_approval_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/common/app_loader.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Écran pour revendiquer son studio (lier un Google Place à son compte)
class StudioClaimScreen extends StatefulWidget {
  const StudioClaimScreen({super.key});

  @override
  State<StudioClaimScreen> createState() => _StudioClaimScreenState();
}

class _StudioClaimScreenState extends State<StudioClaimScreen> {
  final StudioClaimService _claimService = StudioClaimService();
  final StudioClaimApprovalService _approvalService = StudioClaimApprovalService();
  final LocationService _locationService = LocationService();

  List<DiscoveredStudio> _studios = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNearbyStudios();
  }

  Future<void> _loadNearbyStudios() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final position = await _locationService.getCurrentLatLng();
      final studios = await _claimService.searchStudiosForClaim(
        position: position,
        radius: 15000, // 15km
      );
      setState(() {
        _studios = studios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de la recherche: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.claimStudioTitle),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 18),
            onPressed: _loadNearbyStudios,
          ),
        ],
      ),
      body: _buildBody(theme, l10n),
    );
  }

  Widget _buildBody(ThemeData theme, AppLocalizations l10n) {
    if (_isLoading) {
      return const AppLoader();
    }

    if (_error != null) {
      return _buildErrorState(theme, l10n);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        _buildInfoCard(theme, l10n),
        const SizedBox(height: 24),

        // Studios list
        Text(
          l10n.nearbyStudios,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.selectStudioToClaim,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 16),

        if (_studios.isEmpty)
          _buildEmptyState(theme, l10n)
        else
          ..._studios.map((studio) => _buildStudioTile(theme, studio, l10n)),

        const SizedBox(height: 24),

        // Manual creation
        _buildManualCreationCard(theme, l10n),
      ],
    );
  }

  Widget _buildInfoCard(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.buildingUser,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.claimYourStudio,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.claimStudioDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.circleExclamation,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadNearbyStudios,
              icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 14),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          FaIcon(
            FontAwesomeIcons.mapLocationDot,
            size: 32,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noStudioFoundNearby,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.createStudioManuallyBelow,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudioTile(ThemeData theme, DiscoveredStudio studio, AppLocalizations l10n) {
    final isClaimed = studio.isPartner;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isClaimed ? null : () => _showClaimDialog(studio),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Photo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  image: studio.photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(studio.photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: studio.photoUrl == null
                    ? Center(
                        child: FaIcon(
                          FontAwesomeIcons.buildingUser,
                          size: 20,
                          color: theme.colorScheme.outline,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            studio.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isClaimed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              l10n.partner,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (studio.address != null)
                      Text(
                        studio.address!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (studio.rating != null) ...[
                          FaIcon(
                            FontAwesomeIcons.solidStar,
                            size: 12,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            studio.rating!.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (studio.distanceMeters != null)
                          Text(
                            studio.formattedDistance,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isClaimed)
                FaIcon(
                  FontAwesomeIcons.chevronRight,
                  size: 14,
                  color: theme.colorScheme.outline,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualCreationCard(ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: InkWell(
        onTap: _showManualCreationDialog,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.plus,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.studioNotListed,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.createManualProfile,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 14,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showClaimDialog(DiscoveredStudio studio) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.claimThisStudio),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              studio.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (studio.address != null) ...[
              const SizedBox(height: 4),
              Text(
                studio.address!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            Text(
              l10n.claimStudioInfo,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.claim),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _claimStudio(studio);
    }
  }

  Future<void> _claimStudio(DiscoveredStudio studio) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AppLoader(),
    );

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticatedState) {
        final user = authState.user as AppUser;
        final isSuperAdmin = user.isSuperAdmin;

        if (isSuperAdmin) {
          // SuperAdmin: revendication directe
          await _claimService.claimStudio(userId: user.uid, studio: studio);
          if (mounted) {
            Navigator.pop(context);
            final l10n = AppLocalizations.of(context)!;
            // Force reload du BLoC pour mettre à jour l'état
            context.read<AuthBloc>().add(const ReloadUserEvent());
            AppSnackBar.success(context, l10n.studioClaimedSuccess(studio.name));
            context.pop(true);
          }
        } else {
          // Non-superAdmin: créer une demande
          final studioProfile = StudioProfile(
            name: studio.name,
            address: studio.address ?? '',
            location: GeoPoint(studio.position.latitude, studio.position.longitude),
            photos: studio.photoUrl != null ? [studio.photoUrl!] : [],
            googlePlaceId: studio.id,
            googlePlaceName: studio.name,
            rating: studio.rating,
            reviewCount: studio.reviewCount,
            website: studio.website,
            phone: studio.phoneNumber,
            services: studio.services,
          );

          await _approvalService.createClaimRequest(
            userId: user.uid,
            userEmail: user.email,
            userName: user.fullName,
            studioProfile: studioProfile,
          );

          if (mounted) {
            Navigator.pop(context);
            _showPendingClaimDialog(studio.name);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        AppSnackBar.error(context, 'Erreur: $e');
      }
    }
  }

  void _showPendingClaimDialog(String studioName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const FaIcon(FontAwesomeIcons.clock, color: Colors.orange, size: 32),
        title: const Text('Demande envoyée'),
        content: Text(
          'Votre demande de revendication pour "$studioName" a été envoyée. '
          'Un administrateur examinera votre demande prochainement.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  void _showManualCreationDialog() {
    context.push(AppRoutes.studioCreate);
  }
}
