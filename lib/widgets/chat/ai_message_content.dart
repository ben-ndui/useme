import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ai_data_widgets.dart';

/// Types de blocs de données supportés
enum AIDataBlockType {
  sessions,
  services,
  team,
  stats,
  availability,
  pending,
  studios,
  favorites,
}

/// Bloc de données parsé depuis le contenu AI
class AIDataBlock {
  final AIDataBlockType type;
  final Map<String, dynamic> data;

  const AIDataBlock({required this.type, required this.data});
}

/// Widget qui affiche le contenu d'un message AI
/// Supporte le markdown et les blocs de données structurées
class AIMessageContent extends StatelessWidget {
  final String content;
  final Color? textColor;

  const AIMessageContent({
    super.key,
    required this.content,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final segments = _parseContent(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments.map((segment) {
        if (segment is String) {
          return _buildMarkdown(context, segment);
        } else if (segment is AIDataBlock) {
          return _buildDataBlock(context, segment);
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }

  /// Parse le contenu pour extraire les blocs de données
  List<dynamic> _parseContent(String text) {
    final segments = <dynamic>[];
    final pattern = RegExp(
      r'\[(\w+)_DATA\](.*?)\[\/\1_DATA\]',
      dotAll: true,
    );

    int lastEnd = 0;
    for (final match in pattern.allMatches(text)) {
      // Texte avant le bloc
      if (match.start > lastEnd) {
        final textBefore = text.substring(lastEnd, match.start).trim();
        if (textBefore.isNotEmpty) {
          segments.add(textBefore);
        }
      }

      // Parser le bloc de données
      final blockType = match.group(1)?.toUpperCase();
      final blockContent = match.group(2)?.trim() ?? '';

      try {
        final data = jsonDecode(blockContent) as Map<String, dynamic>;
        final type = _parseBlockType(blockType);
        if (type != null) {
          segments.add(AIDataBlock(type: type, data: data));
        }
      } catch (e) {
        // Si le JSON est invalide, afficher comme texte
        segments.add(blockContent);
      }

      lastEnd = match.end;
    }

    // Texte après le dernier bloc
    if (lastEnd < text.length) {
      final textAfter = text.substring(lastEnd).trim();
      if (textAfter.isNotEmpty) {
        segments.add(textAfter);
      }
    }

    // Si aucun bloc trouvé, retourner le texte original
    if (segments.isEmpty) {
      segments.add(text);
    }

    return segments;
  }

  AIDataBlockType? _parseBlockType(String? type) {
    return switch (type) {
      'SESSIONS' => AIDataBlockType.sessions,
      'SERVICES' => AIDataBlockType.services,
      'TEAM' => AIDataBlockType.team,
      'STATS' => AIDataBlockType.stats,
      'AVAILABILITY' => AIDataBlockType.availability,
      'PENDING' => AIDataBlockType.pending,
      'STUDIOS' => AIDataBlockType.studios,
      'FAVORITES' => AIDataBlockType.favorites,
      _ => null,
    };
  }

  Widget _buildMarkdown(BuildContext context, String text) {
    final theme = Theme.of(context);

    return MarkdownBody(
      data: text,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: theme.textTheme.bodyMedium?.copyWith(
          color: textColor,
          height: 1.5,
        ),
        strong: theme.textTheme.bodyMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        em: theme.textTheme.bodyMedium?.copyWith(
          color: textColor,
          fontStyle: FontStyle.italic,
        ),
        listBullet: theme.textTheme.bodyMedium?.copyWith(
          color: textColor,
        ),
        a: TextStyle(
          color: Colors.purple.shade400,
          decoration: TextDecoration.underline,
        ),
        code: TextStyle(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          fontFamily: 'monospace',
          fontSize: 13,
        ),
        blockquote: theme.textTheme.bodyMedium?.copyWith(
          color: textColor?.withOpacity(0.8),
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Colors.purple.shade300,
              width: 3,
            ),
          ),
        ),
        h1: theme.textTheme.titleLarge?.copyWith(color: textColor),
        h2: theme.textTheme.titleMedium?.copyWith(color: textColor),
        h3: theme.textTheme.titleSmall?.copyWith(color: textColor),
      ),
      onTapLink: (text, href, title) {
        if (href != null) {
          launchUrl(Uri.parse(href));
        }
      },
    );
  }

  Widget _buildDataBlock(BuildContext context, AIDataBlock block) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: switch (block.type) {
        AIDataBlockType.sessions => AISessionsCard(data: block.data),
        AIDataBlockType.services => AIServicesCard(data: block.data),
        AIDataBlockType.team => AITeamCard(data: block.data),
        AIDataBlockType.stats => AIStatsCard(data: block.data),
        AIDataBlockType.availability => AIAvailabilityCard(data: block.data),
        AIDataBlockType.pending => AIPendingRequestsCard(data: block.data),
        AIDataBlockType.studios => AIStudiosCard(data: block.data),
        AIDataBlockType.favorites => AIStudiosCard(data: block.data, isFavorites: true),
      },
    );
  }
}
