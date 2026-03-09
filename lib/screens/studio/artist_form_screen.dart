import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/config/responsive_config.dart';
import 'package:useme/l10n/app_localizations.dart';

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
  bool _isLoaded = false;
  Artist? _existingArtist;

  bool get isEditing => widget.artistId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoaded && isEditing) {
      _loadArtistData();
      _isLoaded = true;
    }
  }

  void _loadArtistData() {
    final artistState = context.read<ArtistBloc>().state;
    final artist = artistState.artists.where((a) => a.id == widget.artistId).firstOrNull;
    if (artist != null) {
      _existingArtist = artist;
      _nameController.text = artist.name;
      _stageNameController.text = artist.stageName ?? '';
      _emailController.text = artist.email ?? '';
      _phoneController.text = artist.phone ?? '';
      _cityController.text = artist.city ?? '';
      _bioController.text = artist.bio ?? '';
      _selectedGenres.clear();
      _selectedGenres.addAll(artist.genres);
      setState(() {});
    }
  }

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editArtist : l10n.newArtistTitle),
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
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
            // Nom d'artiste (stage name)
            _buildSectionTitle(context, l10n.artistName),
            const SizedBox(height: 8),
            TextFormField(
              controller: _stageNameController,
              decoration: InputDecoration(
                hintText: l10n.stageNameHint,
                prefixIcon: const Icon(Icons.star),
              ),
            ),
            const SizedBox(height: 24),

            // Nom civil
            _buildSectionTitle(context, l10n.civilName),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: l10n.firstAndLastName,
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) => value?.isEmpty ?? true ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: 24),

            // Contact
            _buildSectionTitle(context, l10n.contact),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: l10n.emailHintGeneric,
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: l10n.phoneHintGeneric,
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                hintText: l10n.cityHint,
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 24),

            // Genres
            _buildSectionTitle(context, l10n.musicalGenres),
            const SizedBox(height: 8),
            _buildGenreSelector(context),
            const SizedBox(height: 24),

            // Bio
            _buildSectionTitle(context, l10n.bioOptional),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.fewWordsAboutArtist,
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            FilledButton(
              onPressed: _submitForm,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(isEditing ? l10n.save : l10n.createTheArtist),
              ),
            ),
              ],
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
      studioIds: _existingArtist?.studioIds ?? [],
      name: _nameController.text.trim(),
      stageName: _stageNameController.text.trim().isEmpty ? null : _stageNameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      genres: _selectedGenres,
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      createdAt: _existingArtist?.createdAt ?? DateTime.now(),
      photoUrl: _existingArtist?.photoUrl,
    );

    if (isEditing) {
      context.read<ArtistBloc>().add(UpdateArtistEvent(artist: artist));
    } else {
      context.read<ArtistBloc>().add(CreateArtistEvent(artist: artist));
    }

    context.pop();
  }

  void _showDeleteDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTheArtist),
        content: Text(l10n.actionIrreversible),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              context.read<ArtistBloc>().add(DeleteArtistEvent(artistId: widget.artistId!));
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
