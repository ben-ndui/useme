import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uzme/config/useme_theme.dart';
import 'package:uzme/core/models/ai_message.dart';
import 'package:uzme/widgets/chat/chat_widgets_exports.dart';

/// Bulle de message dans la conversation IA assistant
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
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: isAI ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isAI) ...[
                _AIAvatar(),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isAI ? cs.surfaceContainerHigh : UseMeTheme.primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isAI ? 4 : 18),
                      bottomRight: Radius.circular(isAI ? 18 : 4),
                    ),
                    border: isAI
                        ? Border.all(color: cs.outlineVariant.withValues(alpha: 0.5))
                        : null,
                  ),
                  child: isAI
                      ? AIMessageContent(
                          content: message.content,
                          textColor: cs.onSurface,
                        )
                      : Text(
                          message.content,
                          style: const TextStyle(
                            color: Colors.white,
                            height: 1.45,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          ),
          if (isAI && message.suggestions.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildSuggestions(context, cs),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(left: 44),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: message.suggestions.map((s) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _SuggestionChip(label: s, onTap: () => onSuggestionTap(s)),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _AIAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [UseMeTheme.accentColor, UseMeTheme.primaryColor],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: FaIcon(FontAwesomeIcons.solidStar, color: Colors.white, size: 11),
      ),
    );
  }
}

class _SuggestionChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  State<_SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<_SuggestionChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: cs.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}
