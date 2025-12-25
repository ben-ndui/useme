import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:useme/core/models/payment_method.dart';
import 'package:useme/core/services/encryption_service.dart';

/// Service pour gérer la configuration des paiements d'un studio
/// avec chiffrement AES-256 des données sensibles
class PaymentConfigService {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final EncryptionService _encryptionService;
  static const String _usersCollection = 'users';

  PaymentConfigService({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
    EncryptionService? encryptionService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance,
        _encryptionService = encryptionService ?? EncryptionService();

  /// Initialise le service de chiffrement pour un utilisateur
  Future<void> initializeEncryption(String userId) async {
    await _encryptionService.initialize(userId);
  }

  /// Récupère la configuration de paiement d'un studio (déchiffrée)
  Future<StudioPaymentConfig> getPaymentConfig(String studioId) async {
    try {
      // S'assurer que le chiffrement est initialisé
      if (!_encryptionService.isInitialized) {
        await _encryptionService.initialize(studioId);
      }

      final doc = await _firestore.collection(_usersCollection).doc(studioId).get();
      if (!doc.exists) return const StudioPaymentConfig();

      final data = doc.data();
      final configData = data?['paymentConfig'] as Map<String, dynamic>?;

      if (configData == null) return const StudioPaymentConfig();

      // Déchiffrer les méthodes de paiement
      final decryptedConfig = _decryptConfigData(configData);
      return StudioPaymentConfig.fromMap(decryptedConfig);
    } catch (e) {
      debugPrint('Erreur getPaymentConfig: $e');
      return const StudioPaymentConfig();
    }
  }

  /// Stream de la configuration de paiement (déchiffrée)
  Stream<StudioPaymentConfig> streamPaymentConfig(String studioId) {
    return _firestore
        .collection(_usersCollection)
        .doc(studioId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return const StudioPaymentConfig();

      // S'assurer que le chiffrement est initialisé
      if (!_encryptionService.isInitialized) {
        await _encryptionService.initialize(studioId);
      }

      final configData = doc.data()?['paymentConfig'] as Map<String, dynamic>?;
      if (configData == null) return const StudioPaymentConfig();

      final decryptedConfig = _decryptConfigData(configData);
      return StudioPaymentConfig.fromMap(decryptedConfig);
    });
  }

  /// Met à jour la configuration de paiement (chiffrée)
  Future<void> updatePaymentConfig({
    required String studioId,
    required StudioPaymentConfig config,
  }) async {
    // S'assurer que le chiffrement est initialisé
    if (!_encryptionService.isInitialized) {
      await _encryptionService.initialize(studioId);
    }

    // Chiffrer les données sensibles
    final encryptedConfig = _encryptConfigData(config.toMap());

    await _firestore.collection(_usersCollection).doc(studioId).update({
      'paymentConfig': encryptedConfig,
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

  /// Met à jour le moyen de paiement par défaut
  Future<void> updateDefaultPaymentMethod({
    required String studioId,
    required PaymentMethodType type,
    double? depositPercent,
  }) async {
    final config = await getPaymentConfig(studioId);
    await updatePaymentConfig(
      studioId: studioId,
      config: config.copyWith(
        defaultPaymentMethod: type,
        defaultDepositPercent: depositPercent ?? config.defaultDepositPercent,
      ),
    );
  }

  /// Génère le message de paiement via Cloud Function (sécurisé)
  Future<String> generatePaymentMessageSecure({
    required String studioId,
    required String sessionTitle,
    required DateTime sessionDate,
    required double totalAmount,
    required double depositAmount,
    required PaymentMethodType paymentMethodType,
  }) async {
    try {
      final callable = _functions.httpsCallable('generatePaymentMessage');
      final result = await callable.call<Map<String, dynamic>>({
        'studioId': studioId,
        'sessionTitle': sessionTitle,
        'sessionDate': sessionDate.toIso8601String(),
        'totalAmount': totalAmount,
        'depositAmount': depositAmount,
        'paymentMethodType': paymentMethodType.name,
      });

      return result.data['message'] as String;
    } catch (e) {
      debugPrint('Erreur generatePaymentMessage (Cloud Function): $e');
      // Fallback: générer localement (moins sécurisé)
      final config = await getPaymentConfig(studioId);
      final method = config.methods.firstWhere(
        (m) => m.type == paymentMethodType,
        orElse: () => PaymentMethod(type: paymentMethodType),
      );
      return generatePaymentMessageLocal(
        sessionTitle: sessionTitle,
        sessionDate: sessionDate,
        totalAmount: totalAmount,
        depositAmount: depositAmount,
        paymentMethod: method,
      );
    }
  }

  /// Génère le message de paiement localement (fallback)
  String generatePaymentMessageLocal({
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
          if (paymentMethod.bic != null && paymentMethod.bic!.isNotEmpty) {
            buffer.writeln('🔢 BIC: ${paymentMethod.bic}');
          }
          if (paymentMethod.accountHolder != null && paymentMethod.accountHolder!.isNotEmpty) {
            buffer.writeln('👤 Titulaire: ${paymentMethod.accountHolder}');
          }
          if (paymentMethod.bankName != null && paymentMethod.bankName!.isNotEmpty) {
            buffer.writeln('🏛️ Banque: ${paymentMethod.bankName}');
          }
          break;
        case PaymentMethodType.paypal:
          buffer.writeln('📧 PayPal: ${paymentMethod.details}');
          break;
        default:
          buffer.writeln('ℹ️ ${paymentMethod.details}');
      }
    }

    if (paymentMethod.instructions != null && paymentMethod.instructions!.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('📝 Instructions: ${paymentMethod.instructions}');
    }

    buffer.writeln('');
    buffer.writeln('Merci de régler l\'acompte pour confirmer ta réservation ! 🎵');

    return buffer.toString();
  }

  /// Chiffre les données de configuration
  Map<String, dynamic> _encryptConfigData(Map<String, dynamic> configData) {
    final encrypted = Map<String, dynamic>.from(configData);

    if (encrypted['methods'] != null) {
      final methods = (encrypted['methods'] as List).map((methodData) {
        if (methodData is Map<String, dynamic>) {
          return _encryptionService.encryptPaymentData(methodData);
        }
        return methodData;
      }).toList();
      encrypted['methods'] = methods;
    }

    return encrypted;
  }

  /// Déchiffre les données de configuration
  Map<String, dynamic> _decryptConfigData(Map<String, dynamic> configData) {
    final decrypted = Map<String, dynamic>.from(configData);

    if (decrypted['methods'] != null) {
      final methods = (decrypted['methods'] as List).map((methodData) {
        if (methodData is Map<String, dynamic>) {
          return _encryptionService.decryptPaymentData(methodData);
        }
        return methodData;
      }).toList();
      decrypted['methods'] = methods;
    }

    return decrypted;
  }
}
