import 'package:flutter/material.dart';
import 'package:useme/core/models/models_exports.dart';

/// Bulle de réponse de l'assistant IA
class AIResponseBubble extends StatelessWidget {
  final ChatAssistantResponse response;
  final VoidCallback? onDismiss;
  final Function(SuggestedAction)? onActionTap;
  final VoidCallback? onUseResponse;
  final VoidCallback? onEditResponse;

  const AIResponseBubble({
    super.key,
    required this.response,
    this.onDismiss,
    this.onActionTap,
    this.onUseResponse,
    this.onEditResponse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(isDark ? 0.2 : 0.1),
            Colors.blue.withOpacity(isDark ? 0.2 : 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(context),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              response.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),

          // Actions suggérées
          if (response.actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildActions(context),
          ],

          // Boutons d'action
          const SizedBox(height: 12),
          _buildActionButtons(context),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 16,
              color: Colors.purple,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Assistant IA',
            style: TextStyle(
              fontSize: 12,
              color: Colors.purple,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (response.confidence < 0.7)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Incertain',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                size: 18,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: response.actions.map((action) {
          return ActionChip(
            avatar: Icon(
              _getActionIcon(action.type),
              size: 16,
              color: Colors.purple,
            ),
            label: Text(
              action.label,
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: Colors.purple.withOpacity(0.1),
            side: BorderSide(color: Colors.purple.withOpacity(0.3)),
            onPressed: () => onActionTap?.call(action),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onEditResponse,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Modifier'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onUseResponse,
              icon: const Icon(Icons.send, size: 16),
              label: const Text('Envoyer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon(ActionType type) {
    switch (type) {
      case ActionType.booking:
        return Icons.calendar_today;
      case ActionType.viewServices:
        return Icons.list_alt;
      case ActionType.viewAvailability:
        return Icons.schedule;
      case ActionType.contact:
        return Icons.person;
      case ActionType.viewEquipment:
        return Icons.mic;
      case ActionType.viewLocation:
        return Icons.location_on;
      case ActionType.customMessage:
        return Icons.message;
    }
  }
}
