import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/core/services/invitation_service.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';
import 'package:useme/widgets/studio/artist/artist_info_card.dart';
import 'package:useme/widgets/studio/artist/artist_creation_success.dart';

/// Form for creating a new artist with invitation
class ArtistCreationForm extends StatefulWidget {
  final String? studioId;
  final String? studioName;
  final InvitationService invitationService;
  final VoidCallback onSuccess;

  const ArtistCreationForm({
    super.key,
    required this.studioId,
    required this.studioName,
    required this.invitationService,
    required this.onSuccess,
  });

  @override
  State<ArtistCreationForm> createState() => _ArtistCreationFormState();
}

class _ArtistCreationFormState extends State<ArtistCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stageNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  final List<String> _selectedGenres = [];
  static const List<String> _availableGenres = [
    'Hip-Hop', 'R&B', 'Pop', 'Rock', 'Jazz', 'Soul', 'Électro', 'Reggae', 'Afro', 'Classique', 'Folk', 'Autre'
  ];

  bool _sendInvitation = true;
  bool _isSubmitting = false;
  StudioInvitation? _createdInvitation;

  @override
  void dispose() {
    _nameController.dispose();
    _stageNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_createdInvitation != null) {
      return ArtistCreationSuccess(
        invitation: _createdInvitation!,
        studioName: widget.studioName,
        onDone: widget.onSuccess,
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ArtistInfoCard(
            icon: FontAwesomeIcons.userPlus,
            title: 'Créer une fiche artiste',
            description: 'Créez la fiche et invitez l\'artiste. Son compte sera automatiquement lié quand il s\'inscrira.',
          ),
          const SizedBox(height: 24),
          _buildStageNameField(theme),
          const SizedBox(height: 16),
          _buildNameField(theme),
          const SizedBox(height: 16),
          _buildEmailField(theme),
          const SizedBox(height: 16),
          _buildPhoneField(theme),
          const SizedBox(height: 16),
          _buildCityField(),
          const SizedBox(height: 16),
          _buildGenreSection(theme),
          const SizedBox(height: 24),
          _buildInvitationToggle(theme),
          const SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600));
  }

  Widget _buildStageNameField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, 'Nom d\'artiste'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _stageNameController,
          decoration: const InputDecoration(
            hintText: 'Le nom de scène...',
            prefixIcon: Icon(Icons.star),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, 'Nom civil'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Prénom et nom...',
            prefixIcon: Icon(Icons.person),
          ),
          validator: (v) => v?.isEmpty ?? true ? 'Champ requis' : null,
        ),
      ],
    );
  }

  Widget _buildEmailField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, 'Email'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Email de l\'artiste...',
            prefixIcon: Icon(Icons.email),
          ),
          validator: (v) {
            if (_sendInvitation && (v?.isEmpty ?? true)) {
              return 'Email requis pour l\'invitation';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhoneField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, 'Téléphone (optionnel)'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: 'Téléphone...',
            prefixIcon: Icon(Icons.phone),
          ),
        ),
      ],
    );
  }

  Widget _buildCityField() {
    return TextFormField(
      controller: _cityController,
      decoration: const InputDecoration(
        hintText: 'Ville...',
        prefixIcon: Icon(Icons.location_on),
      ),
    );
  }

  Widget _buildGenreSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, 'Genres musicaux'),
        const SizedBox(height: 8),
        Wrap(
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
        ),
      ],
    );
  }

  Widget _buildInvitationToggle(ThemeData theme) {
    return SwitchListTile(
      value: _sendInvitation,
      onChanged: (v) => setState(() => _sendInvitation = v),
      title: const Text('Envoyer une invitation'),
      subtitle: Text(
        'L\'artiste recevra un code pour rejoindre votre studio',
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
      ),
      secondary: FaIcon(
        FontAwesomeIcons.paperPlane,
        size: 18,
        color: _sendInvitation ? theme.colorScheme.primary : theme.colorScheme.outline,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _isSubmitting ? null : _submitForm,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(_sendInvitation ? 'Créer et inviter' : 'Créer la fiche'),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final artist = Artist(
        id: '',
        studioIds: widget.studioId != null ? [widget.studioId!] : [],
        name: _nameController.text.trim(),
        stageName: _stageNameController.text.trim().isEmpty ? null : _stageNameController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        genres: _selectedGenres,
        createdAt: DateTime.now(),
      );

      context.read<ArtistBloc>().add(CreateArtistEvent(artist: artist));

      if (_sendInvitation && _emailController.text.trim().isNotEmpty && widget.studioId != null) {
        final invitation = await widget.invitationService.createInvitation(
          studioId: widget.studioId!,
          studioName: widget.studioName ?? 'Studio',
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        );

        setState(() => _createdInvitation = invitation);
      } else {
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Erreur: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
