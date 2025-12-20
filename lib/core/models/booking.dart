/// Booking status enum
enum BookingStatus {
  draft,
  confirmed,
  completed,
  cancelled,
}

extension BookingStatusExtension on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.draft:
        return 'Brouillon';
      case BookingStatus.confirmed:
        return 'Confirmée';
      case BookingStatus.completed:
        return 'Terminée';
      case BookingStatus.cancelled:
        return 'Annulée';
    }
  }

  static BookingStatus fromString(String? value) {
    switch (value) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.draft;
    }
  }
}

/// Booking model for session reservations (simplified - no invoicing)
class Booking {
  final String id;
  final String studioId;
  final String artistId;
  final String artistName;
  final String? sessionId;
  final BookingStatus status;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? notes;
  final String? cancellationReason;

  Booking({
    required this.id,
    required this.studioId,
    required this.artistId,
    required this.artistName,
    this.sessionId,
    this.status = BookingStatus.draft,
    required this.totalAmount,
    required this.createdAt,
    this.confirmedAt,
    this.completedAt,
    this.cancelledAt,
    this.notes,
    this.cancellationReason,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id']?.toString() ?? '',
      studioId: map['studioId']?.toString() ?? '',
      artistId: map['artistId']?.toString() ?? '',
      artistName: map['artistName']?.toString() ?? '',
      sessionId: map['sessionId']?.toString(),
      status: BookingStatusExtension.fromString(map['status']?.toString()),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      confirmedAt: _parseDateTime(map['confirmedAt']),
      completedAt: _parseDateTime(map['completedAt']),
      cancelledAt: _parseDateTime(map['cancelledAt']),
      notes: map['notes']?.toString(),
      cancellationReason: map['cancellationReason']?.toString(),
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
        'artistId': artistId,
        'artistName': artistName,
        'sessionId': sessionId,
        'status': status.name,
        'totalAmount': totalAmount,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'confirmedAt': confirmedAt?.millisecondsSinceEpoch,
        'completedAt': completedAt?.millisecondsSinceEpoch,
        'cancelledAt': cancelledAt?.millisecondsSinceEpoch,
        'notes': notes,
        'cancellationReason': cancellationReason,
      };

  Booking copyWith({
    String? id,
    String? studioId,
    String? artistId,
    String? artistName,
    String? sessionId,
    BookingStatus? status,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? confirmedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? notes,
    String? cancellationReason,
  }) =>
      Booking(
        id: id ?? this.id,
        studioId: studioId ?? this.studioId,
        artistId: artistId ?? this.artistId,
        artistName: artistName ?? this.artistName,
        sessionId: sessionId ?? this.sessionId,
        status: status ?? this.status,
        totalAmount: totalAmount ?? this.totalAmount,
        createdAt: createdAt ?? this.createdAt,
        confirmedAt: confirmedAt ?? this.confirmedAt,
        completedAt: completedAt ?? this.completedAt,
        cancelledAt: cancelledAt ?? this.cancelledAt,
        notes: notes ?? this.notes,
        cancellationReason: cancellationReason ?? this.cancellationReason,
      );

  // Helper getters
  bool get isDraft => status == BookingStatus.draft;
  bool get isConfirmed => status == BookingStatus.confirmed;
  bool get isCompleted => status == BookingStatus.completed;
  bool get isCancelled => status == BookingStatus.cancelled;
  bool get hasSession => sessionId != null;

  String getFormattedAmount() => '${totalAmount.toStringAsFixed(2)} \u20AC';
}
