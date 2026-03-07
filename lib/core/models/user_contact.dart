import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Category for a network contact.
enum ContactCategory {
  artist,
  engineer,
  producer,
  studio,
  other;

  static ContactCategory fromString(String? value) {
    return ContactCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ContactCategory.other,
    );
  }

  String get label {
    switch (this) {
      case ContactCategory.artist:
        return 'Artiste';
      case ContactCategory.engineer:
        return 'Ingénieur';
      case ContactCategory.producer:
        return 'Producteur';
      case ContactCategory.studio:
        return 'Studio';
      case ContactCategory.other:
        return 'Autre';
    }
  }
}

/// A contact in the user's professional network.
class UserContact extends Equatable {
  final String id;
  final String ownerId;
  final String? contactUserId;
  final String contactName;
  final String? contactEmail;
  final String? contactPhone;
  final String? contactPhotoUrl;
  final ContactCategory category;
  final String? note;
  final List<String> tags;
  final bool isOnPlatform;
  final DateTime createdAt;

  const UserContact({
    required this.id,
    required this.ownerId,
    this.contactUserId,
    required this.contactName,
    this.contactEmail,
    this.contactPhone,
    this.contactPhotoUrl,
    required this.category,
    this.note,
    this.tags = const [],
    this.isOnPlatform = false,
    required this.createdAt,
  });

  factory UserContact.fromMap(Map<String, dynamic> map, String id) {
    return UserContact(
      id: id,
      ownerId: map['ownerId'] ?? '',
      contactUserId: map['contactUserId'],
      contactName: map['contactName'] ?? '',
      contactEmail: map['contactEmail'],
      contactPhone: map['contactPhone'],
      contactPhotoUrl: map['contactPhotoUrl'],
      category: ContactCategory.fromString(map['category']),
      note: map['note'],
      tags: List<String>.from(map['tags'] ?? []),
      isOnPlatform: map['isOnPlatform'] ?? false,
      createdAt: _parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'ownerId': ownerId,
        if (contactUserId != null) 'contactUserId': contactUserId,
        'contactName': contactName,
        if (contactEmail != null) 'contactEmail': contactEmail,
        if (contactPhone != null) 'contactPhone': contactPhone,
        if (contactPhotoUrl != null) 'contactPhotoUrl': contactPhotoUrl,
        'category': category.name,
        if (note != null) 'note': note,
        'tags': tags,
        'isOnPlatform': isOnPlatform,
        'createdAt': createdAt.toIso8601String(),
      };

  UserContact copyWith({
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    String? contactPhotoUrl,
    ContactCategory? category,
    String? note,
    List<String>? tags,
  }) {
    return UserContact(
      id: id,
      ownerId: ownerId,
      contactUserId: contactUserId,
      contactName: contactName ?? this.contactName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      contactPhotoUrl: contactPhotoUrl ?? this.contactPhotoUrl,
      category: category ?? this.category,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      isOnPlatform: isOnPlatform,
      createdAt: createdAt,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  @override
  List<Object?> get props => [id, ownerId, contactUserId, contactName];
}
