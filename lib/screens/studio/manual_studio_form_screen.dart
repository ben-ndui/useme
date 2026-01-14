import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/studio_profile.dart';
import 'package:useme/core/services/location_service.dart';
import 'package:useme/core/services/studio_claim_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Écran pour créer manuellement un profil studio (sans lien Google)
class ManualStudioFormScreen extends StatefulWidget {
  const ManualStudioFormScreen({super.key});

  @override
  State<ManualStudioFormScreen> createState() => _ManualStudioFormScreenState();
}

class _ManualStudioFormScreenState extends State<ManualStudioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studioClaimService = StudioClaimService();
  final _locationService = LocationService();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();

  bool _isSubmitting = false;
  GeoPoint? _location;
  StudioType _selectedStudioType = StudioType.independent;

  final List<String> _availableServices = [
    'Enregistrement',
    'Mixage',
    'Mastering',
    'Production',
    'Composition',
    'Sound Design',
  ];
  final List<String> _selectedServices = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final latLng = await _locationService.getCurrentLatLng();
      setState(() {
        _location = GeoPoint(latLng.latitude, latLng.longitude);
      });
    } catch (e) {
      // Ignorer - la localisation sera null
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticatedState) {
        throw Exception('Non connecté');
      }

      final profile = StudioProfile(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        postalCode: _postalCodeController.text.trim().isEmpty
            ? null
            : _postalCodeController.text.trim(),
        country: 'France',
        location: _location,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        website: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
        services: _selectedServices,
        studioType: _selectedStudioType,
        claimedAt: DateTime.now(),
      );

      await _studioClaimService.createManualStudio(
        userId: authState.user.uid,
        profile: profile,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        // Force reload du BLoC pour mettre à jour l'état avec le nouveau studio
        context.read<AuthBloc>().add(const ReloadUserEvent());
        AppSnackBar.success(context, l10n.studioCreatedSuccess);
        context.go(AppRoutes.home);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        AppSnackBar.error(context, '${AppLocalizations.of(context)!.error}: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createMyStudio)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info card
            _buildInfoCard(theme, l10n),
            const SizedBox(height: 24),

            // Nom du studio
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.studioNameRequired,
                hintText: l10n.studioNameHint,
                prefixIcon: const Icon(FontAwesomeIcons.microphone, size: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.studioNameIsRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.description,
                hintText: l10n.describeYourStudio,
                prefixIcon: const Icon(FontAwesomeIcons.alignLeft, size: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Type de studio
            DropdownButtonFormField<StudioType>(
              initialValue: _selectedStudioType,
              decoration: InputDecoration(
                labelText: l10n.studioTypeLabel,
                prefixIcon: const Icon(FontAwesomeIcons.building, size: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: StudioType.values.map((type) {
                final label = switch (type) {
                  StudioType.pro => l10n.studioTypePro,
                  StudioType.independent => l10n.studioTypeIndependent,
                  StudioType.amateur => l10n.studioTypeAmateur,
                };
                return DropdownMenuItem(value: type, child: Text(label));
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedStudioType = value);
              },
            ),
            const SizedBox(height: 24),

            // Section Adresse
            Text(l10n.location, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),

            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: l10n.address,
                hintText: l10n.addressHint,
                prefixIcon: const Icon(FontAwesomeIcons.locationDot, size: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _postalCodeController,
                    decoration: InputDecoration(
                      labelText: l10n.postalCode,
                      hintText: '75001',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: l10n.cityRequired,
                      hintText: 'Paris',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.cityIsRequired;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section Contact
            Text(l10n.contact, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),

            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: l10n.phone,
                hintText: '06 12 34 56 78',
                prefixIcon: const Icon(FontAwesomeIcons.phone, size: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _websiteController,
              decoration: InputDecoration(
                labelText: l10n.website,
                hintText: 'https://www.monstudio.com',
                prefixIcon: const Icon(FontAwesomeIcons.globe, size: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),

            // Section Services
            Text(l10n.servicesOffered, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableServices.map((service) {
                final isSelected = _selectedServices.contains(service);
                return FilterChip(
                  label: Text(service),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedServices.add(service);
                      } else {
                        _selectedServices.remove(service);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Submit button
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const FaIcon(FontAwesomeIcons.check, size: 14),
              label: Text(_isSubmitting ? l10n.creatingInProgress : l10n.createMyStudio),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
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
                  l10n.manualCreation,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.manualCreationDescription,
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
}
