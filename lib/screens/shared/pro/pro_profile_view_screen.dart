import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:uzme/config/responsive_config.dart';
import 'package:uzme/core/models/app_user.dart';
import 'package:uzme/core/models/favorite.dart';
import 'package:uzme/core/models/payment_method.dart';
import 'package:uzme/core/models/pro_profile.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/screens/shared/pro/pro_booking_screen.dart';
import 'package:uzme/widgets/favorite/favorite_button.dart';

/// Full-screen pro profile view for browsing.
class ProProfileViewScreen extends StatelessWidget {
  final AppUser user;

  const ProProfileViewScreen({super.key, required this.user});

  ProProfile get _profile => user.proProfile!;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_profile.displayName),
        actions: [
          if (_profile.isVerified)
            Padding(
              padding: const EdgeInsets.only(right: 4),
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
            targetPhotoUrl: user.displayPhotoUrl,
            targetAddress: _profile.city,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth),
          child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          _buildProfileHeader(theme),
          const SizedBox(height: 16),
          _buildTypeBadges(theme),
          if (_profile.bio != null) _buildSection(theme, null, _profile.bio!),
          _buildInfoRow(theme, l10n),
          if (_profile.specialties.isNotEmpty)
            _buildTagsSection(theme, l10n.proDetailSpecialties, _profile.specialties),
          if (_profile.genres.isNotEmpty)
            _buildTagsSection(theme, l10n.proDetailGenres, _profile.genres),
          if (_profile.instruments.isNotEmpty)
            _buildTagsSection(theme, l10n.proDetailInstruments, _profile.instruments),
          if (_profile.daws.isNotEmpty)
            _buildTagsSection(theme, l10n.proDetailDaws, _profile.daws),
          if (_profile.portfolioUrls.isNotEmpty)
            _buildPortfolioSection(theme, l10n),
          if (_profile.hasPaymentMethods)
            _buildPaymentMethodsSection(theme, l10n),
        ],
      ),
        ),
      ),
      bottomNavigationBar: _buildContactBar(context, theme, l10n),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
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
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profile.displayName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _profile.proTypesLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (_profile.city != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      FaIcon(FontAwesomeIcons.locationDot,
                          size: 12, color: theme.colorScheme.outline),
                      const SizedBox(width: 6),
                      Text(
                        _profile.city!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadges(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_profile.remote)
            _badge(theme,
                icon: FontAwesomeIcons.wifi,
                label: 'Remote',
                color: Colors.green),
          if (_profile.rating != null)
            _badge(theme,
                icon: FontAwesomeIcons.solidStar,
                label:
                    '${_profile.rating!.toStringAsFixed(1)} (${_profile.reviewCount ?? 0})',
                color: Colors.amber),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _statCard(
            theme,
            icon: FontAwesomeIcons.euroSign,
            label: l10n.proDetailRate,
            value: _profile.hasRate
                ? _profile.formattedRate
                : l10n.proDetailOnQuote,
          ),
          const SizedBox(width: 12),
          if (_profile.remote)
            _statCard(
              theme,
              icon: FontAwesomeIcons.wifi,
              label: l10n.proDetailRemote,
              value: '✓',
            ),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String? title, String content) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(
      ThemeData theme, String title, List<String> tags) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
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

  Widget _buildPortfolioSection(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.proDetailPortfolio,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _profile.portfolioUrls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _profile.portfolioUrls[i],
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 120,
                    height: 120,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.broken_image, size: 32),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection(
      ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.proDetailPaymentMethods,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _profile.enabledPaymentMethods
                .map((m) => _paymentBadge(theme, m))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _paymentBadge(ThemeData theme, PaymentMethod method) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        method.type.label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.tertiary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildContactBar(
      BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profile.hasRate
                      ? _profile.formattedRate
                      : l10n.proDetailOnQuote,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _profile.proTypesLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProBookingScreen(proUser: user),
              ),
            ),
            icon: const FaIcon(FontAwesomeIcons.calendarPlus, size: 14),
            label: Text(l10n.proBookingSend),
            style: FilledButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.outlined(
            onPressed: () => _startConversation(context, l10n),
            icon: const FaIcon(FontAwesomeIcons.solidMessage, size: 14),
          ),
        ],
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
      avatarUrl: user.displayPhotoUrl,
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

  Widget _statCard(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FaIcon(icon, size: 14, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 2),
            Text(value,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
