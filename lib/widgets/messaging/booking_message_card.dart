import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import '../../core/models/booking.dart';

/// Carte affichant une réservation partagée dans un message.
class BookingMessageCard extends StatelessWidget {
  final BusinessObjectAttachment businessObject;
  final bool isMe;
  final VoidCallback? onTap;

  const BookingMessageCard({
    super.key,
    required this.businessObject,
    required this.isMe,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final status = BookingStatusExtension.fromString(businessObject.status);
    final statusColor = _getStatusColor(status, colorScheme);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(colorScheme, statusColor, status),
            const SizedBox(height: 8),
            _buildTitle(theme),
            if (businessObject.clientName != null) ...[
              const SizedBox(height: 4),
              _buildArtistInfo(theme),
            ],
            if (businessObject.amount != null) ...[
              const SizedBox(height: 4),
              _buildAmount(theme),
            ],
            const SizedBox(height: 8),
            _buildFooter(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, Color statusColor, BookingStatus status) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.tertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: FaIcon(
              FontAwesomeIcons.calendarCheck,
              size: 14,
              color: colorScheme.tertiary,
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      businessObject.title,
      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildArtistInfo(ThemeData theme) {
    return Row(
      children: [
        FaIcon(
          FontAwesomeIcons.user,
          size: 11,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            businessObject.clientName!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAmount(ThemeData theme) {
    return Row(
      children: [
        FaIcon(
          FontAwesomeIcons.euroSign,
          size: 11,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          '${businessObject.amount!.toStringAsFixed(2)} \u20AC',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        FaIcon(
          FontAwesomeIcons.arrowUpRightFromSquare,
          size: 11,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Text(
          'Voir la réservation',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(BookingStatus status, ColorScheme colorScheme) {
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

/// Extension pour convertir un Booking en BusinessObjectAttachment.
extension BookingToAttachment on Booking {
  BusinessObjectAttachment toBusinessObjectAttachment() {
    return BusinessObjectAttachment(
      objectType: 'booking',
      objectId: id,
      title: 'Réservation #${id.substring(0, 6)}',
      status: status.name,
      amount: totalAmount,
      clientName: artistName,
    );
  }
}
