import 'package:flutter/material.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/widgets/messaging/reaction_button.dart';
import 'package:useme/widgets/messaging/reaction_picker.dart';

/// Bottom sheet for message options with reactions
class MessageOptionsSheet extends StatelessWidget {
  final BaseMessage message;
  final bool isMe;
  final String currentUserId;
  final void Function(String emoji) onReactionTap;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;

  const MessageOptionsSheet({
    super.key,
    required this.message,
    required this.isMe,
    required this.currentUserId,
    required this.onReactionTap,
    this.onCopy,
    this.onDelete,
  });

  static void show({
    required BuildContext context,
    required BaseMessage message,
    required bool isMe,
    required String currentUserId,
    required void Function(String emoji) onReactionTap,
    VoidCallback? onCopy,
    VoidCallback? onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => MessageOptionsSheet(
        message: message,
        isMe: isMe,
        currentUserId: currentUserId,
        onReactionTap: (emoji) {
          Navigator.pop(ctx);
          onReactionTap(emoji);
        },
        onCopy: onCopy != null
            ? () {
                Navigator.pop(ctx);
                onCopy();
              }
            : null,
        onDelete: onDelete != null
            ? () {
                Navigator.pop(ctx);
                onDelete();
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildReactionRow(context),
          const Divider(height: 1),
          if (message.text != null && message.text!.isNotEmpty && onCopy != null)
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copier'),
              onTap: onCopy,
            ),
          if (isMe && !message.isDeleted && onDelete != null)
            ListTile(
              leading: Icon(Icons.delete, color: theme.colorScheme.error),
              title: Text('Supprimer', style: TextStyle(color: theme.colorScheme.error)),
              onTap: onDelete,
            ),
        ],
      ),
    );
  }

  Widget _buildReactionRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: kReactionEmojis.map((emoji) {
          final hasReacted = message.hasReacted(currentUserId, emoji);
          return ReactionButton(
            emoji: emoji,
            isSelected: hasReacted,
            onTap: () => onReactionTap(emoji),
          );
        }).toList(),
      ),
    );
  }
}
