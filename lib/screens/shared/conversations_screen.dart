import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/common/app_loader.dart';
import 'package:useme/widgets/messaging/new_conversation_bottom_sheet.dart';

/// Écran listant toutes les conversations.
class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _retryLoad() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      // Forcer le rechargement
      context.read<MessagingBloc>().add(const ClearMessagingEvent());
      context.read<MessagingBloc>().add(
            LoadConversationsEvent(userId: authState.user.id),
          );
    }
  }

  Widget _buildSearchBar(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
        decoration: InputDecoration(
          hintText: l10n.searchContact,
          prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass, size: 16),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(FontAwesomeIcons.xmark, size: 16),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.messages),
        actions: [
          IconButton(
            onPressed: () => NewConversationBottomSheet.show(context),
            icon: const FaIcon(FontAwesomeIcons.penToSquare, size: 20),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(theme, l10n),
          Expanded(
            child: BlocBuilder<MessagingBloc, MessagingState>(
              builder: (context, state) {
                if (state is MessagingLoadingState) {
                  return const AppLoader();
                }

                if (state is MessagingErrorState) {
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
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _retryLoad,
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ConversationsLoadedState) {
                  if (state.conversations.isEmpty && _searchQuery.isEmpty) {
                    return Column(
                      children: [
                        _buildAIAssistantTile(),
                        Expanded(child: _buildEmptyState(theme, l10n)),
                      ],
                    );
                  }

                  return _buildConversationsList(state);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.comments,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noConversations,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.startNewConversation,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => NewConversationBottomSheet.show(context),
            icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
            label: Text(l10n.newMessage),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList(ConversationsLoadedState state) {
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticatedState ? authState.user.id : '';
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Filter conversations by search query
    final filteredConversations = _searchQuery.isEmpty
        ? state.conversations
        : state.conversations.where((conv) {
            final displayName = conv.getDisplayName(currentUserId).toLowerCase();
            return displayName.contains(_searchQuery);
          }).toList();

    // If search active but no results, show search suggestion
    if (_searchQuery.isNotEmpty && filteredConversations.isEmpty) {
      return _buildNoSearchResults(theme, l10n);
    }

    return ListView.builder(
      itemCount: filteredConversations.length + (_searchQuery.isEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        // AI Assistant tile at the top (only when not searching)
        if (_searchQuery.isEmpty && index == 0) {
          return _buildAIAssistantTile();
        }

        final conversationIndex = _searchQuery.isEmpty ? index - 1 : index;
        final conversation = filteredConversations[conversationIndex];

        return Column(
          children: [
            ConversationTile(
              conversation: conversation,
              currentUserId: currentUserId,
              onTap: () => context.push('/conversations/${conversation.id}'),
              onLongPress: () => _showConversationOptions(conversation),
            ),
            if (conversationIndex < filteredConversations.length - 1) const Divider(height: 1),
          ],
        );
      },
    );
  }

  Widget _buildNoSearchResults(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.magnifyingGlass,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noResult,
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.searchNewContact,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => NewConversationBottomSheet.show(context),
            icon: const FaIcon(FontAwesomeIcons.userPlus, size: 16),
            label: Text(l10n.searchContact),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAssistantTile() {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          onTap: () => context.push(AppRoutes.aiAssistant),
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 26,
            ),
          ),
          title: const Text(
            'Assistant Use Me',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Pose tes questions !',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'IA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.purple,
              ),
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 2,
          color: Colors.purple.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  void _showConversationOptions(BaseConversation conversation) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticatedState
        ? authState.user.id
        : '';
    final isArchived = conversation.isArchivedFor(currentUserId);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  isArchived ? Icons.unarchive : Icons.archive,
                  color: theme.colorScheme.onSurface,
                ),
                title: Text(isArchived ? l10n.unarchive : l10n.archive),
                onTap: () {
                  Navigator.pop(context);
                  this.context.read<MessagingBloc>().add(
                        ToggleArchiveConversationEvent(
                          conversationId: conversation.id,
                          archived: !isArchived,
                        ),
                      );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
