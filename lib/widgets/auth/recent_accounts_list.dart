import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uzme/core/models/recent_account.dart';
import 'package:uzme/l10n/app_localizations.dart';

/// Displays a list of recent accounts for quick re-login.
class RecentAccountsList extends StatelessWidget {
  final List<RecentAccount> accounts;
  final void Function(RecentAccount account) onAccountSelected;
  final void Function(RecentAccount account) onAccountRemoved;
  final VoidCallback onUseAnotherAccount;

  const RecentAccountsList({
    super.key,
    required this.accounts,
    required this.onAccountSelected,
    required this.onAccountRemoved,
    required this.onUseAnotherAccount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildHeader(context, l10n),
          const SizedBox(height: 24),
          ...accounts.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AccountTile(
                  account: a,
                  onTap: () => onAccountSelected(a),
                  onRemove: () => onAccountRemoved(a),
                ),
              )),
          const SizedBox(height: 16),
          _buildAnotherAccountButton(context, l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          'UZME',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : cs.onSurface,
            letterSpacing: 25,
          ),
        ),
        Text(
          l10n.chooseAccount,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white.withValues(alpha: 0.75) : cs.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildAnotherAccountButton(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final btn = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.15) : cs.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.userPlus,
              size: 14,
              color: isDark ? Colors.white.withValues(alpha: 0.8) : cs.onSurfaceVariant),
          const SizedBox(width: 10),
          Text(
            l10n.useAnotherAccount,
            style: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.8) : cs.onSurface.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onUseAnotherAccount,
      child: isDark
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: btn,
              ),
            )
          : ClipRRect(borderRadius: BorderRadius.circular(16), child: btn),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final RecentAccount account;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _AccountTile({
    required this.account,
    required this.onTap,
    required this.onRemove,
  });

  void _confirmRemove(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.removeAccount),
        content: Text(l10n.removeAccountConfirm(account.displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onRemove();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final initial = account.displayName.isNotEmpty
        ? account.displayName[0].toUpperCase()
        : '?';

    final tile = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.1) : cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.18) : cs.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.2) : cs.surfaceContainerHighest,
            backgroundImage: account.photoUrl != null ? NetworkImage(account.photoUrl!) : null,
            child: account.photoUrl == null
                ? Text(initial,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : cs.onSurface,
                    ))
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.displayName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : cs.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  account.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white.withValues(alpha: 0.6) : cs.onSurface.withValues(alpha: 0.55),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (account.biometricEnabled) ...[
            _BiometricBadge(isDark: isDark, cs: cs),
            const SizedBox(width: 6),
          ],
          _ProviderBadge(provider: account.provider, l10n: l10n),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _confirmRemove(context, l10n),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: FaIcon(
                FontAwesomeIcons.xmark,
                size: 14,
                color: isDark ? Colors.white.withValues(alpha: 0.4) : cs.onSurface.withValues(alpha: 0.35),
              ),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: isDark
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: tile,
              ),
            )
          : ClipRRect(borderRadius: BorderRadius.circular(16), child: tile),
    );
  }
}

class _BiometricBadge extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const _BiometricBadge({required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? Colors.white.withValues(alpha: 0.85) : cs.primary;
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.12)
            : cs.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: FaIcon(FontAwesomeIcons.fingerprint, size: 12, color: color),
    );
  }
}

class _ProviderBadge extends StatelessWidget {
  final String provider;
  final AppLocalizations l10n;

  const _ProviderBadge({required this.provider, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final (icon, label) = switch (provider) {
      'google' => (FontAwesomeIcons.google, 'Google'),
      'apple' => (FontAwesomeIcons.apple, 'Apple'),
      _ => (FontAwesomeIcons.lock, l10n.passwordHint),
    };
    final fgColor = isDark ? Colors.white.withValues(alpha: 0.7) : cs.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.12) : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 11, color: fgColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: fgColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
