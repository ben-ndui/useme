import 'dart:convert';

/// A recently used account stored locally for quick re-login.
class RecentAccount {
  final String email;
  final String displayName;
  final String provider; // 'email', 'google', 'apple'
  final String role; // 'admin', 'worker', 'client', 'superAdmin'
  final String? photoUrl;
  final DateTime lastLoginAt;

  const RecentAccount({
    required this.email,
    required this.displayName,
    required this.provider,
    required this.role,
    this.photoUrl,
    required this.lastLoginAt,
  });

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'provider': provider,
        'role': role,
        'photoUrl': photoUrl,
        'lastLoginAt': lastLoginAt.toIso8601String(),
      };

  factory RecentAccount.fromMap(Map<String, dynamic> map) => RecentAccount(
        email: map['email'] ?? '',
        displayName: map['displayName'] ?? '',
        provider: map['provider'] ?? 'email',
        role: map['role'] ?? 'client',
        photoUrl: map['photoUrl'],
        lastLoginAt: DateTime.tryParse(map['lastLoginAt'] ?? '') ?? DateTime.now(),
      );

  /// Encode a list of accounts to a JSON string for SharedPreferences.
  static String encodeList(List<RecentAccount> accounts) =>
      jsonEncode(accounts.map((a) => a.toMap()).toList());

  /// Decode a JSON string from SharedPreferences to a list of accounts.
  static List<RecentAccount> decodeList(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => RecentAccount.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
