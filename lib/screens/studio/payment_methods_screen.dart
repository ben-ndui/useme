import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/payment_method.dart';
import 'package:useme/core/services/payment_config_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/app_loader.dart';

/// Écran de configuration des moyens de paiement pour un studio
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final PaymentConfigService _paymentService = PaymentConfigService();

  StudioPaymentConfig? _config;
  bool _isLoading = true;
  String? _studioId;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;

    _studioId = authState.user.uid;
    final config = await _paymentService.getPaymentConfig(_studioId!);

    // Initialiser avec tous les types si vide
    if (config.methods.isEmpty) {
      final defaultMethods = PaymentMethodType.values
          .where((t) => t != PaymentMethodType.other)
          .map((t) => PaymentMethod(type: t, isEnabled: false))
          .toList();

      setState(() {
        _config = config.copyWith(methods: defaultMethods);
        _isLoading = false;
      });
    } else {
      setState(() {
        _config = config;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentMethods)),
      body: _isLoading
          ? const AppLoader()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildInfoCard(theme, l10n),
                const SizedBox(height: 24),
                _buildDepositSection(theme, l10n),
                const SizedBox(height: 24),
                _buildPaymentMethodsSection(theme, l10n),
                const SizedBox(height: 24),
                _buildCancellationPolicySection(theme, l10n),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.creditCard,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.configurePayments,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.paymentOptionsDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.defaultDeposit, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          l10n.depositPercentDescription,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _config?.defaultDepositPercent ?? 30,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${(_config?.defaultDepositPercent ?? 30).toInt()}%',
                onChanged: (value) {
                  setState(() {
                    _config = _config?.copyWith(defaultDepositPercent: value);
                  });
                },
                onChangeEnd: (value) => _saveDepositPercent(value),
              ),
            ),
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(_config?.defaultDepositPercent ?? 30).toInt()}%',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.acceptedPaymentMethods, style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        ...(_config?.methods ?? []).map((method) => _buildPaymentMethodCard(theme, method, l10n)),
      ],
    );
  }

  Widget _buildCancellationPolicySection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.cancellationPolicy, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          l10n.cancellationPolicyDescription,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 16),
        RadioGroup<CancellationPolicy>(
          groupValue: _config?.cancellationPolicy ?? CancellationPolicy.moderate,
          onChanged: (value) => _updateCancellationPolicy(value!),
          child: Column(
            children: CancellationPolicy.values.map((policy) => RadioListTile<CancellationPolicy>(
                  title: Text(policy.label),
                  subtitle: Text(
                    policy.description,
                    style: theme.textTheme.bodySmall,
                  ),
                  value: policy,
                  contentPadding: EdgeInsets.zero,
                )).toList(),
          ),
        ),
        if (_config?.cancellationPolicy == CancellationPolicy.custom) ...[
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _config?.customCancellationTerms,
            decoration: InputDecoration(
              labelText: l10n.customCancellationTerms,
              hintText: l10n.customCancellationHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
            onChanged: _updateCustomCancellationTerms,
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentMethodCard(ThemeData theme, PaymentMethod method, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec switch
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: method.isEnabled
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: FaIcon(
                      _getIconForType(method.type),
                      size: 16,
                      color: method.isEnabled
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    method.type.label,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Switch.adaptive(
                  value: method.isEnabled,
                  onChanged: (enabled) => _toggleMethod(method.type, enabled),
                ),
              ],
            ),
            // Champs de configuration (visibles seulement si activé)
            if (method.isEnabled) ...[
              const SizedBox(height: 16),
              TextFormField(
                initialValue: method.details,
                decoration: InputDecoration(
                  labelText: _getDetailsLabelForType(method.type, l10n),
                  hintText: _getDetailsHintForType(method.type),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => _updateMethodDetails(method.type, value),
              ),
              // Champs supplémentaires pour virement bancaire
              if (method.type == PaymentMethodType.bankTransfer) ...[
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: method.bic,
                  decoration: InputDecoration(
                    labelText: l10n.bic,
                    hintText: 'BNPAFRPP',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => _updateBankDetails(
                    type: method.type,
                    bic: value,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: method.accountHolder,
                  decoration: InputDecoration(
                    labelText: l10n.accountHolder,
                    hintText: 'Studio XYZ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => _updateBankDetails(
                    type: method.type,
                    accountHolder: value,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: method.bankName,
                  decoration: InputDecoration(
                    labelText: l10n.bankName,
                    hintText: 'BNP Paribas',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => _updateBankDetails(
                    type: method.type,
                    bankName: value,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                initialValue: method.instructions,
                decoration: InputDecoration(
                  labelText: l10n.instructionsOptional,
                  hintText: l10n.instructionsHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
                onChanged: (value) =>
                    _updateMethodInstructions(method.type, value),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.cash:
        return FontAwesomeIcons.moneyBill;
      case PaymentMethodType.bankTransfer:
        return FontAwesomeIcons.buildingColumns;
      case PaymentMethodType.paypal:
        return FontAwesomeIcons.paypal;
      case PaymentMethodType.card:
        return FontAwesomeIcons.creditCard;
      case PaymentMethodType.other:
        return FontAwesomeIcons.ellipsis;
    }
  }

  String _getDetailsLabelForType(PaymentMethodType type, AppLocalizations l10n) {
    switch (type) {
      case PaymentMethodType.bankTransfer:
        return l10n.iban;
      case PaymentMethodType.paypal:
        return l10n.paypalEmail;
      case PaymentMethodType.card:
        return l10n.information;
      default:
        return l10n.details;
    }
  }

  String _getDetailsHintForType(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.bankTransfer:
        return 'FR76 1234 5678 9012 3456 7890 123';
      case PaymentMethodType.paypal:
        return 'paiement@monstudio.com';
      case PaymentMethodType.cash:
        return 'Ex: À régler le jour de la session';
      default:
        return '';
    }
  }

  Future<void> _toggleMethod(PaymentMethodType type, bool enabled) async {
    if (_studioId == null) return;

    // Update local state
    final methods = _config!.methods.map((m) {
      if (m.type == type) return m.copyWith(isEnabled: enabled);
      return m;
    }).toList();

    setState(() {
      _config = _config!.copyWith(methods: methods);
    });

    // Save to Firestore
    await _paymentService.updatePaymentConfig(
      studioId: _studioId!,
      config: _config!,
    );
  }

  Future<void> _updateMethodDetails(PaymentMethodType type, String details) async {
    if (_studioId == null) return;

    final methods = _config!.methods.map((m) {
      if (m.type == type) return m.copyWith(details: details);
      return m;
    }).toList();

    _config = _config!.copyWith(methods: methods);

    // Debounce save
    await Future.delayed(const Duration(milliseconds: 500));
    await _paymentService.updatePaymentConfig(
      studioId: _studioId!,
      config: _config!,
    );
  }

  Future<void> _updateMethodInstructions(
      PaymentMethodType type, String instructions) async {
    if (_studioId == null) return;

    final methods = _config!.methods.map((m) {
      if (m.type == type) return m.copyWith(instructions: instructions);
      return m;
    }).toList();

    _config = _config!.copyWith(methods: methods);

    // Debounce save
    await Future.delayed(const Duration(milliseconds: 500));
    await _paymentService.updatePaymentConfig(
      studioId: _studioId!,
      config: _config!,
    );
  }

  Future<void> _saveDepositPercent(double percent) async {
    if (_studioId == null) return;

    await _paymentService.updatePaymentConfig(
      studioId: _studioId!,
      config: _config!.copyWith(defaultDepositPercent: percent),
    );
  }

  Future<void> _updateCancellationPolicy(CancellationPolicy policy) async {
    if (_studioId == null) return;

    setState(() {
      _config = _config!.copyWith(cancellationPolicy: policy);
    });

    await _paymentService.updatePaymentConfig(
      studioId: _studioId!,
      config: _config!,
    );
  }

  Future<void> _updateCustomCancellationTerms(String terms) async {
    if (_studioId == null) return;

    _config = _config!.copyWith(customCancellationTerms: terms);

    await Future.delayed(const Duration(milliseconds: 500));
    await _paymentService.updatePaymentConfig(
      studioId: _studioId!,
      config: _config!,
    );
  }

  Future<void> _updateBankDetails({
    required PaymentMethodType type,
    String? bic,
    String? accountHolder,
    String? bankName,
  }) async {
    if (_studioId == null) return;

    final methods = _config!.methods.map((m) {
      if (m.type == type) {
        return m.copyWith(
          bic: bic ?? m.bic,
          accountHolder: accountHolder ?? m.accountHolder,
          bankName: bankName ?? m.bankName,
        );
      }
      return m;
    }).toList();

    _config = _config!.copyWith(methods: methods);

    await Future.delayed(const Duration(milliseconds: 500));
    await _paymentService.updatePaymentConfig(
      studioId: _studioId!,
      config: _config!,
    );
  }
}
