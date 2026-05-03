import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uzme/core/models/card_config.dart';
import 'package:uzme/core/utils/app_logger.dart';

/// Service for loading and saving card customization from Firestore.
class CardConfigService {
  final FirebaseFirestore _firestore;

  CardConfigService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  /// Load the card config from the user document.
  Future<CardConfig> load(String userId) async {
    try {
      final doc = await _userDoc(userId).get();
      final data = doc.data();
      if (data == null || data['cardConfig'] == null) {
        return const CardConfig();
      }
      return CardConfig.fromMap(data['cardConfig'] as Map<String, dynamic>);
    } catch (e) {
      appLog('CardConfigService.load error: $e');
      return const CardConfig();
    }
  }

  /// Save the card config to the user document.
  Future<bool> save(String userId, CardConfig config) async {
    try {
      await _userDoc(userId).update({
        'cardConfig': config.isDefault ? FieldValue.delete() : config.toMap(),
      });
      return true;
    } catch (e) {
      appLog('CardConfigService.save error: $e');
      return false;
    }
  }
}
