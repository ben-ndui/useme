import 'package:flutter/material.dart';
import 'package:useme/core/models/ai_message.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/chat/chat_widgets_exports.dart';

/// Bulle de message dans la conversation IA
class AIMessageBubble extends StatelessWidget {
  final AIMessage message;
  final ValueChanged<String> onSuggestionTap;

  const AIMessageBubble({
    super.key,
    required this.message,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAI = message.isFromAI;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment:
            isAI ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isAI
                  ? Theme.of(context).cardColor
                  : Colors.purple.shade500,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: isAI ? const Radius.circular(4) : null,
                bottomRight: !isAI ? const Radius.circular(4) : null,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isAI) _buildAILabel(context),
                if (isAI)
                  AIMessageContent(content: message.content)
                else
                  Text(
                    message.content,
                    style: const TextStyle(
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
          if (isAI && message.suggestions.isNotEmpty)
            _buildSuggestions(context),
        ],
      ),
    );
  }

  Widget _buildAILabel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 14,
            color: Colors.purple.shade400,
          ),
          const SizedBox(width: 4),
          Text(
            AppLocalizations.of(context)!.aiAssistantLabel,
            style: TextStyle(
              fontSize: 11,
              color: Colors.purple.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: message.suggestions.map((suggestion) {
          return GestureDetector(
            onTap: () => onSuggestionTap(suggestion),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.purple.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                suggestion,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.purple.shade600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
