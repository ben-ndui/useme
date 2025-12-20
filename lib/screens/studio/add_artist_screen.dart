import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/core/services/invitation_service.dart';
import 'package:useme/widgets/studio/artist_search_widget.dart';

/// Écran d'ajout d'artiste avec recherche + création + invitation
class AddArtistScreen extends StatefulWidget {
  const AddArtistScreen({super.key});

  @override
  State<AddArtistScreen> createState() => _AddArtistScreenState();
}

class _AddArtistScreenState extends State<AddArtistScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _invitationService = InvitationService();

  String? _studioId;
  String? _studioName;
  bool _isLinking = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      _studioId = authState.user.uid;
      final appUser = authState.user as AppUser;
      _studioName = appUser.studioProfile?.name ?? appUser.displayName;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un artiste'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 16), text: 'Rechercher'),
            Tab(icon: FaIcon(FontAwesomeIcons.userPlus, size: 16), text: 'Créer'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchTab(),
          _buildCreateTab(),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    if (_studioId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            icon: FontAwesomeIcons.magnifyingGlass,
            title: 'Trouvez un artiste existant',
            description: 'Recherchez parmi les artistes déjà inscrits sur Use Me pour le lier à votre studio.',
          ),
          const SizedBox(height: 24),
          if (_isLinking)
            const Center(child: CircularProgressIndicator())
          else
            ArtistSearchWidget(
              studioId: _studioId!,
              onUserSelected: _onUserSelected,
              onCreateNew: () => _tabController.animateTo(1),
            ),
        ],
      ),
    );
  }

  Widget _buildCreateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _ArtistCreationForm(
        studioId: _studioId,
        studioName: _studioName,
        invitationService: _invitationService,
        onSuccess: () => context.pop(true),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

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
              child: FaIcon(icon, size: 20, color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onUserSelected(AppUser user) async {
    setState(() => _isLinking = true);

    try {
      await _invitationService.linkExistingUserToStudio(
        userId: user.uid,
        studioId: _studioId!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.displayName} ajouté à votre studio !'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLinking = false);
    }
  }
}

/// Formulaire de création d'artiste avec invitation
class _ArtistCreationForm extends StatefulWidget {
  final String? studioId;
  final String? studioName;
  final InvitationService invitationService;
  final VoidCallback onSuccess;

  const _ArtistCreationForm({
    required this.studioId,
    required this.studioName,
    required this.invitationService,
    required this.onSuccess,
  });

  @override
  State<_ArtistCreationForm> createState() => _ArtistCreationFormState();
}

class _ArtistCreationFormState extends State<_ArtistCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stageNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  final List<String> _selectedGenres = [];
  final List<String> _availableGenres = [
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
      return _buildSuccessState(theme);
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(theme),
          const SizedBox(height: 24),

          // Nom d'artiste
          _buildSectionTitle(theme, 'Nom d\'artiste'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _stageNameController,
            decoration: const InputDecoration(
              hintText: 'Le nom de scène...',
              prefixIcon: Icon(Icons.star),
            ),
          ),
          const SizedBox(height: 16),

          // Nom civil
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
          const SizedBox(height: 16),

          // Email (important pour l'invitation)
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
          const SizedBox(height: 16),

          // Téléphone
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
          const SizedBox(height: 16),

          // Ville
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(
              hintText: 'Ville...',
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
          const SizedBox(height: 16),

          // Genres
          _buildSectionTitle(theme, 'Genres musicaux'),
          const SizedBox(height: 8),
          _buildGenreSelector(),
          const SizedBox(height: 24),

          // Invitation toggle
          SwitchListTile(
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
          ),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
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
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
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
              child: FaIcon(FontAwesomeIcons.userPlus, size: 20, color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Créer une fiche artiste',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  'Créez la fiche et invitez l\'artiste. Son compte sera automatiquement lié quand il s\'inscrira.',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600));
  }

  Widget _buildGenreSelector() {
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

  Widget _buildSuccessState(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: FaIcon(FontAwesomeIcons.circleCheck, size: 40, color: Colors.green),
          ),
        ),
        const SizedBox(height: 24),
        Text('Artiste créé !', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          'Partagez ce code avec l\'artiste pour qu\'il rejoigne votre studio',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: 24),

        // Code display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _createdInvitation!.code,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _createdInvitation!.code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code copié !')),
                  );
                },
                icon: const FaIcon(FontAwesomeIcons.copy, size: 18),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Share via system share
              },
              icon: const FaIcon(FontAwesomeIcons.shareNodes, size: 14),
              label: const Text('Partager'),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: widget.onSuccess,
              child: const Text('Terminé'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Créer la fiche artiste
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

      // Envoyer au bloc
      context.read<ArtistBloc>().add(CreateArtistEvent(artist: artist));

      // Créer l'invitation si demandé
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
