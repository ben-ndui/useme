import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uzme/core/models/app_user.dart';
import 'package:uzme/core/models/favorite.dart';
import 'package:uzme/core/models/pro_profile.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/widgets/favorite/favorite_button.dart';

/// Card displaying a pro profile in the discovery list.
class ProCard extends StatelessWidget {
  final AppUser user;
  final VoidCallback onTap;

  const ProCard({super.key, required this.user, required this.onTap});

  ProProfile get _profile => user.proProfile!;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildAvatar(theme),
              const SizedBox(width: 14),
              Expanded(child: _buildInfo(theme, l10n)),
              Column(
                children: [
                  FavoriteButtonCompact(
                    targetId: user.uid,
                    type: FavoriteType.pro,
                    targetName: _profile.displayName,
                    targetPhotoUrl: user.displayPhotoUrl,
                    targetAddress: _profile.city,
                  ),
                  const SizedBox(height: 4),
                  _buildRate(theme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.primaryContainer,
        image: user.displayPhotoUrl != null
            ? DecorationImage(
                image: NetworkImage(user.displayPhotoUrl!),
                fit: BoxFit.cover,
                onError: (_, __) {},
              )
            : null,
      ),
      child: Center(
        child: Text(
          _profile.displayName.isNotEmpty
              ? _profile.displayName[0].toUpperCase()
              : '?',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                _profile.displayName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_profile.isVerified) ...[
              const SizedBox(width: 6),
              FaIcon(
                FontAwesomeIcons.solidCircleCheck,
                size: 14,
                color: Colors.blue,
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _profile.proTypesLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        _buildChips(theme),
      ],
    );
  }

  Widget _buildChips(ThemeData theme) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        if (_profile.city != null && _profile.city!.isNotEmpty)
          _chip(
            theme,
            icon: FontAwesomeIcons.locationDot,
            label: _profile.city!,
          ),
        if (_profile.remote)
          _chip(
            theme,
            icon: FontAwesomeIcons.wifi,
            label: 'Remote',
            color: Colors.green,
          ),
        if (_profile.rating != null)
          _chip(
            theme,
            icon: FontAwesomeIcons.solidStar,
            label: _profile.rating!.toStringAsFixed(1),
            color: Colors.amber,
          ),
      ],
    );
  }

  Widget _chip(
    ThemeData theme, {
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final c = color ?? theme.colorScheme.outline;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon, size: 11, color: c),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: c),
          ),
        ),
      ],
    );
  }

  Widget _buildRate(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _profile.formattedRate,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
