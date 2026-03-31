import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:useme/core/utils/app_logger.dart';

/// Stats tracked for a user's digital card.
class CardStats {
  final int scanCount;
  final int viewCount;
  final DateTime? lastScannedAt;
  final DateTime? lastViewedAt;

  const CardStats({
    this.scanCount = 0,
    this.viewCount = 0,
    this.lastScannedAt,
    this.lastViewedAt,
  });

  factory CardStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const CardStats();
    return CardStats(
      scanCount: map['scanCount'] as int? ?? 0,
      viewCount: map['viewCount'] as int? ?? 0,
      lastScannedAt: _parseDate(map['lastScannedAt']),
      lastViewedAt: _parseDate(map['lastViewedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

/// Service for tracking and reading card scan/view stats.
class CardStatsService {
  final FirebaseFirestore _firestore;

  CardStatsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  /// Load stats for a user.
  Future<CardStats> load(String userId) async {
    try {
      final doc = await _userDoc(userId).get();
      final data = doc.data();
      if (data == null) return const CardStats();
      return CardStats.fromMap(data['cardStats'] as Map<String, dynamic>?);
    } catch (e) {
      appLog('CardStatsService.load error: $e');
      return const CardStats();
    }
  }

  /// Increment the scan counter (called when someone scans this user's QR).
  Future<void> recordScan(String scannedUserId) async {
    try {
      await _userDoc(scannedUserId).update({
        'cardStats.scanCount': FieldValue.increment(1),
        'cardStats.lastScannedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      appLog('CardStatsService.recordScan error: $e');
    }
  }

  /// Increment the view counter (called when someone views this user's profile).
  Future<void> recordView(String viewedUserId) async {
    try {
      await _userDoc(viewedUserId).update({
        'cardStats.viewCount': FieldValue.increment(1),
        'cardStats.lastViewedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      appLog('CardStatsService.recordView error: $e');
    }
  }
}
