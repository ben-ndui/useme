import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/core/services/services_exports.dart';
import 'package:useme/widgets/common/limit_reached_dialog.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Service creation/editing form
class ServiceFormScreen extends StatefulWidget {
  final String? serviceId;

  const ServiceFormScreen({super.key, this.serviceId});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _serviceCatalogService = ServiceCatalogService();

  int _minDuration = 2;
  bool _isActive = true;
  List<String> _selectedRoomIds = [];
  bool _isLoaded = false;

  bool get isEditing => widget.serviceId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoaded && isEditing) {
      _loadServiceData();
      _isLoaded = true;
    }
  }

  void _loadServiceData() {
    final serviceState = context.read<ServiceBloc>().state;
    final service = serviceState.services.where((s) => s.id == widget.serviceId).firstOrNull;
    if (service != null) {
      _nameController.text = service.name;
      _descriptionController.text = service.description ?? '';
      _hourlyRateController.text = service.hourlyRate.toStringAsFixed(0);
      _minDuration = service.minDurationHours;
      _isActive = service.isActive;
      _selectedRoomIds = List.from(service.roomIds);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServiceBloc, ServiceState>(
      listener: (context, state) {
        if (state is ServiceLimitReachedState) {
          LimitReachedDialog.show(
            context,
            limitType: 'services',
            currentCount: state.currentCount,
            maxAllowed: state.maxAllowed,
            tierId: state.tierId,
          );
        } else if (state is ServiceCreatedState) {
          AppSnackBar.success(context, 'Service créé');
          context.pop();
        } else if (state is ServiceUpdatedState) {
          AppSnackBar.success(context, 'Service modifié');
          context.pop();
        } else if (state is ServiceErrorState) {
          AppSnackBar.error(context, state.errorMessage ?? 'Erreur');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Modifier le service' : 'Nouveau service'),
          actions: [
            if (isEditing)
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.trash, size: 18),
                onPressed: _showDeleteDialog,
              ),
          ],
        ),
        body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nom du service
            _buildSectionTitle(context, 'Nom du service'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Ex: Mix, Mastering, Recording...',
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 24),

            // Description
            _buildSectionTitle(context, 'Description (optionnel)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Description du service...',
              ),
            ),
            const SizedBox(height: 24),

            // Prix horaire
            _buildSectionTitle(context, 'Tarif horaire (€)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _hourlyRateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: '50',
                prefixIcon: Icon(Icons.euro),
                suffixText: '€/h',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Champ requis';
                if (double.tryParse(value!) == null) return 'Nombre invalide';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Durée minimum
            _buildSectionTitle(context, 'Durée minimum'),
            const SizedBox(height: 8),
            _buildDurationSelector(context),
            const SizedBox(height: 24),

            // Salles associées
            _buildSectionTitle(context, 'Salles (optionnel)'),
            const SizedBox(height: 8),
            _buildRoomSelector(context),
            const SizedBox(height: 24),

            // Statut actif
            SwitchListTile(
              title: const Text('Service actif'),
              subtitle: Text(_isActive ? 'Disponible à la réservation' : 'Non disponible'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
            const SizedBox(height: 32),

            // Submit button
            FilledButton(
              onPressed: _submitForm,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Text(isEditing ? 'Enregistrer' : 'Créer le service'),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildDurationSelector(BuildContext context) {
    return Wrap(
      children: [1, 2, 3, 4, 6, 8].map((hours) {
        final isSelected = _minDuration == hours;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text('${hours}h'),
            selected: isSelected,
            onSelected: (_) => setState(() => _minDuration = hours),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRoomSelector(BuildContext context) {
    return BlocBuilder<StudioRoomBloc, StudioRoomState>(
      builder: (context, state) {
        if (state.rooms.isEmpty) {
          return Text(
            'Aucune salle configurée',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.rooms.map((room) {
            final isSelected = _selectedRoomIds.contains(room.id);
            return FilterChip(
              label: Text(room.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedRoomIds = [..._selectedRoomIds, room.id];
                  } else {
                    _selectedRoomIds = _selectedRoomIds.where((id) => id != room.id).toList();
                  }
                });
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;

    // Get subscription info
    String? subscriptionTierId;
    if (authState.user is AppUser) {
      subscriptionTierId = (authState.user as AppUser).subscriptionTierId;
    }

    // Get current services count from bloc state
    final serviceState = context.read<ServiceBloc>().state;
    final currentServiceCount = serviceState.services.length;

    final service = StudioService(
      id: widget.serviceId ?? _serviceCatalogService.getNewServiceId(),
      studioId: authState.user.uid,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      hourlyRate: double.parse(_hourlyRateController.text.trim()),
      minDurationHours: _minDuration,
      roomIds: _selectedRoomIds,
      isActive: _isActive,
      createdAt: DateTime.now(),
    );

    if (isEditing) {
      context.read<ServiceBloc>().add(UpdateServiceEvent(service: service));
    } else {
      context.read<ServiceBloc>().add(CreateServiceEvent(
            service: service,
            subscriptionTierId: subscriptionTierId,
            currentServiceCount: currentServiceCount,
          ));
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le service'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              context.read<ServiceBloc>().add(DeleteServiceEvent(serviceId: widget.serviceId!));
              Navigator.pop(context);
              context.pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
