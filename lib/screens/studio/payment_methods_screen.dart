import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/payment_method.dart';
import 'package:useme/core/services/payment_config_service.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Moyens de paiement')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildInfoCard(theme),
                const SizedBox(height: 24),
                _buildDepositSection(theme),
                const SizedBox(height: 24),
                _buildPaymentMethodsSection(theme),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
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
                  'Configurez vos paiements',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ces options seront proposées aux artistes lors de la confirmation de réservation.',
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

  Widget _buildDepositSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Acompte par défaut', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Pourcentage du montant total demandé en acompte',
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

  Widget _buildPaymentMethodsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Moyens de paiement acceptés', style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        ...(_config?.methods ?? []).map((method) => _buildPaymentMethodCard(theme, method)),
      ],
    );
  }

  Widget _buildPaymentMethodCard(ThemeData theme, PaymentMethod method) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
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
        title: Text(method.type.label),
        subtitle: method.details != null && method.details!.isNotEmpty
            ? Text(
                method.details!,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Switch.adaptive(
          value: method.isEnabled,
          onChanged: (enabled) => _toggleMethod(method.type, enabled),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                TextFormField(
                  initialValue: method.details,
                  decoration: InputDecoration(
                    labelText: _getDetailsLabelForType(method.type),
                    hintText: _getDetailsHintForType(method.type),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => _updateMethodDetails(method.type, value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: method.instructions,
                  decoration: InputDecoration(
                    labelText: 'Instructions (optionnel)',
                    hintText: 'Ex: Mettre le nom de l\'artiste en référence',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                  onChanged: (value) =>
                      _updateMethodInstructions(method.type, value),
                ),
              ],
            ),
          ),
        ],
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

  String _getDetailsLabelForType(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.bankTransfer:
        return 'IBAN';
      case PaymentMethodType.paypal:
        return 'Email PayPal';
      case PaymentMethodType.card:
        return 'Informations';
      default:
        return 'Détails';
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
}
