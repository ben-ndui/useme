import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/config/responsive_config.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/stripe_config.dart';
import 'package:useme/core/services/encryption_service.dart';
import 'package:useme/core/services/stripe_config_service.dart';
import 'package:useme/widgets/common/app_loader.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Écran DevMaster pour configurer les clés Stripe
/// Accessible UNIQUEMENT aux utilisateurs avec hasDevMasterAccess = true
class StripeConfigScreen extends StatefulWidget {
  const StripeConfigScreen({super.key});

  @override
  State<StripeConfigScreen> createState() => _StripeConfigScreenState();
}

class _StripeConfigScreenState extends State<StripeConfigScreen> {
  late StripeConfigService _service;
  bool _isLoading = true;
  StripeConfig? _config;

  final _publishableKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();
  final _webhookSecretController = TextEditingController();

  bool _isLiveMode = false;
  bool _showSecretKey = false;
  bool _showWebhookSecret = false;
  bool _isSaving = false;

  // Price IDs
  final _proMonthlyController = TextEditingController();
  final _proYearlyController = TextEditingController();
  final _enterpriseMonthlyController = TextEditingController();
  final _enterpriseYearlyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      final encryption = EncryptionService();
      await encryption.initialize(authState.user.uid);
      _service = StripeConfigService(encryption: encryption);
      await _loadConfig();
    }
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);

    try {
      final config = await _service.getConfig();
      if (config != null) {
        _config = config;
        _publishableKeyController.text = config.publishableKey;
        // Note: Les clés secrètes ne sont pas pré-remplies pour des raisons de sécurité
        _isLiveMode = config.isLiveMode;

        // Price IDs
        _proMonthlyController.text = config.priceIds['pro_monthly'] ?? '';
        _proYearlyController.text = config.priceIds['pro_yearly'] ?? '';
        _enterpriseMonthlyController.text =
            config.priceIds['enterprise_monthly'] ?? '';
        _enterpriseYearlyController.text =
            config.priceIds['enterprise_yearly'] ?? '';
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        AppSnackBar.error(context, l10n.adminStripeLoadError(e.toString()));
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _publishableKeyController.dispose();
    _secretKeyController.dispose();
    _webhookSecretController.dispose();
    _proMonthlyController.dispose();
    _proYearlyController.dispose();
    _enterpriseMonthlyController.dispose();
    _enterpriseYearlyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final authState = context.read<AuthBloc>().state;

    // Vérifier l'accès DevMaster
    if (authState is AuthAuthenticatedState) {
      final user = authState.user;
      if (user is! AppUser || !user.hasDevMasterAccess) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.adminAccessDenied)),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.lock,
                    size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(l10n.adminDevMasterRequired,
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  l10n.adminDevMasterOnly,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),
        );
      }
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.adminStripeConfig)),
        body: const AppLoader(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminStripeConfig),
        actions: [
          if (_config != null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isLiveMode
                    ? Colors.green.withValues(alpha: 0.15)
                    : Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    _isLiveMode
                        ? FontAwesomeIcons.circleCheck
                        : FontAwesomeIcons.flask,
                    size: 14,
                    color: _isLiveMode ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isLiveMode ? 'Live' : 'Test',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: _isLiveMode ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth),
          child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Warning banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const FaIcon(FontAwesomeIcons.triangleExclamation,
                    size: 20, color: Colors.amber),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.adminStripeKeysWarning,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Mode switch
          _buildSection(l10n.adminMode, [
            SwitchListTile(
              title: Text(l10n.adminProductionMode),
              subtitle: Text(_isLiveMode
                  ? l10n.adminLivePayments
                  : l10n.adminTestMode),
              value: _isLiveMode,
              onChanged: (v) => setState(() => _isLiveMode = v),
              secondary: FaIcon(
                _isLiveMode ? FontAwesomeIcons.rocket : FontAwesomeIcons.flask,
                color: _isLiveMode ? Colors.green : Colors.orange,
              ),
            ),
          ]),
          const SizedBox(height: 24),

          // API Keys
          _buildSection(l10n.adminApiKeys, [
            TextField(
              controller: _publishableKeyController,
              decoration: InputDecoration(
                labelText: l10n.adminPublishableKey,
                hintText: _isLiveMode ? 'pk_live_...' : 'pk_test_...',
                prefixIcon: const Icon(Icons.key),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _secretKeyController,
              obscureText: !_showSecretKey,
              decoration: InputDecoration(
                labelText: l10n.adminSecretKey,
                hintText: _isLiveMode ? 'sk_live_...' : 'sk_test_...',
                helperText: l10n.adminKeepCurrentKey,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: FaIcon(
                    _showSecretKey
                        ? FontAwesomeIcons.eyeSlash
                        : FontAwesomeIcons.eye,
                    size: 16,
                  ),
                  onPressed: () =>
                      setState(() => _showSecretKey = !_showSecretKey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _webhookSecretController,
              obscureText: !_showWebhookSecret,
              decoration: InputDecoration(
                labelText: l10n.adminWebhookSecret,
                hintText: 'whsec_...',
                helperText: l10n.adminKeepCurrentSecret,
                prefixIcon: const Icon(Icons.webhook),
                suffixIcon: IconButton(
                  icon: FaIcon(
                    _showWebhookSecret
                        ? FontAwesomeIcons.eyeSlash
                        : FontAwesomeIcons.eye,
                    size: 16,
                  ),
                  onPressed: () =>
                      setState(() => _showWebhookSecret = !_showWebhookSecret),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 24),

          // Price IDs
          _buildSection(l10n.adminStripePriceIds, [
            Text(
              l10n.adminStripePriceIdsHelp,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _proMonthlyController,
                    decoration: InputDecoration(
                      labelText: l10n.adminProMonthly,
                      hintText: 'price_...',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _proYearlyController,
                    decoration: InputDecoration(
                      labelText: l10n.adminProYearly,
                      hintText: 'price_...',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _enterpriseMonthlyController,
                    decoration: InputDecoration(
                      labelText: l10n.adminEnterpriseMonthly,
                      hintText: 'price_...',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _enterpriseYearlyController,
                    decoration: InputDecoration(
                      labelText: l10n.adminEnterpriseYearly,
                      hintText: 'price_...',
                    ),
                  ),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 32),

          // Save button
          FilledButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const FaIcon(FontAwesomeIcons.floppyDisk, size: 16),
            label: Text(_isSaving ? l10n.adminSaving : l10n.save),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          const SizedBox(height: 16),

          // Status info
          if (_config != null && _config!.updatedAt != null)
            Center(
              child: Text(
                l10n.adminLastUpdated(_formatDate(_config!.updatedAt!)),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall
              ?.copyWith(color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _save() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;

    final l10n = AppLocalizations.of(context)!;

    // Validation
    final publishableKey = _publishableKeyController.text.trim();
    if (publishableKey.isEmpty) {
      AppSnackBar.error(context, l10n.adminPublicKeyRequired);
      return;
    }

    if (!publishableKey.startsWith('pk_')) {
      AppSnackBar.error(context, l10n.adminInvalidPublicKeyFormat);
      return;
    }

    // Vérifier cohérence mode/clé
    final isTestKey = publishableKey.startsWith('pk_test_');
    if (_isLiveMode && isTestKey) {
      AppSnackBar.error(context, l10n.adminTestKeyInProduction);
      return;
    }
    if (!_isLiveMode && !isTestKey) {
      AppSnackBar.error(context, l10n.adminProdKeyInTestMode);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final priceIds = <String, String>{};
      if (_proMonthlyController.text.trim().isNotEmpty) {
        priceIds['pro_monthly'] = _proMonthlyController.text.trim();
      }
      if (_proYearlyController.text.trim().isNotEmpty) {
        priceIds['pro_yearly'] = _proYearlyController.text.trim();
      }
      if (_enterpriseMonthlyController.text.trim().isNotEmpty) {
        priceIds['enterprise_monthly'] =
            _enterpriseMonthlyController.text.trim();
      }
      if (_enterpriseYearlyController.text.trim().isNotEmpty) {
        priceIds['enterprise_yearly'] =
            _enterpriseYearlyController.text.trim();
      }

      final config = (_config ?? const StripeConfig()).copyWith(
        publishableKey: publishableKey,
        isLiveMode: _isLiveMode,
        priceIds: priceIds,
      );

      await _service.saveConfig(
        config: config,
        updatedBy: authState.user.uid,
        secretKey: _secretKeyController.text.trim().isNotEmpty
            ? _secretKeyController.text.trim()
            : null,
        webhookSecret: _webhookSecretController.text.trim().isNotEmpty
            ? _webhookSecretController.text.trim()
            : null,
      );

      if (mounted) {
        AppSnackBar.success(context, l10n.adminStripeConfigSaved);
        // Clear secret fields after save
        _secretKeyController.clear();
        _webhookSecretController.clear();
        await _loadConfig();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, l10n.errorWithMessage(e.toString()));
      }
    }

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }
}
