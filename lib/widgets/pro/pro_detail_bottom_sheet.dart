import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/favorite.dart';
import 'package:useme/core/models/pro_profile.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/screens/shared/pro/pro_booking_screen.dart';
import 'package:useme/screens/shared/pro/pro_profile_view_screen.dart';
import 'package:useme/widgets/favorite/favorite_button.dart';

/// Bottom sheet showing detailed pro profile info.
class ProDetailBottomSheet extends StatelessWidget {
  final AppUser user;

  const ProDetailBottomSheet({super.key, required this.user});

  ProProfile get _profile => user.proProfile!;

  static void show(BuildContext context, AppUser user) {
    final authBloc = context.read<AuthBloc>();
    final messagingBloc = context.read<MessagingBloc>();
    final favoriteBloc = context.read<FavoriteBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider.value(value: messagingBloc),
          BlocProvider.value(value: favoriteBloc),
        ],
        child: ProDetailBottomSheet(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(theme),
            _buildHeader(theme),
            if (_profile.bio != null) _buildBio(theme),
            _buildStats(theme, l10n),
            _buildTags(theme, l10n),
            if (_profile.portfolioUrls.isNotEmpty) _buildPortfolio(theme, l10n),
            if (_profile.hasPaymentMethods) _buildPaymentMethods(theme, l10n),
            _buildActions(context, theme, l10n),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
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

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildAvatar(theme),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _profile.displayName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_profile.isVerified)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: FaIcon(
                          FontAwesomeIcons.solidCircleCheck,
                          size: 18,
                          color: Colors.blue,
                        ),
                      ),
                    FavoriteButtonCompact(
                      targetId: user.uid,
                      type: FavoriteType.pro,
                      targetName: _profile.displayName,
                      targetPhotoUrl: user.photoURL,
                      targetAddress: _profile.city,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _profile.proTypesLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (_profile.city != null)
                      _badge(
                        theme,
                        icon: FontAwesomeIcons.locationDot,
                        label: _profile.city!,
                        color: theme.colorScheme.outline,
                      ),
                    if (_profile.remote)
                      _badge(
                        theme,
                        icon: FontAwesomeIcons.wifi,
                        label: 'Remote',
                        color: Colors.green,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.primaryContainer,
        image: user.photoURL != null
            ? DecorationImage(
                image: NetworkImage(user.photoURL!),
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
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBio(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        _profile.bio!,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildStats(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _statChip(
            theme,
            icon: FontAwesomeIcons.euroSign,
            value: _profile.hasRate
                ? _profile.formattedRate
                : l10n.proDetailOnQuote,
          ),
          if (_profile.rating != null) ...[
            const SizedBox(width: 12),
            _statChip(
              theme,
              icon: FontAwesomeIcons.solidStar,
              iconColor: Colors.amber,
              value:
                  '${_profile.rating!.toStringAsFixed(1)} (${_profile.reviewCount ?? 0})',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTags(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        spacing: 8,
        children: [
          if (_profile.specialties.isNotEmpty)
            _tagSection(theme, l10n.proDetailSpecialties, _profile.specialties),
          if (_profile.genres.isNotEmpty)
            _tagSection(theme, l10n.proDetailGenres, _profile.genres),
          if (_profile.instruments.isNotEmpty)
            _tagSection(
                theme, l10n.proDetailInstruments, _profile.instruments),
          if (_profile.daws.isNotEmpty)
            _tagSection(theme, l10n.proDetailDaws, _profile.daws),
        ],
      ),
    );
  }

  Widget _tagSection(ThemeData theme, String title, List<String> tags) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags
                .map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolio(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.proDetailPortfolio,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _profile.portfolioUrls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _profile.portfolioUrls[i],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.broken_image, size: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.proDetailPaymentMethods,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _profile.enabledPaymentMethods
                .map((m) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        m.type.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(
      BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: BlocListener<MessagingBloc, MessagingState>(
        listenWhen: (prev, curr) => curr is ChatOpenState,
        listener: (context, state) {
          if (state is ChatOpenState) {
            Navigator.pop(context);
            context.push('${AppRoutes.conversations}/${state.conversation.id}');
          }
        },
        child: Column(
          children: [
            FilledButton.icon(
              onPressed: () => _startConversation(context, l10n),
              icon: const FaIcon(FontAwesomeIcons.solidMessage, size: 16),
              label: Text(l10n.proDetailContact),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProBookingScreen(proUser: user),
                  ),
                );
              },
              icon: const FaIcon(FontAwesomeIcons.calendarPlus, size: 16),
              label: Text(l10n.proBookingSend),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                foregroundColor: Theme.of(context).colorScheme.onTertiary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _FullProfileWrapper(user: user),
                  ),
                );
              },
              icon: const FaIcon(FontAwesomeIcons.user, size: 14),
              label: Text(l10n.seeFullProfile),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startConversation(BuildContext context, AppLocalizations l10n) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;

    final currentUser = authState.user as AppUser;
    final currentUserInfo = ParticipantInfo(
      name: currentUser.displayName ?? currentUser.name ?? l10n.user,
      avatarUrl: currentUser.photoURL,
      role: currentUser.role.useMeLabel,
    );

    final otherUserInfo = ParticipantInfo(
      name: _profile.displayName,
      avatarUrl: user.photoURL,
      role: user.role.useMeLabel,
    );

    context.read<MessagingBloc>().add(StartPrivateConversationEvent(
          otherUserId: user.uid,
          otherUserInfo: otherUserInfo,
          currentUserInfo: currentUserInfo,
        ));
  }

  Widget _badge(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
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

  Widget _statChip(
    ThemeData theme, {
    required IconData icon,
    required String value,
    Color? iconColor,
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
          FaIcon(icon, size: 14, color: iconColor ?? theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Wraps [ProProfileViewScreen] with required BlocProviders
/// when navigating from a bottom sheet context.
class _FullProfileWrapper extends StatelessWidget {
  final AppUser user;

  const _FullProfileWrapper({required this.user});

  @override
  Widget build(BuildContext context) {
    return ProProfileViewScreen(user: user);
  }
}
