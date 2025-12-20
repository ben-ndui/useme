import 'package:equatable/equatable.dart';

/// Types de moyens de paiement disponibles
enum PaymentMethodType {
  cash,
  bankTransfer,
  paypal,
  card,
  other;

  String get label {
    switch (this) {
      case PaymentMethodType.cash:
        return 'Espèces';
      case PaymentMethodType.bankTransfer:
        return 'Virement bancaire';
      case PaymentMethodType.paypal:
        return 'PayPal';
      case PaymentMethodType.card:
        return 'Carte bancaire';
      case PaymentMethodType.other:
        return 'Autre';
    }
  }

  String get icon {
    switch (this) {
      case PaymentMethodType.cash:
        return 'moneyBill';
      case PaymentMethodType.bankTransfer:
        return 'buildingColumns';
      case PaymentMethodType.paypal:
        return 'paypal';
      case PaymentMethodType.card:
        return 'creditCard';
      case PaymentMethodType.other:
        return 'ellipsis';
    }
  }
}

/// Configuration d'un moyen de paiement pour un studio
class PaymentMethod extends Equatable {
  final PaymentMethodType type;
  final bool isEnabled;
  final String? details; // Ex: IBAN pour virement, email PayPal, etc.
  final String? instructions; // Instructions supplémentaires

  const PaymentMethod({
    required this.type,
    this.isEnabled = true,
    this.details,
    this.instructions,
  });

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      type: PaymentMethodType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => PaymentMethodType.other,
      ),
      isEnabled: map['isEnabled'] ?? true,
      details: map['details'],
      instructions: map['instructions'],
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'isEnabled': isEnabled,
        'details': details,
        'instructions': instructions,
      };

  PaymentMethod copyWith({
    PaymentMethodType? type,
    bool? isEnabled,
    String? details,
    String? instructions,
  }) {
    return PaymentMethod(
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
      details: details ?? this.details,
      instructions: instructions ?? this.instructions,
    );
  }

  @override
  List<Object?> get props => [type, isEnabled, details, instructions];
}

/// Configuration des paiements d'un studio
class StudioPaymentConfig extends Equatable {
  final List<PaymentMethod> methods;
  final double? defaultDepositPercent; // Ex: 30% d'acompte par défaut
  final String? paymentTerms; // Conditions de paiement

  const StudioPaymentConfig({
    this.methods = const [],
    this.defaultDepositPercent,
    this.paymentTerms,
  });

  /// Moyens de paiement activés
  List<PaymentMethod> get enabledMethods =>
      methods.where((m) => m.isEnabled).toList();

  factory StudioPaymentConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const StudioPaymentConfig();
    return StudioPaymentConfig(
      methods: (map['methods'] as List<dynamic>?)
              ?.map((m) => PaymentMethod.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      defaultDepositPercent: (map['defaultDepositPercent'] as num?)?.toDouble(),
      paymentTerms: map['paymentTerms'],
    );
  }

  Map<String, dynamic> toMap() => {
        'methods': methods.map((m) => m.toMap()).toList(),
        'defaultDepositPercent': defaultDepositPercent,
        'paymentTerms': paymentTerms,
      };

  StudioPaymentConfig copyWith({
    List<PaymentMethod>? methods,
    double? defaultDepositPercent,
    String? paymentTerms,
  }) {
    return StudioPaymentConfig(
      methods: methods ?? this.methods,
      defaultDepositPercent: defaultDepositPercent ?? this.defaultDepositPercent,
      paymentTerms: paymentTerms ?? this.paymentTerms,
    );
  }

  @override
  List<Object?> get props => [methods, defaultDepositPercent, paymentTerms];
}
