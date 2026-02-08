import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:useme/core/models/studio_invitation.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Success state after artist creation with shareable invitation code
class ArtistCreationSuccess extends StatelessWidget {
  final StudioInvitation invitation;
  final String? studioName;
  final VoidCallback onDone;

  const ArtistCreationSuccess({
    super.key,
    required this.invitation,
    required this.studioName,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: FaIcon(FontAwesomeIcons.circleCheck, size: 40, color: Colors.green),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Artiste créé !',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Partagez ce code avec l\'artiste pour qu\'il rejoigne votre studio',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: 24),
        _buildCodeDisplay(context, theme),
        const SizedBox(height: 32),
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildCodeDisplay(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            invitation.code,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: invitation.code));
              AppSnackBar.success(context, 'Code copié !');
            },
            icon: const FaIcon(FontAwesomeIcons.copy, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: () => _shareInvitation(),
          icon: const FaIcon(FontAwesomeIcons.shareNodes, size: 14),
          label: const Text('Partager'),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: onDone,
          child: const Text('Terminé'),
        ),
      ],
    );
  }

  void _shareInvitation() {
    final code = invitation.code;
    final studio = studioName ?? 'notre studio';
    final message = '''
Rejoins $studio sur UZME !

Utilise ce code d'invitation : $code

Télécharge l'app UZME et entre ce code pour te connecter au studio.
''';

    SharePlus.instance.share(ShareParams(text: message, subject: 'Invitation UZME - $studio'));
  }
}
