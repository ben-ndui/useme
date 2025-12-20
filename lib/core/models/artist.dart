/// Artist model for studio clients (simplified from Client - no B2B fields)
class Artist {
  final String id;
  final List<String> studioIds;
  final String name;
  final String? stageName;
  final String? email;
  final String? phone;
  final String? city;
  final List<String> genres;
  final String? bio;
  final String? photoUrl;
  final String? linkedUserId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Artist({
    required this.id,
    this.studioIds = const [],
    required this.name,
    this.stageName,
    this.email,
    this.phone,
    this.city,
    this.genres = const [],
    this.bio,
    this.photoUrl,
    this.linkedUserId,
    required this.createdAt,
    this.updatedAt,
  });

  bool hasStudio(String studioId) => studioIds.contains(studioId);

  static List<String> parseStudioIds(Map<String, dynamic> data) {
    if (data['studioIds'] is List) {
      return List<String>.from(data['studioIds'].map((e) => e.toString()));
    }
    if (data['studioId'] != null && data['studioId'].toString().isNotEmpty) {
      return [data['studioId'].toString()];
    }
    return [];
  }

  factory Artist.fromMap(Map<String, dynamic> map) {
    return Artist(
      id: map['id']?.toString() ?? '',
      studioIds: parseStudioIds(map),
      name: map['name']?.toString() ?? '',
      stageName: map['stageName']?.toString(),
      email: map['email']?.toString(),
      phone: map['phone']?.toString(),
      city: map['city']?.toString(),
      genres: List<String>.from(map['genres'] ?? []),
      bio: map['bio']?.toString(),
      photoUrl: map['photoUrl']?.toString(),
      linkedUserId: map['linkedUserId']?.toString(),
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
        'studioIds': studioIds,
        'name': name,
        'stageName': stageName,
        'email': email,
        'phone': phone,
        'city': city,
        'genres': genres,
        'bio': bio,
        'photoUrl': photoUrl,
        'linkedUserId': linkedUserId,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt?.millisecondsSinceEpoch,
      };

  Artist copyWith({
    String? id,
    List<String>? studioIds,
    String? name,
    String? stageName,
    String? email,
    String? phone,
    String? city,
    List<String>? genres,
    String? bio,
    String? photoUrl,
    String? linkedUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Artist(
        id: id ?? this.id,
        studioIds: studioIds ?? this.studioIds,
        name: name ?? this.name,
        stageName: stageName ?? this.stageName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        city: city ?? this.city,
        genres: genres ?? this.genres,
        bio: bio ?? this.bio,
        photoUrl: photoUrl ?? this.photoUrl,
        linkedUserId: linkedUserId ?? this.linkedUserId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  String get displayName => stageName ?? name;
  bool get isLinkedToUser => linkedUserId != null && linkedUserId!.isNotEmpty;
  bool get hasGenres => genres.isNotEmpty;
  String get genresDisplay => genres.join(', ');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Artist && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
