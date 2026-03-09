import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:useme/core/utils/app_logger.dart';

/// Service for blocking and unblocking users.
class BlockService {
  final FirebaseFirestore _firestore;

  BlockService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Blocks a user by adding them to the current user's blockedUsers map.
  Future<void> blockUser(String currentUserId, String blockedUserId) async {
    await _firestore.collection('users').doc(currentUserId).update({
      'blockedUsers.$blockedUserId': Timestamp.now(),
    });
    appLog('BlockService: $currentUserId blocked $blockedUserId');
  }

  /// Unblocks a user by removing them from the blockedUsers map.
  Future<void> unblockUser(String currentUserId, String blockedUserId) async {
    await _firestore.collection('users').doc(currentUserId).update({
      'blockedUsers.$blockedUserId': FieldValue.delete(),
    });
    appLog('BlockService: $currentUserId unblocked $blockedUserId');
  }

  /// Returns the list of user IDs blocked by the given user.
  Future<List<String>> getBlockedUserIds(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();
    if (data == null) return [];

    final blockedUsers = data['blockedUsers'];
    if (blockedUsers is Map) {
      return blockedUsers.keys.cast<String>().toList();
    }
    return [];
  }

  /// Checks if [otherUserId] is blocked by [currentUserId].
  Future<bool> isBlocked(String currentUserId, String otherUserId) async {
    final blockedIds = await getBlockedUserIds(currentUserId);
    return blockedIds.contains(otherUserId);
  }
}
