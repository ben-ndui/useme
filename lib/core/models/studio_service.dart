/// StudioService model for service catalog (simplified from Product - no TVA)
class StudioService {
  final String id;
  final String studioId;
  final String name;
  final String? description;
  final double hourlyRate;
  final int minDurationHours;
  final int? maxDurationHours;
  final List<String> roomIds;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  StudioService({
    required this.id,
    required this.studioId,
    required this.name,
    this.description,
    required this.hourlyRate,
    this.minDurationHours = 1,
    this.maxDurationHours,
    this.roomIds = const [],
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory StudioService.fromMap(Map<String, dynamic> map) {
    // Support pour les deux formats (Flutter: hourlyRate, Backend IA: price)
    final hourlyRate = (map['hourlyRate'] ?? map['price'] ?? 0).toDouble();
    // Support pour les deux formats (Flutter: minDurationHours, Backend IA: duration en minutes)
    int minDurationHours = map['minDurationHours'] as int? ?? 1;
    if (map['duration'] != null && map['minDurationHours'] == null) {
      // Convertir minutes en heures si c'est le format backend
      minDurationHours = ((map['duration'] as int) / 60).ceil().clamp(1, 24);
    }

    return StudioService(
      id: map['id']?.toString() ?? '',
      studioId: map['studioId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      hourlyRate: hourlyRate,
      minDurationHours: minDurationHours,
      maxDurationHours: map['maxDurationHours'] as int?,
      roomIds: List<String>.from(map['roomIds'] ?? []),
      isActive: map['isActive'] ?? true,
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value.runtimeType.toString() == 'Timestamp') {
      return (value as dynamic).toDate();
    }
    return null;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'studioId': studioId,
        'name': name,
        'description': description,
        'hourlyRate': hourlyRate,
        'minDurationHours': minDurationHours,
        'maxDurationHours': maxDurationHours,
        'roomIds': roomIds,
        'isActive': isActive,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt?.millisecondsSinceEpoch,
      };

  StudioService copyWith({
    String? id,
    String? studioId,
    String? name,
    String? description,
    double? hourlyRate,
    int? minDurationHours,
    int? maxDurationHours,
    List<String>? roomIds,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      StudioService(
        id: id ?? this.id,
        studioId: studioId ?? this.studioId,
        name: name ?? this.name,
        description: description ?? this.description,
        hourlyRate: hourlyRate ?? this.hourlyRate,
        minDurationHours: minDurationHours ?? this.minDurationHours,
        maxDurationHours: maxDurationHours ?? this.maxDurationHours,
        roomIds: roomIds ?? this.roomIds,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  double calculatePrice(int durationMinutes) => hourlyRate * durationMinutes / 60;

  String getFormattedPrice() => '${hourlyRate.toStringAsFixed(0)} \u20AC/h';

  String getDurationRange() {
    if (maxDurationHours != null) {
      return '$minDurationHours-${maxDurationHours}h';
    }
    return 'Min ${minDurationHours}h';
  }
}
