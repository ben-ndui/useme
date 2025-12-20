import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';

/// Artist creation/editing form
class ArtistFormScreen extends StatefulWidget {
  final String? artistId;

  const ArtistFormScreen({super.key, this.artistId});

  @override
  State<ArtistFormScreen> createState() => _ArtistFormScreenState();
}

class _ArtistFormScreenState extends State<ArtistFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stageNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _bioController = TextEditingController();

  final List<String> _selectedGenres = [];
  final List<String> _availableGenres = [
    'Hip-Hop', 'R&B', 'Pop', 'Rock', 'Jazz', 'Soul', 'Électro', 'Reggae', 'Afro', 'Classique', 'Folk', 'Autre'
  ];

  bool get isEditing => widget.artistId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _stageNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier l\'artiste' : 'Nouvel artiste'),
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
            // Nom d'artiste (stage name)
            _buildSectionTitle(context, 'Nom d\'artiste'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _stageNameController,
              decoration: const InputDecoration(
                hintText: 'Le nom de scène...',
                prefixIcon: Icon(Icons.star),
              ),
            ),
            const SizedBox(height: 24),

            // Nom civil
            _buildSectionTitle(context, 'Nom civil'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Prénom et nom...',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 24),

            // Contact
            _buildSectionTitle(context, 'Contact'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email...',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Téléphone...',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                hintText: 'Ville...',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 24),

            // Genres
            _buildSectionTitle(context, 'Genres musicaux'),
            const SizedBox(height: 8),
            _buildGenreSelector(context),
            const SizedBox(height: 24),

            // Bio
            _buildSectionTitle(context, 'Bio (optionnel)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Quelques mots sur l\'artiste...',
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            FilledButton(
              onPressed: _submitForm,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(isEditing ? 'Enregistrer' : 'Créer l\'artiste'),
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

  Widget _buildGenreSelector(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableGenres.map((genre) {
        final isSelected = _selectedGenres.contains(genre);
        return FilterChip(
          label: Text(genre),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedGenres.add(genre);
              } else {
                _selectedGenres.remove(genre);
              }
            });
          },
        );
      }).toList(),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final artist = Artist(
      id: widget.artistId ?? '',
      studioIds: [], // TODO: Get from auth
      name: _nameController.text.trim(),
      stageName: _stageNameController.text.trim().isEmpty ? null : _stageNameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      genres: _selectedGenres,
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      createdAt: DateTime.now(),
    );

    if (isEditing) {
      context.read<ArtistBloc>().add(UpdateArtistEvent(artist: artist));
    } else {
      context.read<ArtistBloc>().add(CreateArtistEvent(artist: artist));
    }

    context.pop();
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'artiste'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              context.read<ArtistBloc>().add(DeleteArtistEvent(artistId: widget.artistId!));
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
