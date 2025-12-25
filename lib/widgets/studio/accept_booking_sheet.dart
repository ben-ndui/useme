import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/payment_method.dart';
import 'package:useme/core/models/session.dart';
import 'package:useme/core/services/engineer_availability_service.dart';
import 'package:useme/core/services/payment_config_service.dart';
import 'package:useme/widgets/studio/booking/booking_exports.dart';

/// Résultat de l'acceptation d'une réservation
class AcceptBookingResult {
  final PaymentMethod paymentMethod;
  final double depositAmount;
  final double totalAmount;
  final String? customMessage;
  final bool saveAsDefault;
  final List<AppUser> selectedEngineers;
  final bool proposeToEngineers;

  const AcceptBookingResult({
    required this.paymentMethod,
    required this.depositAmount,
    required this.totalAmount,
    this.customMessage,
    this.saveAsDefault = false,
    this.selectedEngineers = const [],
    this.proposeToEngineers = false,
  });

  AppUser? get selectedEngineer => selectedEngineers.isNotEmpty ? selectedEngineers.first : null;
}

/// Bottom sheet pour accepter une réservation avec sélection du paiement et ingénieur
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
      builder: (_) => AcceptBookingSheet(session: session, totalAmount: totalAmount),
    );
  }

  @override
  State<AcceptBookingSheet> createState() => _AcceptBookingSheetState();
}

class _AcceptBookingSheetState extends State<AcceptBookingSheet> {
  final PaymentConfigService _paymentService = PaymentConfigService();
  final EngineerAvailabilityService _engineerService = EngineerAvailabilityService();

  StudioPaymentConfig? _config;
  PaymentMethod? _selectedMethod;
  double _depositPercent = 30;
  bool _isLoading = true;
  bool _saveAsDefault = false;
  final _customMessageController = TextEditingController();

  List<AvailableEngineer> _availableEngineers = [];
  final Set<String> _selectedEngineerIds = {};
  bool _needsEngineerSelection = false;
  bool _proposeMode = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _customMessageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;

    final studioId = authState.user.uid;
    final config = await _paymentService.getPaymentConfig(studioId);

    _needsEngineerSelection = !widget.session.hasEngineer;

    if (_needsEngineerSelection) {
      final engineers = await _engineerService.getAvailableEngineers(
        studioId: studioId,
        start: widget.session.scheduledStart,
        end: widget.session.scheduledEnd,
      );
      _availableEngineers = engineers;
    }

    setState(() {
      _config = config;
      _depositPercent = config.defaultDepositPercent ?? 30;
      _selectedMethod = config.defaultMethod ?? config.enabledMethods.firstOrNull;
      _isLoading = false;
    });
  }

  double get _depositAmount => widget.totalAmount * (_depositPercent / 100);

  List<AppUser> get _selectedEngineers => _availableEngineers
      .where((e) => _selectedEngineerIds.contains(e.user.uid))
      .map((e) => e.user)
      .toList();

  bool get _canSubmit =>
      _selectedMethod != null &&
      (!_needsEngineerSelection || !_proposeMode || _selectedEngineerIds.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
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
                  BookingSheetHeader(
                    session: widget.session,
                    totalAmount: widget.totalAmount,
                  ),
                  if (_needsEngineerSelection) ...[
                    const SizedBox(height: 24),
                    BookingEngineerSelector(
                      availableEngineers: _availableEngineers,
                      selectedEngineerIds: _selectedEngineerIds,
                      proposeMode: _proposeMode,
                      onModeChanged: (value) => setState(() {
                        _proposeMode = value;
                        if (!value) _selectedEngineerIds.clear();
                      }),
                      onEngineerToggled: (id) => setState(() {
                        if (_selectedEngineerIds.contains(id)) {
                          _selectedEngineerIds.remove(id);
                        } else {
                          _selectedEngineerIds.add(id);
                        }
                      }),
                    ),
                  ],
                  const SizedBox(height: 24),
                  BookingPaymentSelector(
                    enabledMethods: _config?.enabledMethods ?? [],
                    selectedMethod: _selectedMethod,
                    depositPercent: _depositPercent,
                    totalAmount: widget.totalAmount,
                    messageController: _customMessageController,
                    onMethodSelected: (m) => setState(() => _selectedMethod = m),
                    onDepositChanged: (v) => setState(() => _depositPercent = v),
                  ),
                  const SizedBox(height: 24),
                  BookingSheetSummary(
                    totalAmount: widget.totalAmount,
                    depositAmount: _depositAmount,
                    selectedMethod: _selectedMethod,
                    selectedEngineers: _selectedEngineers,
                    needsEngineerSelection: _needsEngineerSelection,
                    proposeMode: _proposeMode,
                    saveAsDefault: _saveAsDefault,
                    canSubmit: _canSubmit,
                    onSaveAsDefaultChanged: (v) => setState(() => _saveAsDefault = v),
                    onSubmit: _submit,
                    onCancel: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
    );
  }

  void _submit() {
    if (_selectedMethod == null) return;
    if (_needsEngineerSelection && _proposeMode && _selectedEngineerIds.isEmpty) return;

    final result = AcceptBookingResult(
      paymentMethod: _selectedMethod!,
      depositAmount: _depositAmount,
      totalAmount: widget.totalAmount,
      customMessage: _customMessageController.text.trim().isEmpty ? null : _customMessageController.text.trim(),
      saveAsDefault: _saveAsDefault,
      selectedEngineers: _selectedEngineers,
      proposeToEngineers: _proposeMode && _selectedEngineers.isNotEmpty,
    );

    Navigator.pop(context, result);
  }
}
