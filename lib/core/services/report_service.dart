import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uzme/core/utils/app_logger.dart';

/// Service for reporting users from conversations.
class ReportService {
  final FirebaseFirestore _firestore;

  ReportService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Reports a user and notifies superAdmin users.
  Future<void> reportUser({
    required String reporterId,
    required String reportedUserId,
    required String conversationId,
    String? reason,
  }) async {
    final now = FieldValue.serverTimestamp();

    // Create the report document
    final reportRef = await _firestore.collection('reports').add({
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'conversationId': conversationId,
      'reason': reason ?? '',
      'createdAt': now,
      'status': 'pending',
    });

    appLog('ReportService: report created ${reportRef.id}');

    // Notify superAdmin users
    await _notifySuperAdmins(
      reportId: reportRef.id,
      reporterId: reporterId,
      reportedUserId: reportedUserId,
    );
  }

  Future<void> _notifySuperAdmins({
    required String reportId,
    required String reporterId,
    required String reportedUserId,
  }) async {
    try {
      final admins = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'superAdmin')
          .get();

      final batch = _firestore.batch();
      for (final admin in admins.docs) {
        final notifRef = _firestore.collection('user_notifications').doc();
        batch.set(notifRef, {
          'userId': admin.id,
          'type': 'user_report',
          'title': 'New user report',
          'body': 'User $reporterId reported user $reportedUserId',
          'data': {'reportId': reportId},
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      appLog('ReportService: notified ${admins.docs.length} superAdmins');
    } catch (e) {
      appLog('ReportService: failed to notify superAdmins: $e');
    }
  }
}