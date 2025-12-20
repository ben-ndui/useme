import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';

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

  int _minDuration = 2;
  bool _isActive = true;

  bool get isEditing => widget.serviceId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final service = StudioService(
      id: widget.serviceId ?? '',
      studioId: '', // TODO: Get from auth
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      hourlyRate: double.parse(_hourlyRateController.text.trim()),
      minDurationHours: _minDuration,
      isActive: _isActive,
      createdAt: DateTime.now(),
    );

    if (isEditing) {
      context.read<ServiceBloc>().add(UpdateServiceEvent(service: service));
    } else {
      context.read<ServiceBloc>().add(CreateServiceEvent(service: service));
    }

    context.pop();
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
