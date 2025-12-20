import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// About screen showing app info and legal links.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('À propos')),
      body: ListView(
        children: [
          const SizedBox(height: 32),

          // App icon and name
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.music,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Use Me',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'La plateforme des studios',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Version $_version ($_buildNumber)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const Divider(),

          // Legal section
          _buildSectionHeader(context, 'Informations légales'),
          _buildTile(
            context,
            icon: FontAwesomeIcons.fileContract,
            title: 'Conditions d\'utilisation',
            onTap: () => _openUrl('https://useme.app/terms'),
          ),
          _buildTile(
            context,
            icon: FontAwesomeIcons.shieldHalved,
            title: 'Politique de confidentialité',
            onTap: () => _openUrl('https://useme.app/privacy'),
          ),
          _buildTile(
            context,
            icon: FontAwesomeIcons.scaleBalanced,
            title: 'Mentions légales',
            onTap: () => _openUrl('https://useme.app/legal'),
          ),

          const Divider(height: 32),

          // Support section
          _buildSectionHeader(context, 'Support'),
          _buildTile(
            context,
            icon: FontAwesomeIcons.circleQuestion,
            title: 'Centre d\'aide',
            onTap: () => _openUrl('https://useme.app/help'),
          ),
          _buildTile(
            context,
            icon: FontAwesomeIcons.envelope,
            title: 'Nous contacter',
            subtitle: 'support@useme.app',
            onTap: () => _openUrl('mailto:support@useme.app'),
          ),

          const Divider(height: 32),

          // Social section
          _buildSectionHeader(context, 'Suivez-nous'),
          _buildTile(
            context,
            icon: FontAwesomeIcons.instagram,
            title: 'Instagram',
            subtitle: '@useme.app',
            onTap: () => _openUrl('https://instagram.com/useme.app'),
          ),

          const SizedBox(height: 32),

          // Copyright
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '© ${DateTime.now().year} Use Me. Tous droits réservés.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: FaIcon(icon, size: 18, color: theme.colorScheme.primary),
        ),
      ),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle, style: theme.textTheme.bodySmall)
          : null,
      trailing: FaIcon(
        FontAwesomeIcons.arrowUpRightFromSquare,
        size: 14,
        color: theme.colorScheme.outline,
      ),
      onTap: onTap,
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
