import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uzme/l10n/app_localizations.dart';

/// Photos section of the session tracking screen
class SessionTrackingPhotos extends StatelessWidget {
  final List<String> photos;
  final VoidCallback onAddPhoto;

  const SessionTrackingPhotos({
    super.key,
    required this.photos,
    required this.onAddPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.photos,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (photos.isNotEmpty) ...[
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: photos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => _buildPhotoTile(
                    context,
                    photos[index],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: onAddPhoto,
              icon: const FaIcon(FontAwesomeIcons.camera, size: 16),
              label: Text(l10n.addPhoto),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoTile(BuildContext context, String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 100,
          height: 100,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.broken_image),
        ),
      ),
    );
  }
}
