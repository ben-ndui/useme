import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:useme/core/models/payment_method.dart';

/// Service pour gérer la configuration des paiements d'un studio
class PaymentConfigService {
  final FirebaseFirestore _firestore;
  static const String _usersCollection = 'users';

  PaymentConfigService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Récupère la configuration de paiement d'un studio
  Future<StudioPaymentConfig> getPaymentConfig(String studioId) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(studioId).get();
      if (!doc.exists) return const StudioPaymentConfig();

      final data = doc.data();
      return StudioPaymentConfig.fromMap(data?['paymentConfig']);
    } catch (e) {
      debugPrint('Erreur getPaymentConfig: $e');
      return const StudioPaymentConfig();
    }
  }

  /// Stream de la configuration de paiement
  Stream<StudioPaymentConfig> streamPaymentConfig(String studioId) {
    return _firestore
        .collection(_usersCollection)
        .doc(studioId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return const StudioPaymentConfig();
      return StudioPaymentConfig.fromMap(doc.data()?['paymentConfig']);
    });
  }

  /// Met à jour la configuration de paiement
  Future<void> updatePaymentConfig({
    required String studioId,
    required StudioPaymentConfig config,
  }) async {
    await _firestore.collection(_usersCollection).doc(studioId).update({
      'paymentConfig': config.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Ajoute ou met à jour un moyen de paiement
  Future<void> upsertPaymentMethod({
    required String studioId,
    required PaymentMethod method,
  }) async {
    final config = await getPaymentConfig(studioId);
    final methods = List<PaymentMethod>.from(config.methods);

    final existingIndex = methods.indexWhere((m) => m.type == method.type);
    if (existingIndex >= 0) {
      methods[existingIndex] = method;
    } else {
      methods.add(method);
    }

    await updatePaymentConfig(
      studioId: studioId,
      config: config.copyWith(methods: methods),
    );
  }

  /// Active/désactive un moyen de paiement
  Future<void> togglePaymentMethod({
    required String studioId,
    required PaymentMethodType type,
    required bool enabled,
  }) async {
    final config = await getPaymentConfig(studioId);
    final methods = config.methods.map((m) {
      if (m.type == type) {
        return m.copyWith(isEnabled: enabled);
      }
      return m;
    }).toList();

    await updatePaymentConfig(
      studioId: studioId,
      config: config.copyWith(methods: methods),
    );
  }

  /// Met à jour le pourcentage d'acompte par défaut
  Future<void> updateDefaultDeposit({
    required String studioId,
    required double percent,
  }) async {
    final config = await getPaymentConfig(studioId);
    await updatePaymentConfig(
      studioId: studioId,
      config: config.copyWith(defaultDepositPercent: percent),
    );
  }

  /// Génère le message de paiement pour une réservation
  String generatePaymentMessage({
    required String sessionTitle,
    required DateTime sessionDate,
    required double totalAmount,
    required double depositAmount,
    required PaymentMethod paymentMethod,
    String? studioName,
  }) {
    final dateStr = '${sessionDate.day}/${sessionDate.month}/${sessionDate.year}';
    final buffer = StringBuffer();

    buffer.writeln('💰 Demande d\'acompte');
    buffer.writeln('');
    buffer.writeln('📅 Session: $sessionTitle');
    buffer.writeln('📆 Date: $dateStr');
    buffer.writeln('');
    buffer.writeln('💵 Montant total: ${totalAmount.toStringAsFixed(2)} €');
    buffer.writeln('🔒 Acompte à régler: ${depositAmount.toStringAsFixed(2)} €');
    buffer.writeln('');
    buffer.writeln('💳 Mode de paiement: ${paymentMethod.type.label}');

    if (paymentMethod.details != null && paymentMethod.details!.isNotEmpty) {
      buffer.writeln('');
      switch (paymentMethod.type) {
        case PaymentMethodType.bankTransfer:
          buffer.writeln('🏦 IBAN: ${paymentMethod.details}');
          break;
        case PaymentMethodType.paypal:
          buffer.writeln('📧 PayPal: ${paymentMethod.details}');
          break;
        default:
          buffer.writeln('ℹ️ ${paymentMethod.details}');
      }
    }

    if (paymentMethod.instructions != null &&
        paymentMethod.instructions!.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('📝 Instructions: ${paymentMethod.instructions}');
    }

    buffer.writeln('');
    buffer.writeln('Merci de régler l\'acompte pour confirmer ta réservation ! 🎵');

    return buffer.toString();
  }
}
