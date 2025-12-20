import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/payment_method.dart';
import 'package:useme/core/models/session.dart';
import 'package:useme/core/services/payment_config_service.dart';

/// Résultat de l'acceptation d'une réservation
class AcceptBookingResult {
  final PaymentMethod paymentMethod;
  final double depositAmount;
  final double totalAmount;
  final String? customMessage;

  const AcceptBookingResult({
    required this.paymentMethod,
    required this.depositAmount,
    required this.totalAmount,
    this.customMessage,
  });
}

/// Bottom sheet pour accepter une réservation avec sélection du paiement
class AcceptBookingSheet extends StatefulWidget {
  final Session session;
  final double totalAmount;

  const AcceptBookingSheet({
    super.key,
    required this.session,
    required this.totalAmount,
  });

  static Future<AcceptBookingResult?> show(
    BuildContext context, {
    required Session session,
    required double totalAmount,
  }) {
    return showModalBottomSheet<AcceptBookingResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AcceptBookingSheet(
        session: session,
        totalAmount: totalAmount,
      ),
    );
  }

  @override
  State<AcceptBookingSheet> createState() => _AcceptBookingSheetState();
}

class _AcceptBookingSheetState extends State<AcceptBookingSheet> {
  final PaymentConfigService _paymentService = PaymentConfigService();

  StudioPaymentConfig? _config;
  PaymentMethod? _selectedMethod;
  double _depositPercent = 30;
  bool _isLoading = true;
  final _customMessageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _customMessageController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;

    final config = await _paymentService.getPaymentConfig(authState.user.uid);

    setState(() {
      _config = config;
      _depositPercent = config.defaultDepositPercent ?? 30;
      if (config.enabledMethods.isNotEmpty) {
        _selectedMethod = config.enabledMethods.first;
      }
      _isLoading = false;
    });
  }

  double get _depositAmount => widget.totalAmount * (_depositPercent / 100);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(theme),
                  const SizedBox(height: 24),
                  _buildSessionInfo(theme),
                  const SizedBox(height: 24),
                  _buildPaymentMethodSection(theme),
                  const SizedBox(height: 24),
                  _buildDepositSection(theme),
                  const SizedBox(height: 24),
                  _buildCustomMessageSection(theme),
                  const SizedBox(height: 24),
                  _buildSummary(theme),
                  const SizedBox(height: 24),
                  _buildActions(theme),
                  const SizedBox(height: 8),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // Drag handle
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.check, size: 20, color: Colors.green),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accepter la réservation',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Choisissez le mode de paiement',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          FaIcon(
            FontAwesomeIcons.calendarCheck,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.session.type.label} - ${widget.session.artistNames.join(", ")}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatSessionDate(widget.session),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${widget.totalAmount.toStringAsFixed(2)} €',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(ThemeData theme) {
    final enabledMethods = _config?.enabledMethods ?? [];

    if (enabledMethods.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.triangleExclamation,
              size: 20,
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Aucun moyen de paiement configuré. Allez dans Réglages > Moyens de paiement.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mode de paiement', style: theme.textTheme.titleSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: enabledMethods.map((method) {
            final isSelected = _selectedMethod?.type == method.type;
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    _getIconForType(method.type),
                    size: 14,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(method.type.label),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedMethod = method),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDepositSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Acompte demandé', style: theme.textTheme.titleSmall),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _depositPercent,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${_depositPercent.toInt()}%',
                onChanged: (value) => setState(() => _depositPercent = value),
              ),
            ),
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_depositAmount.toStringAsFixed(0)} €',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Text(
          '${_depositPercent.toInt()}% du montant total',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomMessageSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Message personnalisé (optionnel)', style: theme.textTheme.titleSmall),
        const SizedBox(height: 12),
        TextField(
          controller: _customMessageController,
          decoration: InputDecoration(
            hintText: 'Ex: Merci pour ta confiance !',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildSummary(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Montant total'),
              Text('${widget.totalAmount.toStringAsFixed(2)} €'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Acompte à régler',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_depositAmount.toStringAsFixed(2)} €',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          if (_selectedMethod != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Paiement par'),
                Text(_selectedMethod!.type.label),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    final canSubmit = _selectedMethod != null;

    return Column(
      children: [
        FilledButton.icon(
          onPressed: canSubmit ? _submit : null,
          icon: const FaIcon(FontAwesomeIcons.paperPlane, size: 14),
          label: const Text('Accepter et envoyer les infos'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
      ],
    );
  }

  void _submit() {
    if (_selectedMethod == null) return;

    final result = AcceptBookingResult(
      paymentMethod: _selectedMethod!,
      depositAmount: _depositAmount,
      totalAmount: widget.totalAmount,
      customMessage: _customMessageController.text.trim().isEmpty
          ? null
          : _customMessageController.text.trim(),
    );

    Navigator.pop(context, result);
  }

  String _formatSessionDate(Session session) {
    final date = session.scheduledStart;
    final endTime = session.scheduledEnd;
    return '${date.day}/${date.month}/${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')} - ${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';
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
}
