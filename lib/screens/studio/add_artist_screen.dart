import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/core/services/invitation_service.dart';
import 'package:useme/widgets/common/app_loader.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';
import 'package:useme/widgets/studio/artist/artist_exports.dart';
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
      return const AppLoader();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ArtistInfoCard(
            icon: FontAwesomeIcons.magnifyingGlass,
            title: 'Trouvez un artiste existant',
            description: 'Recherchez parmi les artistes déjà inscrits sur Use Me pour le lier à votre studio.',
          ),
          const SizedBox(height: 24),
          if (_isLinking)
            const AppLoader.compact()
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
      child: ArtistCreationForm(
        studioId: _studioId,
        studioName: _studioName,
        invitationService: _invitationService,
        onSuccess: () => context.pop(true),
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
        AppSnackBar.success(context, '${user.displayName} ajouté à votre studio !');
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Erreur: $e');
      }
    } finally {
      if (mounted) setState(() => _isLinking = false);
    }
  }
}
