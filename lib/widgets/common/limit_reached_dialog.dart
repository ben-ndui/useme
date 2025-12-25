import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

/// Dialog affiché quand une limite d'abonnement est atteinte
class LimitReachedDialog extends StatelessWidget {
  final String limitType; // 'sessions', 'salles', 'services', 'ingénieurs'
  final int currentCount;
  final int maxAllowed;
  final String tierId;
  final VoidCallback? onDismiss;

  const LimitReachedDialog({
    super.key,
    required this.limitType,
    required this.currentCount,
    required this.maxAllowed,
    required this.tierId,
    this.onDismiss,
  });

  /// Affiche le dialog de limite atteinte
  static Future<void> show(
    BuildContext context, {
    required String limitType,
    required int currentCount,
    required int maxAllowed,
    required String tierId,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => LimitReachedDialog(
        limitType: limitType,
        currentCount: currentCount,
        maxAllowed: maxAllowed,
        tierId: tierId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tierName = _getTierName(tierId);
    final nextTier = _getNextTier(tierId);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const FaIcon(
              FontAwesomeIcons.lock,
              size: 32,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Limite atteinte',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Message
          Text(
            'Vous avez atteint la limite de $maxAllowed $limitType '
            'pour l\'abonnement $tierName.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),

          // Current usage
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$currentCount / $maxAllowed $limitType',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Upgrade suggestion
          if (nextTier != null) ...[
            Text(
              'Passez à ${nextTier['name']} pour ${nextTier['limit']}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onDismiss?.call();
                  },
                  child: const Text('Plus tard'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/upgrade');
                  },
                  icon: const FaIcon(FontAwesomeIcons.arrowUp, size: 14),
                  label: const Text('Upgrade'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTierName(String tierId) {
    switch (tierId) {
      case 'free':
        return 'Gratuit';
      case 'pro':
        return 'Pro';
      case 'enterprise':
        return 'Enterprise';
      default:
        return tierId;
    }
  }

  Map<String, String>? _getNextTier(String currentTierId) {
    switch (currentTierId) {
      case 'free':
        return {
          'name': 'Pro',
          'limit': _getProLimit(limitType),
        };
      case 'pro':
        return {
          'name': 'Enterprise',
          'limit': 'illimité',
        };
      default:
        return null;
    }
  }

  String _getProLimit(String type) {
    switch (type) {
      case 'sessions':
        return 'sessions illimitées';
      case 'salles':
        return '10 salles';
      case 'services':
        return 'services illimités';
      case 'ingénieurs':
        return '10 ingénieurs';
      default:
        return 'plus';
    }
  }
}
