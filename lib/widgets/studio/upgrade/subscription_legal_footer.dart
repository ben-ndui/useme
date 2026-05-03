import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uzme/l10n/app_localizations.dart';

/// Legal footer for the subscription screen.
/// Shows auto-renew notice and links to Terms of Use & Privacy Policy.
/// Required by Apple App Store (Guideline 3.1.2).
class SubscriptionLegalFooter extends StatelessWidget {
  const SubscriptionLegalFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        children: [
          Text(
            l10n.subscriptionAutoRenewNotice,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegalLink(
                label: l10n.termsOfService,
                url: 'https://uzme.app/terms',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '·',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
              _LegalLink(
                label: l10n.privacyPolicy,
                url: 'https://uzme.app/privacy',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  final String label;
  final String url;

  const _LegalLink({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
