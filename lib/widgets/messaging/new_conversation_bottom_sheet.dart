import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/services/contact_service.dart';

/// Bottom sheet pour démarrer une nouvelle conversation.
class NewConversationBottomSheet extends StatefulWidget {
  const NewConversationBottomSheet({super.key});

  /// Affiche le bottom sheet et retourne l'ID de la conversation créée.
  static Future<String?> show(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NewConversationBottomSheet(),
    );
  }

  @override
  State<NewConversationBottomSheet> createState() => _NewConversationBottomSheetState();
}

class _NewConversationBottomSheetState extends State<NewConversationBottomSheet> {
  final _contactService = ContactService();
  final _searchController = TextEditingController();

  List<AppUser> _contacts = [];
  List<AppUser> _filteredContacts = [];
  bool _isLoading = true;
  String? _error;
  AppUser? _selectedContact;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;

    final currentUser = authState.user as AppUser;

    try {
      final contacts = await _contactService.getContacts(currentUser);
      if (mounted) {
        setState(() {
          _contacts = contacts;
          _filteredContacts = contacts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur lors du chargement des contacts';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredContacts = _contactService.searchContacts(_contacts, query);
    });
  }

  Future<void> _startConversation(AppUser contact) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;

    final currentUser = authState.user as AppUser;

    setState(() {
      _selectedContact = contact;
      _isCreating = true;
    });

    // Créer les ParticipantInfo
    final currentUserInfo = ParticipantInfo(
      name: currentUser.displayName ?? currentUser.name ?? 'Utilisateur',
      avatarUrl: currentUser.photoURL,
      role: currentUser.role.useMeLabel,
    );

    final otherUserInfo = ParticipantInfo(
      name: contact.displayName ?? contact.name ?? 'Contact',
      avatarUrl: contact.photoURL,
      role: contact.role.useMeLabel,
    );

    // Dispatcher l'event
    context.read<MessagingBloc>().add(StartPrivateConversationEvent(
          otherUserId: contact.uid,
          otherUserInfo: otherUserInfo,
          currentUserInfo: currentUserInfo,
        ));

    // Écouter le résultat
    await for (final state in context.read<MessagingBloc>().stream) {
      if (state is ChatOpenState) {
        if (mounted) {
          Navigator.pop(context);
          context.push('/conversations/${state.conversation.id}');
        }
        break;
      } else if (state is MessagingErrorState) {
        if (mounted) {
          setState(() {
            _isCreating = false;
            _selectedContact = null;
            _error = state.message;
          });
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(theme),
          _buildSearchBar(theme),
          Expanded(child: _buildContent(theme)),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Nouvelle conversation',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const FaIcon(FontAwesomeIcons.xmark, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Rechercher un contact...',
          prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass, size: 16),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.circleExclamation,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadContacts();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_filteredContacts.isEmpty) {
      return _buildEmptyState(theme);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: _filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = _filteredContacts[index];
        return FadeInUp(
          delay: Duration(milliseconds: 50 * index),
          duration: const Duration(milliseconds: 300),
          child: _buildContactTile(theme, contact),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final hasSearchQuery = _searchController.text.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            hasSearchQuery ? FontAwesomeIcons.magnifyingGlass : FontAwesomeIcons.userGroup,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            hasSearchQuery ? 'Aucun résultat' : 'Aucun contact disponible',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearchQuery
                ? 'Essayez avec d\'autres termes'
                : 'Vos contacts apparaîtront ici',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(ThemeData theme, AppUser contact) {
    final isSelected = _selectedContact?.uid == contact.uid;
    final isLoading = isSelected && _isCreating;

    return ListTile(
      onTap: _isCreating ? null : () => _startConversation(contact),
      leading: _buildAvatar(theme, contact),
      title: Text(
        contact.displayName ?? contact.name ?? 'Sans nom',
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Row(
        children: [
          _buildRoleBadge(theme, contact),
          if (contact.stageName != null) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                contact.stageName!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
      trailing: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 14,
              color: theme.colorScheme.outline,
            ),
    );
  }

  Widget _buildAvatar(ThemeData theme, AppUser contact) {
    if (contact.photoURL != null && contact.photoURL!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(contact.photoURL!),
      );
    }

    final initial = (contact.displayName ?? contact.name ?? '?')[0].toUpperCase();
    return CircleAvatar(
      radius: 24,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        initial,
        style: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildRoleBadge(ThemeData theme, AppUser contact) {
    final roleLabel = contact.role.useMeLabel;
    final color = _getRoleColor(contact.role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        roleLabel,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getRoleColor(BaseUserRole role) {
    switch (role) {
      case BaseUserRole.admin:
        return Colors.blue;
      case BaseUserRole.worker:
        return Colors.orange;
      case BaseUserRole.client:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
