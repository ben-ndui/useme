import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Type de favori.
enum FavoriteType {
  studio,
  engineer,
  artist;

  static FavoriteType fromString(String? value) {
    return FavoriteType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FavoriteType.studio,
    );
  }
}

/// Modèle représentant un favori.
class Favorite extends Equatable {
  final String id;
  final String userId;
  final String targetId;
  final FavoriteType type;
  final DateTime createdAt;

  /// Données dénormalisées pour l'affichage.
  final String? targetName;
  final String? targetPhotoUrl;
  final String? targetAddress;

  const Favorite({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.type,
    required this.createdAt,
    this.targetName,
    this.targetPhotoUrl,
    this.targetAddress,
  });

  factory Favorite.fromMap(Map<String, dynamic> map, String id) {
    return Favorite(
      id: id,
      userId: map['userId'] ?? '',
      targetId: map['targetId'] ?? '',
      type: FavoriteType.fromString(map['type']),
      createdAt: _parseDate(map['createdAt']),
      targetName: map['targetName'],
      targetPhotoUrl: map['targetPhotoUrl'],
      targetAddress: map['targetAddress'],
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'targetId': targetId,
        'type': type.name,
        'createdAt': createdAt.toIso8601String(),
        if (targetName != null) 'targetName': targetName,
        if (targetPhotoUrl != null) 'targetPhotoUrl': targetPhotoUrl,
        if (targetAddress != null) 'targetAddress': targetAddress,
      };

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  @override
  List<Object?> get props => [id, userId, targetId, type];
}
