import 'dart:math';

/// Status d'une invitation studio
enum InvitationStatus {
  pending,
  accepted,
  expired,
  cancelled;

  static InvitationStatus fromString(String? value) {
    return InvitationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => InvitationStatus.pending,
    );
  }
}

/// Invitation envoyée par un studio à un artiste
class StudioInvitation {
  final String id;
  final String studioId;
  final String studioName;
  final String? artistId; // Fiche artiste créée (optionnel)
  final String email;
  final String? phone;
  final String code; // Code unique: "USEME-XXXX"
  final InvitationStatus status;
  final String? acceptedByUserId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? acceptedAt;

  StudioInvitation({
    required this.id,
    required this.studioId,
    required this.studioName,
    this.artistId,
    required this.email,
    this.phone,
    required this.code,
    this.status = InvitationStatus.pending,
    this.acceptedByUserId,
    required this.createdAt,
    required this.expiresAt,
    this.acceptedAt,
  });

  /// Génère un code d'invitation unique
  static String generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    final code = List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
    return 'USEME-$code';
  }

  /// Vérifie si l'invitation est expirée
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Vérifie si l'invitation est valide (pending et non expirée)
  bool get isValid => status == InvitationStatus.pending && !isExpired;

  factory StudioInvitation.fromMap(Map<String, dynamic> map) {
    return StudioInvitation(
      id: map['id']?.toString() ?? '',
      studioId: map['studioId']?.toString() ?? '',
      studioName: map['studioName']?.toString() ?? '',
      artistId: map['artistId']?.toString(),
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString(),
      code: map['code']?.toString() ?? '',
      status: InvitationStatus.fromString(map['status']?.toString()),
      acceptedByUserId: map['acceptedByUserId']?.toString(),
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      expiresAt: _parseDateTime(map['expiresAt']) ?? DateTime.now().add(const Duration(days: 30)),
      acceptedAt: _parseDateTime(map['acceptedAt']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is DateTime) return value;
    if (value.runtimeType.toString() == 'Timestamp') {
      return (value as dynamic).toDate();
    }
    return null;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'studioId': studioId,
        'studioName': studioName,
        'artistId': artistId,
        'email': email,
        'phone': phone,
        'code': code,
        'status': status.name,
        'acceptedByUserId': acceptedByUserId,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'expiresAt': expiresAt.millisecondsSinceEpoch,
        'acceptedAt': acceptedAt?.millisecondsSinceEpoch,
      };

  StudioInvitation copyWith({
    String? id,
    String? studioId,
    String? studioName,
    String? artistId,
    String? email,
    String? phone,
    String? code,
    InvitationStatus? status,
    String? acceptedByUserId,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? acceptedAt,
  }) =>
      StudioInvitation(
        id: id ?? this.id,
        studioId: studioId ?? this.studioId,
        studioName: studioName ?? this.studioName,
        artistId: artistId ?? this.artistId,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        code: code ?? this.code,
        status: status ?? this.status,
        acceptedByUserId: acceptedByUserId ?? this.acceptedByUserId,
        createdAt: createdAt ?? this.createdAt,
        expiresAt: expiresAt ?? this.expiresAt,
        acceptedAt: acceptedAt ?? this.acceptedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudioInvitation && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
