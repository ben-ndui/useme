import 'package:cloud_firestore/cloud_firestore.dart';
import 'studio_profile.dart';

/// Status d'une demande de revendication de studio
enum ClaimStatus { pending, approved, rejected }

/// Modèle pour une demande de revendication de studio
class StudioClaim {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final StudioProfile studioProfile;
  final ClaimStatus status;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;

  const StudioClaim({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.studioProfile,
    required this.status,
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
  });

  factory StudioClaim.fromMap(Map<String, dynamic> map, [String? docId]) {
    return StudioClaim(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userName: map['userName'] ?? '',
      studioProfile: StudioProfile.fromMap(map['studioProfile'] ?? {}),
      status: _parseStatus(map['status']),
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      reviewedAt: _parseDateTime(map['reviewedAt']),
      reviewedBy: map['reviewedBy'],
      rejectionReason: map['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'userEmail': userEmail,
        'userName': userName,
        'studioProfile': studioProfile.toMap(),
        'status': status.name,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'reviewedAt': reviewedAt?.millisecondsSinceEpoch,
        'reviewedBy': reviewedBy,
        'rejectionReason': rejectionReason,
      };

  bool get isPending => status == ClaimStatus.pending;
  bool get isApproved => status == ClaimStatus.approved;
  bool get isRejected => status == ClaimStatus.rejected;

  static ClaimStatus _parseStatus(String? value) {
    switch (value) {
      case 'approved':
        return ClaimStatus.approved;
      case 'rejected':
        return ClaimStatus.rejected;
      default:
        return ClaimStatus.pending;
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}
