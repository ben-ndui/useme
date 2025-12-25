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

  // Champs spécifiques au virement bancaire
  final String? bic; // BIC/SWIFT
  final String? accountHolder; // Nom du titulaire
  final String? bankName; // Nom de la banque

  const PaymentMethod({
    required this.type,
    this.isEnabled = true,
    this.details,
    this.instructions,
    this.bic,
    this.accountHolder,
    this.bankName,
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
      bic: map['bic'],
      accountHolder: map['accountHolder'],
      bankName: map['bankName'],
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'isEnabled': isEnabled,
        'details': details,
        'instructions': instructions,
        'bic': bic,
        'accountHolder': accountHolder,
        'bankName': bankName,
      };

  PaymentMethod copyWith({
    PaymentMethodType? type,
    bool? isEnabled,
    String? details,
    String? instructions,
    String? bic,
    String? accountHolder,
    String? bankName,
  }) {
    return PaymentMethod(
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
      details: details ?? this.details,
      instructions: instructions ?? this.instructions,
      bic: bic ?? this.bic,
      accountHolder: accountHolder ?? this.accountHolder,
      bankName: bankName ?? this.bankName,
    );
  }

  @override
  List<Object?> get props => [
        type,
        isEnabled,
        details,
        instructions,
        bic,
        accountHolder,
        bankName,
      ];
}

/// Politique d'annulation
enum CancellationPolicy {
  flexible, // Remboursement complet jusqu'à 24h avant
  moderate, // Remboursement 50% jusqu'à 48h avant
  strict, // Pas de remboursement
  custom; // Politique personnalisée

  String get label {
    switch (this) {
      case CancellationPolicy.flexible:
        return 'Flexible';
      case CancellationPolicy.moderate:
        return 'Modérée';
      case CancellationPolicy.strict:
        return 'Stricte';
      case CancellationPolicy.custom:
        return 'Personnalisée';
    }
  }

  String get description {
    switch (this) {
      case CancellationPolicy.flexible:
        return 'Remboursement complet jusqu\'à 24h avant la session';
      case CancellationPolicy.moderate:
        return 'Remboursement 50% jusqu\'à 48h avant la session';
      case CancellationPolicy.strict:
        return 'Aucun remboursement après paiement';
      case CancellationPolicy.custom:
        return 'Conditions personnalisées';
    }
  }
}

/// Configuration des paiements d'un studio
class StudioPaymentConfig extends Equatable {
  final List<PaymentMethod> methods;
  final double? defaultDepositPercent; // Ex: 30% d'acompte par défaut
  final String? paymentTerms; // Conditions de paiement
  final PaymentMethodType? defaultPaymentMethod; // Moyen de paiement par défaut
  final CancellationPolicy cancellationPolicy;
  final String? customCancellationTerms; // Si policy = custom

  const StudioPaymentConfig({
    this.methods = const [],
    this.defaultDepositPercent,
    this.paymentTerms,
    this.defaultPaymentMethod,
    this.cancellationPolicy = CancellationPolicy.moderate,
    this.customCancellationTerms,
  });

  /// Moyens de paiement activés
  List<PaymentMethod> get enabledMethods =>
      methods.where((m) => m.isEnabled).toList();

  /// Moyen de paiement par défaut (ou premier activé)
  PaymentMethod? get defaultMethod {
    if (defaultPaymentMethod != null) {
      final method = methods.where((m) => m.type == defaultPaymentMethod && m.isEnabled).firstOrNull;
      if (method != null) return method;
    }
    return enabledMethods.firstOrNull;
  }

  factory StudioPaymentConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const StudioPaymentConfig();
    return StudioPaymentConfig(
      methods: (map['methods'] as List<dynamic>?)
              ?.map((m) => PaymentMethod.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      defaultDepositPercent: (map['defaultDepositPercent'] as num?)?.toDouble(),
      paymentTerms: map['paymentTerms'],
      defaultPaymentMethod: map['defaultPaymentMethod'] != null
          ? PaymentMethodType.values.firstWhere(
              (t) => t.name == map['defaultPaymentMethod'],
              orElse: () => PaymentMethodType.other,
            )
          : null,
      cancellationPolicy: map['cancellationPolicy'] != null
          ? CancellationPolicy.values.firstWhere(
              (p) => p.name == map['cancellationPolicy'],
              orElse: () => CancellationPolicy.moderate,
            )
          : CancellationPolicy.moderate,
      customCancellationTerms: map['customCancellationTerms'],
    );
  }

  Map<String, dynamic> toMap() => {
        'methods': methods.map((m) => m.toMap()).toList(),
        'defaultDepositPercent': defaultDepositPercent,
        'paymentTerms': paymentTerms,
        'defaultPaymentMethod': defaultPaymentMethod?.name,
        'cancellationPolicy': cancellationPolicy.name,
        'customCancellationTerms': customCancellationTerms,
      };

  StudioPaymentConfig copyWith({
    List<PaymentMethod>? methods,
    double? defaultDepositPercent,
    String? paymentTerms,
    PaymentMethodType? defaultPaymentMethod,
    CancellationPolicy? cancellationPolicy,
    String? customCancellationTerms,
  }) {
    return StudioPaymentConfig(
      methods: methods ?? this.methods,
      defaultDepositPercent: defaultDepositPercent ?? this.defaultDepositPercent,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      defaultPaymentMethod: defaultPaymentMethod ?? this.defaultPaymentMethod,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      customCancellationTerms: customCancellationTerms ?? this.customCancellationTerms,
    );
  }

  @override
  List<Object?> get props => [
        methods,
        defaultDepositPercent,
        paymentTerms,
        defaultPaymentMethod,
        cancellationPolicy,
        customCancellationTerms,
      ];
}
