import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/favorite.dart';

/// Bouton pour ajouter/supprimer des favoris.
class FavoriteButton extends StatelessWidget {
  final String targetId;
  final FavoriteType type;
  final String? targetName;
  final String? targetPhotoUrl;
  final String? targetAddress;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const FavoriteButton({
    super.key,
    required this.targetId,
    required this.type,
    this.targetName,
    this.targetPhotoUrl,
    this.targetAddress,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthAuthenticatedState) {
      return const SizedBox.shrink();
    }

    final userId = authState.user.uid;

    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, state) {
        final isFavorite = state.isFavorite(targetId);

        return IconButton(
          onPressed: () {
            context.read<FavoriteBloc>().add(
                  ToggleFavoriteEvent(
                    userId: userId,
                    targetId: targetId,
                    type: type,
                    targetName: targetName,
                    targetPhotoUrl: targetPhotoUrl,
                    targetAddress: targetAddress,
                  ),
                );
          },
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: FaIcon(
              isFavorite ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
              key: ValueKey(isFavorite),
              size: size,
              color: isFavorite
                  ? (activeColor ?? Colors.red)
                  : (inactiveColor ?? theme.colorScheme.onSurfaceVariant),
            ),
          ),
        );
      },
    );
  }
}

/// Version compacte du bouton favori (sans padding IconButton).
class FavoriteButtonCompact extends StatelessWidget {
  final String targetId;
  final FavoriteType type;
  final String? targetName;
  final String? targetPhotoUrl;
  final String? targetAddress;
  final double size;

  const FavoriteButtonCompact({
    super.key,
    required this.targetId,
    required this.type,
    this.targetName,
    this.targetPhotoUrl,
    this.targetAddress,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthAuthenticatedState) {
      return const SizedBox.shrink();
    }

    final userId = authState.user.uid;

    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, state) {
        final isFavorite = state.isFavorite(targetId);

        return GestureDetector(
          onTap: () {
            context.read<FavoriteBloc>().add(
                  ToggleFavoriteEvent(
                    userId: userId,
                    targetId: targetId,
                    type: type,
                    targetName: targetName,
                    targetPhotoUrl: targetPhotoUrl,
                    targetAddress: targetAddress,
                  ),
                );
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: FaIcon(
              isFavorite ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
              key: ValueKey(isFavorite),
              size: size,
              color: isFavorite ? Colors.red : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}
