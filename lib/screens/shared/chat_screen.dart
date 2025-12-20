import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';

/// Écran de chat pour une conversation.
class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final MessagingBloc _messagingBloc;

  @override
  void initState() {
    super.initState();
    _messagingBloc = context.read<MessagingBloc>();
    _openConversation();
  }

  void _openConversation() {
    _messagingBloc.add(
      OpenConversationEvent(conversationId: widget.conversationId),
    );
  }

  @override
  void dispose() {
    _messagingBloc.add(const CloseConversationEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticatedState
        ? authState.user.id ?? ''
        : '';

    return BlocBuilder<MessagingBloc, MessagingState>(
      builder: (context, state) {
        if (state is MessagingLoadingState) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chargement...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is MessagingErrorState) {
          return Scaffold(
            appBar: AppBar(title: const Text('Erreur')),
            body: Center(
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
                ],
              ),
            ),
          );
        }

        if (state is ChatOpenState) {
          return Scaffold(
            appBar: _buildAppBar(state.conversation, currentUserId),
            body: ChatView(
              conversation: state.conversation,
              messages: state.messages,
              currentUserId: currentUserId,
              isLoadingMore: state.isLoadingMore,
              hasMoreMessages: state.hasMoreMessages,
              isSending: state.isSending,
              onSendText: (text) {
                context.read<MessagingBloc>().add(
                      SendTextMessageEvent(text: text),
                    );
              },
              onLoadMore: () {
                context.read<MessagingBloc>().add(
                      const LoadMoreMessagesEvent(),
                    );
              },
              onMessageLongPress: (message) {
                _showMessageOptions(message, message.senderId == currentUserId);
              },
              onAttachmentTap: () {
                _handleAttachmentTap();
              },
              onAudioTap: () {
                _handleAudioTap();
              },
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(),
          body: const SizedBox.shrink(),
        );
      },
    );
  }

  AppBar _buildAppBar(BaseConversation conversation, String currentUserId) {
    final theme = Theme.of(context);
    final displayName = conversation.getDisplayName(currentUserId);
    final avatarUrl = conversation.getAvatarUrl(currentUserId);

    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          _buildAvatar(displayName, avatarUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (conversation.type == ConversationType.group)
                  Text(
                    '${conversation.participantIds.length} participants',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Info conversation
          },
          icon: const FaIcon(FontAwesomeIcons.circleInfo, size: 20),
        ),
      ],
    );
  }

  Widget _buildAvatar(String name, String? avatarUrl) {
    final theme = Theme.of(context);

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(avatarUrl),
      );
    }

    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 20,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        initial,
        style: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showMessageOptions(BaseMessage message, bool isMe) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.text != null && message.text!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: const Text('Copier'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Copier le texte
                  },
                ),
              if (isMe && !message.isDeleted)
                ListTile(
                  leading: Icon(Icons.delete, color: theme.colorScheme.error),
                  title: Text(
                    'Supprimer',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    this.context.read<MessagingBloc>().add(
                          DeleteMessageEvent(messageId: message.id),
                        );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleAttachmentTap() {
    // TODO: Ouvrir le picker de fichiers
  }

  void _handleAudioTap() {
    // TODO: Enregistrement audio
  }
}
