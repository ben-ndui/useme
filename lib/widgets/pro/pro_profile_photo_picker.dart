import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Widget to choose a profile photo from account photo or portfolio images.
class ProProfilePhotoPicker extends StatelessWidget {
  final String? accountPhotoUrl;
  final List<String> portfolioUrls;
  final String? selectedUrl;
  final ValueChanged<String?> onChanged;

  const ProProfilePhotoPicker({
    super.key,
    this.accountPhotoUrl,
    required this.portfolioUrls,
    this.selectedUrl,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final candidates = <_PhotoOption>[
      if (accountPhotoUrl != null)
        _PhotoOption(url: accountPhotoUrl!, isAccount: true),
      ...portfolioUrls.map((u) => _PhotoOption(url: u, isAccount: false)),
    ];

    if (candidates.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FaIcon(FontAwesomeIcons.camera, size: 14,
                color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              l10n.proProfilePhoto,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.proProfilePhotoDesc,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: candidates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) =>
                _buildOption(theme, candidates[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildOption(ThemeData theme, _PhotoOption option) {
    final isSelected = selectedUrl == option.url;
    return GestureDetector(
      onTap: () => onChanged(isSelected ? null : option.url),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.network(
                option.url,
                width: 74,
                height: 74,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 74,
                  height: 74,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.broken_image, size: 24),
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, size: 14,
                      color: theme.colorScheme.onPrimary),
                ),
              ),
            if (option.isAccount)
              Positioned(
                top: 2,
                left: 2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const FaIcon(FontAwesomeIcons.user,
                      size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhotoOption {
  final String url;
  final bool isAccount;

  const _PhotoOption({required this.url, required this.isAccount});
}
