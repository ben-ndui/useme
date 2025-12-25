import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a room/space within a studio that can be booked
class StudioRoom {
  final String id;
  final String studioId;
  final String name;
  final String? description;
  final double? hourlyRate;
  final bool requiresEngineer;
  final List<String> photoUrls;
  final List<String> equipmentList;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudioRoom({
    required this.id,
    required this.studioId,
    required this.name,
    this.description,
    this.hourlyRate,
    this.requiresEngineer = true,
    this.photoUrls = const [],
    this.equipmentList = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudioRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudioRoom(
      id: doc.id,
      studioId: data['studioId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      hourlyRate: (data['hourlyRate'] as num?)?.toDouble(),
      requiresEngineer: data['requiresEngineer'] ?? true,
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      equipmentList: List<String>.from(data['equipmentList'] ?? []),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studioId': studioId,
      'name': name,
      'description': description,
      'hourlyRate': hourlyRate,
      'requiresEngineer': requiresEngineer,
      'photoUrls': photoUrls,
      'equipmentList': equipmentList,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  StudioRoom copyWith({
    String? id,
    String? studioId,
    String? name,
    String? description,
    double? hourlyRate,
    bool? requiresEngineer,
    List<String>? photoUrls,
    List<String>? equipmentList,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudioRoom(
      id: id ?? this.id,
      studioId: studioId ?? this.studioId,
      name: name ?? this.name,
      description: description ?? this.description,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      requiresEngineer: requiresEngineer ?? this.requiresEngineer,
      photoUrls: photoUrls ?? this.photoUrls,
      equipmentList: equipmentList ?? this.equipmentList,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Display label for room type
  String get accessTypeLabel => requiresEngineer ? 'Avec ingénieur' : 'Libre accès';
}
