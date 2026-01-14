import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/discovered_studio.dart';
import 'package:useme/core/models/favorite.dart';
import 'package:useme/core/models/studio_profile.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/favorite/favorite_button.dart';

/// Bottom sheet showing studio details for authenticated artists
class StudioDetailBottomSheet extends StatelessWidget {
  final DiscoveredStudio studio;

  const StudioDetailBottomSheet({super.key, required this.studio});

  static void show(BuildContext context, DiscoveredStudio studio) {
    final authBloc = context.read<AuthBloc>();
    final favoriteBloc = context.read<FavoriteBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider.value(value: favoriteBloc),
        ],
        child: StudioDetailBottomSheet(studio: studio),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(theme),
          _buildHeader(theme, l10n),
          if (studio.address != null) _buildAddress(theme),
          _buildStats(theme, l10n),
          if (studio.services.isNotEmpty) _buildServices(theme, l10n),
          _buildActions(context, theme, l10n),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildStudioAvatar(theme),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        studio.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    FavoriteButton(
                      targetId: studio.id,
                      type: FavoriteType.studio,
                      targetName: studio.name,
                      targetPhotoUrl: studio.photoUrl,
                      targetAddress: studio.address,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (studio.isPartner) _buildPartnerBadge(theme, l10n),
                    _buildStudioTypeBadge(theme, l10n),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudioAvatar(ThemeData theme) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.primaryContainer,
        image: studio.photoUrl != null
            ? DecorationImage(
                image: NetworkImage(studio.photoUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: studio.photoUrl == null
          ? Center(
              child: FaIcon(
                FontAwesomeIcons.buildingUser,
                color: theme.colorScheme.primary,
                size: 32,
              ),
            )
          : null,
    );
  }

  Widget _buildPartnerBadge(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(FontAwesomeIcons.solidCircleCheck, size: 12, color: Colors.green),
          const SizedBox(width: 6),
          Text(
            l10n.partner,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudioTypeBadge(ThemeData theme, AppLocalizations l10n) {
    final (icon, label, color) = switch (studio.studioType) {
      StudioType.pro => (FontAwesomeIcons.building, l10n.studioTypePro, Colors.purple),
      StudioType.independent => (FontAwesomeIcons.houseUser, l10n.studioTypeIndependent, Colors.blue),
      StudioType.amateur => (FontAwesomeIcons.house, l10n.studioTypeAmateur, Colors.orange),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddress(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          FaIcon(FontAwesomeIcons.locationDot, size: 14, color: theme.colorScheme.outline),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              studio.address!,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (studio.rating != null) ...[
            _buildStatChip(
              theme,
              icon: FontAwesomeIcons.solidStar,
              iconColor: Colors.amber,
              value: studio.rating!.toStringAsFixed(1),
              label: '(${studio.reviewCount ?? 0})',
            ),
            const SizedBox(width: 12),
          ],
          _buildStatChip(
            theme,
            icon: FontAwesomeIcons.locationArrow,
            iconColor: theme.colorScheme.primary,
            value: studio.formattedDistance,
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          ],
        ],
      ),
    );
  }

  Widget _buildServices(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: studio.services.take(5).map((service) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              service,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: studio.isPartner
          ? FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.push(
                  '/artist/request?studioId=${studio.id}&studioName=${Uri.encodeComponent(studio.name)}',
                );
              },
              icon: const FaIcon(FontAwesomeIcons.calendarPlus, size: 16),
              label: Text(l10n.book),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            )
          : OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const FaIcon(FontAwesomeIcons.xmark, size: 16),
              label: Text(l10n.notAvailable),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
    );
  }
}
