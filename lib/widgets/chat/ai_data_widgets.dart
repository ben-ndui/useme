import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

/// Widget pour afficher une liste de sessions
class AISessionsCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const AISessionsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessions = (data['sessions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final count = data['count'] ?? sessions.length;

    if (sessions.isEmpty) {
      return _buildEmptyCard(theme, 'Aucune session trouvée', FontAwesomeIcons.calendar);
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.purple.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, 'Sessions', FontAwesomeIcons.calendar, count),
          ...sessions.take(5).map((s) => _buildSessionItem(theme, s)),
          if (sessions.length > 5) _buildMoreIndicator(theme, sessions.length - 5),
        ],
      ),
    );
  }

  Widget _buildSessionItem(ThemeData theme, Map<String, dynamic> session) {
    final date = _parseDate(session['date']);
    final status = session['status'] ?? 'unknown';
    final statusColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha:0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session['artistName'] ?? session['serviceName'] ?? 'Session',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${session['serviceName'] ?? ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date != null ? DateFormat('dd/MM').format(date) : '-',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${session['startTime'] ?? ''} - ${session['endTime'] ?? ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    return switch (status) {
      'confirmed' => Colors.green,
      'pending' => Colors.orange,
      'inProgress' => Colors.blue,
      'completed' => Colors.grey,
      'cancelled' || 'declined' => Colors.red,
      _ => Colors.grey,
    };
  }

  DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  Widget _buildHeader(ThemeData theme, String title, IconData icon, int count) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha:0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          FaIcon(icon, size: 14, color: Colors.purple),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(ThemeData theme, String message, IconData icon) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            FaIcon(icon, size: 16, color: theme.colorScheme.outline),
            const SizedBox(width: 12),
            Text(message, style: TextStyle(color: theme.colorScheme.outline)),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreIndicator(ThemeData theme, int remaining) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        '+ $remaining autres...',
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.purple,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Widget pour afficher une liste de services
class AIServicesCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const AIServicesCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final services = (data['services'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    if (services.isEmpty) {
      return _buildEmptyCard(theme, 'Aucun service trouvé');
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.purple.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, 'Services', FontAwesomeIcons.tags, services.length),
          ...services.map((s) => _buildServiceItem(theme, s)),
        ],
      ),
    );
  }

  Widget _buildServiceItem(ThemeData theme, Map<String, dynamic> service) {
    final price = service['price'] ?? service['pricePerHour'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha:0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['name'] ?? 'Service',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (service['description'] != null)
                  Text(
                    service['description'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (price != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$price€/h',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String title, IconData icon, int count) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha:0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          FaIcon(icon, size: 14, color: Colors.purple),
          const SizedBox(width: 8),
          Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count', style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.purple, fontWeight: FontWeight.bold,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(ThemeData theme, String message) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            FaIcon(FontAwesomeIcons.tags, size: 16, color: theme.colorScheme.outline),
            const SizedBox(width: 12),
            Text(message, style: TextStyle(color: theme.colorScheme.outline)),
          ],
        ),
      ),
    );
  }
}

/// Widget pour afficher l'équipe
class AITeamCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const AITeamCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final engineers = (data['engineers'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    if (engineers.isEmpty) {
      return _buildEmptyCard(theme);
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.purple.withValues(alpha:0.2)),
      ),
      child: Column(
        children: [
          _buildHeader(theme, engineers.length),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: engineers.map((e) => _buildEngineerChip(theme, e)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngineerChip(ThemeData theme, Map<String, dynamic> engineer) {
    final isAvailable = engineer['isAvailable'] ?? true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green.withValues(alpha:0.1) : Colors.grey.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAvailable ? Colors.green.withValues(alpha:0.3) : Colors.grey.withValues(alpha:0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.purple.withValues(alpha:0.2),
            child: Text(
              (engineer['name'] ?? 'I')[0].toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            engineer['name'] ?? 'Ingénieur',
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          if (!isAvailable) ...[
            const SizedBox(width: 4),
            Icon(Icons.do_not_disturb, size: 12, color: Colors.grey.shade600),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, int count) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha:0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.userTie, size: 14, color: Colors.purple),
          const SizedBox(width: 8),
          Text('Équipe', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count', style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.purple, fontWeight: FontWeight.bold,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            FaIcon(FontAwesomeIcons.userTie, size: 16, color: theme.colorScheme.outline),
            const SizedBox(width: 12),
            Text('Aucun ingénieur dans l\'équipe', style: TextStyle(color: theme.colorScheme.outline)),
          ],
        ),
      ),
    );
  }
}

/// Widget pour afficher les statistiques
class AIStatsCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const AIStatsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.purple.withValues(alpha:0.2)),
      ),
      child: Column(
        children: [
          _buildHeader(theme),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildStatItem(theme, 'Sessions', data['totalSessions'] ?? data['sessionsCount'] ?? 0, FontAwesomeIcons.calendar, Colors.blue),
                _buildStatItem(theme, 'Revenus', '${data['totalRevenue'] ?? data['revenue'] ?? 0}€', FontAwesomeIcons.euroSign, Colors.green),
                _buildStatItem(theme, 'En attente', data['pendingCount'] ?? data['pending'] ?? 0, FontAwesomeIcons.clock, Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, dynamic value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.1),
              shape: BoxShape.circle,
            ),
            child: FaIcon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha:0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.chartLine, size: 14, color: Colors.purple),
          const SizedBox(width: 8),
          Text('Statistiques', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Widget pour afficher les disponibilités
class AIAvailabilityCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const AIAvailabilityCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slots = (data['slots'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final date = data['date'];

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.purple.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, date),
          Padding(
            padding: const EdgeInsets.all(12),
            child: slots.isEmpty
                ? Text('Aucun créneau disponible', style: TextStyle(color: theme.colorScheme.outline))
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: slots.map((s) => _buildSlotChip(theme, s)).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotChip(ThemeData theme, Map<String, dynamic> slot) {
    final isAvailable = slot['available'] ?? true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green.withValues(alpha:0.1) : Colors.red.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAvailable ? Colors.green.withValues(alpha:0.3) : Colors.red.withValues(alpha:0.3),
        ),
      ),
      child: Text(
        slot['time'] ?? slot['startTime'] ?? '',
        style: theme.textTheme.bodySmall?.copyWith(
          color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String? date) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha:0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.clock, size: 14, color: Colors.purple),
          const SizedBox(width: 8),
          Text('Disponibilités', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          if (date != null) ...[
            const Spacer(),
            Text(date, style: theme.textTheme.bodySmall?.copyWith(color: Colors.purple)),
          ],
        ],
      ),
    );
  }
}

/// Widget pour afficher les demandes en attente
class AIPendingRequestsCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const AIPendingRequestsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requests = (data['requests'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    if (requests.isEmpty) {
      return Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              FaIcon(FontAwesomeIcons.inbox, size: 16, color: theme.colorScheme.outline),
              const SizedBox(width: 12),
              Text('Aucune demande en attente', style: TextStyle(color: theme.colorScheme.outline)),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.withValues(alpha:0.3)),
      ),
      child: Column(
        children: [
          _buildHeader(theme, requests.length),
          ...requests.take(5).map((r) => _buildRequestItem(theme, r)),
        ],
      ),
    );
  }

  Widget _buildRequestItem(ThemeData theme, Map<String, dynamic> request) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha:0.3))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha:0.1),
              shape: BoxShape.circle,
            ),
            child: const FaIcon(FontAwesomeIcons.userClock, size: 12, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request['artistName'] ?? 'Artiste',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  request['serviceName'] ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),
          Text(
            request['date'] ?? '',
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, int count) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha:0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.inbox, size: 14, color: Colors.orange),
          const SizedBox(width: 8),
          Text('Demandes en attente', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count', style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.orange.shade800, fontWeight: FontWeight.bold,
            )),
          ),
        ],
      ),
    );
  }
}

/// Widget pour afficher une liste de studios
class AIStudiosCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isFavorites;

  const AIStudiosCard({
    super.key,
    required this.data,
    this.isFavorites = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studios = (data['studios'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    if (studios.isEmpty) {
      return _buildEmptyCard(
        theme,
        isFavorites ? 'Aucun studio favori' : 'Aucun studio trouvé',
      );
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.purple.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, studios.length),
          ...studios.take(5).map((s) => _buildStudioItem(theme, s)),
          if (studios.length > 5) _buildMoreIndicator(theme, studios.length - 5),
        ],
      ),
    );
  }

  Widget _buildStudioItem(ThemeData theme, Map<String, dynamic> studio) {
    final isPartner = studio['isPartner'] == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha:0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.building,
                size: 16,
                color: Colors.purple.shade400,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        studio['name'] ?? 'Studio',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isPartner) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha:0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(FontAwesomeIcons.solidStar, size: 8, color: Colors.amber.shade700),
                            const SizedBox(width: 3),
                            Text(
                              'Partenaire',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 9,
                                color: Colors.amber.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.locationDot,
                      size: 10,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        studio['city'] ?? studio['address'] ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isFavorites)
            FaIcon(
              FontAwesomeIcons.solidHeart,
              size: 14,
              color: Colors.red.shade400,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, int count) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha:0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          FaIcon(
            isFavorites ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.building,
            size: 14,
            color: isFavorites ? Colors.red.shade400 : Colors.purple,
          ),
          const SizedBox(width: 8),
          Text(
            isFavorites ? 'Studios favoris' : 'Studios',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(ThemeData theme, String message) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            FaIcon(
              isFavorites ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.building,
              size: 16,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Text(message, style: TextStyle(color: theme.colorScheme.outline)),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreIndicator(ThemeData theme, int remaining) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        '+ $remaining autres...',
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.purple,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
