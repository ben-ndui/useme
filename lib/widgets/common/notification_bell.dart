import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';

/// Notification bell icon with badge based on unread notifications count
class NotificationBell extends StatelessWidget {
  final String userId;
  final VoidCallback onTap;

  const NotificationBell({
    super.key,
    required this.userId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<QuerySnapshot>(
      stream: SmoothFirebase.collection('user_notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data?.docs.length ?? 0;
        final hasUnread = unreadCount > 0;

        return Stack(
          children: [
            Material(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: FaIcon(
                    FontAwesomeIcons.bell,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            if (hasUnread)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
