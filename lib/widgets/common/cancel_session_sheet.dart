import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/core/models/refund_calculation.dart';
import 'package:useme/core/services/payment_config_service.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Result returned by the cancel session sheet.
class CancelSessionResult {
  final String reason;
  final String? customReason;

  const CancelSessionResult({required this.reason, this.customReason});
}

/// Bottom sheet for cancelling a session with reason selection
/// and refund preview based on the studio's cancellation policy.
class CancelSessionSheet extends StatefulWidget {
  final Session session;
  final bool isCancelledByStudio;

  const CancelSessionSheet({
    super.key,
    required this.session,
    required this.isCancelledByStudio,
  });

  static Future<CancelSessionResult?> show(
    BuildContext context, {
    required Session session,
    required bool isCancelledByStudio,
  }) {
    return showModalBottomSheet<CancelSessionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CancelSessionSheet(
        session: session,
        isCancelledByStudio: isCancelledByStudio,
      ),
    );
  }

  @override
  State<CancelSessionSheet> createState() => _CancelSessionSheetState();
}

class _CancelSessionSheetState extends State<CancelSessionSheet> {
  String? _selectedReason;
  final _customReasonController = TextEditingController();
  RefundCalculation? _refund;
  bool _isLoading = true;

  final _reasons = const [
    'schedule_change',
    'personal',
    'studio_unavailable',
    'artist_no_response',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _loadRefundCalculation();
  }

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  Future<void> _loadRefundCalculation() async {
    final config = await PaymentConfigService()
        .getPaymentConfig(widget.session.studioId);
    if (!mounted) return;

    final amountPaid = widget.session.isFullyPaid
        ? (widget.session.totalAmount ?? 0).toDouble()
        : widget.session.isDepositPaid
            ? (widget.session.depositAmount ?? 0).toDouble()
            : 0.0;

    setState(() {
      _refund = RefundCalculation.calculate(
        amountPaid: amountPaid,
        policy: config.cancellationPolicy,
        sessionStart: widget.session.scheduledStart,
        isCancelledByStudio: widget.isCancelledByStudio,
      );
      _isLoading = false;
    });
  }

  String _reasonLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'schedule_change':
        return l10n.cancellationReasonSchedule;
      case 'personal':
        return l10n.cancellationReasonPersonal;
      case 'studio_unavailable':
        return l10n.cancellationReasonStudioUnavailable;
      case 'artist_no_response':
        return l10n.cancellationReasonArtistNoResponse;
      case 'other':
        return l10n.cancellationReasonOther;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
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
                  _buildHeader(theme, l10n),
                  const SizedBox(height: 20),
                  _buildReasons(theme, l10n),
                  if (_selectedReason == 'other') ...[
                    const SizedBox(height: 12),
                    _buildCustomReason(theme, l10n),
                  ],
                  if (_refund != null && _refund!.originalAmount > 0) ...[
                    const SizedBox(height: 20),
                    _buildRefundPreview(theme, l10n),
                  ],
                  const SizedBox(height: 20),
                  _buildActions(theme, l10n),
                  const SizedBox(height: 8),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: FaIcon(FontAwesomeIcons.ban, size: 20, color: Colors.red),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.cancelSessionTitle,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(l10n.selectCancellationReason,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReasons(ThemeData theme, AppLocalizations l10n) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _reasons.map((key) {
        final isSelected = _selectedReason == key;
        return ChoiceChip(
          label: Text(_reasonLabel(key, l10n)),
          selected: isSelected,
          onSelected: (_) => setState(() => _selectedReason = key),
        );
      }).toList(),
    );
  }

  Widget _buildCustomReason(ThemeData theme, AppLocalizations l10n) {
    return TextField(
      controller: _customReasonController,
      decoration: InputDecoration(
        hintText: l10n.cancellationReasonHint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      maxLines: 2,
    );
  }

  Widget _buildRefundPreview(ThemeData theme, AppLocalizations l10n) {
    final r = _refund!;
    final Color color;
    final String label;

    if (r.isFullRefund) {
      color = Colors.green;
      label = l10n.refundFull;
    } else if (r.isPartialRefund) {
      color = Colors.orange;
      label = l10n.refundPartial(r.refundPercent.toString());
    } else {
      color = Colors.red;
      label = l10n.refundNone;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.refundSummary,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              Text('${r.refundAmount.toStringAsFixed(2)} €',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.cancellationPolicyNotice(r.policy.label),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme, AppLocalizations l10n) {
    final hasRefund = _refund != null && _refund!.hasRefund;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _selectedReason != null ? _submit : null,
            icon: const FaIcon(FontAwesomeIcons.ban, size: 14),
            label: Text(hasRefund
                ? l10n.confirmCancelWithRefund
                : l10n.confirmCancelNoRefund),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }

  void _submit() {
    if (_selectedReason == null) return;
    Navigator.pop(
      context,
      CancelSessionResult(
        reason: _selectedReason!,
        customReason: _selectedReason == 'other'
            ? _customReasonController.text.trim()
            : null,
      ),
    );
  }
}
