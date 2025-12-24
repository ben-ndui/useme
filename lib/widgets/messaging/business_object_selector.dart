import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import '../../core/models/session.dart';
import '../../core/models/booking.dart';
import 'session_message_card.dart';
import 'booking_message_card.dart';

/// Type d'objet à sélectionner.
enum BusinessObjectType { session, booking }

/// Bottom sheet pour sélectionner une session ou réservation à partager.
class BusinessObjectSelectorBottomSheet extends StatefulWidget {
  final List<Session> sessions;
  final List<Booking> bookings;
  final void Function(BusinessObjectAttachment attachment) onSelected;

  const BusinessObjectSelectorBottomSheet({
    super.key,
    required this.sessions,
    required this.bookings,
    required this.onSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required List<Session> sessions,
    required List<Booking> bookings,
    required void Function(BusinessObjectAttachment attachment) onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BusinessObjectSelectorBottomSheet(
        sessions: sessions,
        bookings: bookings,
        onSelected: onSelected,
      ),
    );
  }

  @override
  State<BusinessObjectSelectorBottomSheet> createState() =>
      _BusinessObjectSelectorBottomSheetState();
}

class _BusinessObjectSelectorBottomSheetState
    extends State<BusinessObjectSelectorBottomSheet> {
  BusinessObjectType _selectedType = BusinessObjectType.session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            _buildHeader(theme),
            _buildTabs(theme),
            Expanded(child: _buildList(scrollController)),
          ],
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Partager',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              theme,
              icon: FontAwesomeIcons.music,
              label: 'Sessions',
              count: widget.sessions.length,
              isSelected: _selectedType == BusinessObjectType.session,
              onTap: () => setState(() => _selectedType = BusinessObjectType.session),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTab(
              theme,
              icon: FontAwesomeIcons.calendarCheck,
              label: 'Réservations',
              count: widget.bookings.length,
              isSelected: _selectedType == BusinessObjectType.booking,
              onTap: () => setState(() => _selectedType = BusinessObjectType.booking),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, size: 14, color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: colorScheme.outline.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
              child: Text('$count', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(ScrollController controller) {
    if (_selectedType == BusinessObjectType.session) {
      return _buildSessionList(controller);
    }
    return _buildBookingList(controller);
  }

  Widget _buildSessionList(ScrollController controller) {
    if (widget.sessions.isEmpty) {
      return _buildEmptyState('Aucune session');
    }

    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.all(16),
      itemCount: widget.sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final session = widget.sessions[index];
        return _SessionTile(
          session: session,
          onTap: () {
            Navigator.pop(context);
            widget.onSelected(session.toBusinessObjectAttachment());
          },
        );
      },
    );
  }

  Widget _buildBookingList(ScrollController controller) {
    if (widget.bookings.isEmpty) {
      return _buildEmptyState('Aucune réservation');
    }

    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.all(16),
      itemCount: widget.bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final booking = widget.bookings[index];
        return _BookingTile(
          booking: booking,
          onTap: () {
            Navigator.pop(context);
            widget.onSelected(booking.toBusinessObjectAttachment());
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.inbox, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final Session session;
  final VoidCallback onTap;

  const _SessionTile({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
        child: Center(child: FaIcon(FontAwesomeIcons.music, size: 16, color: theme.colorScheme.primary)),
      ),
      title: Text(session.typeLabel, style: theme.textTheme.titleSmall),
      subtitle: Text('${session.artistName} - ${dateFormat.format(session.scheduledStart)}', style: theme.textTheme.bodySmall),
      trailing: _buildStatusChip(session.displayStatus, theme),
    );
  }

  Widget _buildStatusChip(SessionStatus status, ThemeData theme) {
    final color = _getColor(status, theme.colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Color _getColor(SessionStatus status, ColorScheme colorScheme) {
    switch (status) {
      case SessionStatus.pending:
        return Colors.orange;
      case SessionStatus.confirmed:
        return Colors.blue;
      case SessionStatus.inProgress:
        return Colors.purple;
      case SessionStatus.completed:
        return Colors.green;
      case SessionStatus.cancelled:
      case SessionStatus.noShow:
        return colorScheme.error;
    }
  }
}

class _BookingTile extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const _BookingTile({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: theme.colorScheme.tertiaryContainer, borderRadius: BorderRadius.circular(10)),
        child: Center(child: FaIcon(FontAwesomeIcons.calendarCheck, size: 16, color: theme.colorScheme.tertiary)),
      ),
      title: Text('Réservation #${booking.id.substring(0, 6)}', style: theme.textTheme.titleSmall),
      subtitle: Text('${booking.artistName} - ${booking.getFormattedAmount()}', style: theme.textTheme.bodySmall),
      trailing: _buildStatusChip(booking.status, theme),
    );
  }

  Widget _buildStatusChip(BookingStatus status, ThemeData theme) {
    final color = _getColor(status, theme.colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Color _getColor(BookingStatus status, ColorScheme colorScheme) {
    switch (status) {
      case BookingStatus.draft:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return colorScheme.error;
    }
  }
}
