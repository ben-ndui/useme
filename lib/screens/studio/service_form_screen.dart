import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/core/services/services_exports.dart';
import 'package:useme/config/responsive_config.dart';
import 'package:useme/widgets/common/limit_reached_dialog.dart';
import 'package:useme/l10n/app_localizations.dart';
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
        final l10n = AppLocalizations.of(context)!;
        if (state is ServiceLimitReachedState) {
          LimitReachedDialog.show(
            context,
            limitType: 'services',
            currentCount: state.currentCount,
            maxAllowed: state.maxAllowed,
            tierId: state.tierId,
          );
        } else if (state is ServiceCreatedState) {
          AppSnackBar.success(context, l10n.serviceCreated);
          context.pop();
        } else if (state is ServiceUpdatedState) {
          AppSnackBar.success(context, l10n.serviceModified);
          context.pop();
        } else if (state is ServiceErrorState) {
          AppSnackBar.error(context, state.errorMessage ?? l10n.error);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? AppLocalizations.of(context)!.editService : AppLocalizations.of(context)!.newServiceTitle),
          actions: [
            if (isEditing)
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.trash, size: 18),
                onPressed: _showDeleteDialog,
              ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Responsive.maxFormWidth),
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
            // Nom du service
            _buildSectionTitle(context, l10n.serviceName),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: l10n.serviceNameHint,
                prefixIcon: const Icon(Icons.label),
              ),
              validator: (value) => value?.isEmpty ?? true ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: 24),

            // Description
            _buildSectionTitle(context, l10n.descriptionOptional),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: l10n.descriptionHint,
              ),
            ),
            const SizedBox(height: 24),

            // Prix horaire
            _buildSectionTitle(context, l10n.hourlyRate),
            const SizedBox(height: 8),
            TextFormField(
              controller: _hourlyRateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '50',
                prefixIcon: const Icon(Icons.euro),
                suffixText: l10n.perHour,
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return l10n.fieldRequired;
                if (double.tryParse(value!) == null) return l10n.invalidNumber;
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Durée minimum
            _buildSectionTitle(context, l10n.minimumDuration),
            const SizedBox(height: 8),
            _buildDurationSelector(context),
            const SizedBox(height: 24),

            // Salles associées
            _buildSectionTitle(context, l10n.roomsOptional),
            const SizedBox(height: 8),
            _buildRoomSelector(context),
            const SizedBox(height: 24),

            // Statut actif
            SwitchListTile(
              title: Text(l10n.serviceActive),
              subtitle: Text(_isActive ? l10n.availableForBooking : l10n.notAvailableForBooking),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
            const SizedBox(height: 32),

            // Submit button
            FilledButton(
              onPressed: _submitForm,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Text(isEditing ? l10n.save : l10n.createService),
              ),
            ),
                    ],
                  ),
                );
              },
            ),
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
            AppLocalizations.of(context)!.noRoomConfigured,
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTheService),
        content: Text(l10n.actionIrreversible),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              context.read<ServiceBloc>().add(DeleteServiceEvent(serviceId: widget.serviceId!));
              Navigator.pop(context);
              context.pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
