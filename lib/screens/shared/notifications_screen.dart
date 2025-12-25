import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/app_loader.dart';

/// Notifications screen - loads from Firestore user_notifications collection
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) {
      return const AppLoader.fullScreen();
    }

    final userId = authState.user.uid;

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          TextButton(
            onPressed: () => _markAllAsRead(userId),
            child: Text(l10n.markAllAsRead),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: SmoothFirebase.collection('user_notifications')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader();
          }

          if (snapshot.hasError) {
            return _buildErrorState(context, l10n, snapshot.error.toString());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return _buildEmptyState(context, l10n);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return _buildNotificationCard(context, l10n, doc.id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.bellSlash, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            l10n.noNotifications,
            style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.notifyNewSessions,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AppLocalizations l10n, String error) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.circleExclamation, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(l10n.loadingError, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(error, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, AppLocalizations l10n, String docId, Map<String, dynamic> data) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('d MMM', locale);

    final title = data['title'] as String? ?? l10n.notifications;
    final body = data['body'] as String? ?? '';
    final type = data['type'] as String? ?? 'other';
    final isRead = data['isRead'] as bool? ?? false;
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    final isToday = createdAt.day == DateTime.now().day &&
        createdAt.month == DateTime.now().month &&
        createdAt.year == DateTime.now().year;
    final timeText = isToday ? timeFormat.format(createdAt) : dateFormat.format(createdAt);

    return Card(
      color: isRead ? null : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: InkWell(
        onTap: () => _onNotificationTap(context, docId, data),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getTypeColor(type).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(_getTypeIcon(type), size: 18, color: _getTypeColor(type)),
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          timeText,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Unread indicator
              if (!isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNotificationTap(BuildContext context, String docId, Map<String, dynamic> data) {
    // Marquer comme lu
    _markAsRead(docId);

    // Navigation selon le type
    final type = data['type'] as String? ?? '';
    final notifData = data['data'] as Map<String, dynamic>? ?? {};

    // Déterminer le rôle de l'utilisateur
    final authState = context.read<AuthBloc>().state;
    final isStudio = authState is AuthAuthenticatedState &&
        (authState.user as AppUser).role.name == 'admin';

    switch (type) {
      case 'new_message':
        final conversationId = notifData['conversationId'] as String?;
        if (conversationId != null) {
          context.push('/conversations/$conversationId');
        }
        break;
      case 'session_request':
        // session_request = pour les studios (demande d'un artiste)
        final sessionId = notifData['sessionId'] as String?;
        if (sessionId != null) {
          context.push('/sessions/$sessionId');
        }
        break;
      case 'session_confirmed':
      case 'session_cancelled':
        // Ces notifs sont pour les artistes (réponse du studio)
        final sessionId = notifData['sessionId'] as String?;
        if (sessionId != null) {
          if (isStudio) {
            context.push('/sessions/$sessionId');
          } else {
            context.push('/artist/sessions/$sessionId');
          }
        }
        break;
      case 'session_assigned':
        // Pour les ingénieurs (nouvelle session assignée)
        final sessionId = notifData['sessionId'] as String?;
        if (sessionId != null) {
          context.push('/engineer/sessions/$sessionId');
        }
        break;
      case 'booking_created':
      case 'booking_confirmed':
      case 'booking_cancelled':
        final bookingId = notifData['bookingId'] as String?;
        if (bookingId != null) {
          context.push('/bookings/$bookingId');
        }
        break;
      default:
        debugPrint('Notification type sans navigation: $type');
    }
  }

  Future<void> _markAsRead(String docId) async {
    try {
      await SmoothFirebase.collection('user_notifications').doc(docId).update({
        'isRead': true,
      });
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> _markAllAsRead(String userId) async {
    try {
      final batch = SmoothFirebase.firestore.batch();
      final unreadDocs = await SmoothFirebase.collection('user_notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in unreadDocs.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'new_message':
        return FontAwesomeIcons.message;
      case 'session_request':
        return FontAwesomeIcons.calendarPlus;
      case 'session_confirmed':
        return FontAwesomeIcons.circleCheck;
      case 'session_cancelled':
        return FontAwesomeIcons.circleXmark;
      case 'session_assigned':
        return FontAwesomeIcons.headphones;
      case 'booking_created':
        return FontAwesomeIcons.music;
      case 'booking_confirmed':
        return FontAwesomeIcons.calendarCheck;
      case 'booking_cancelled':
        return FontAwesomeIcons.calendarXmark;
      case 'studio_invitation':
        return FontAwesomeIcons.building;
      case 'new_review':
        return FontAwesomeIcons.star;
      default:
        return FontAwesomeIcons.bell;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'new_message':
        return Colors.blue;
      case 'session_request':
      case 'booking_created':
        return Colors.orange;
      case 'session_confirmed':
      case 'booking_confirmed':
      case 'session_assigned':
        return Colors.green;
      case 'session_cancelled':
      case 'booking_cancelled':
        return Colors.red;
      case 'studio_invitation':
        return Colors.purple;
      case 'new_review':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
