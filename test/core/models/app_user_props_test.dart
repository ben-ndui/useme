import 'package:flutter_test/flutter_test.dart';
import 'package:useme/core/models/app_user.dart';

void main() {
  group('AppUser Equatable props', () {
    test('users with different photoURL are NOT equal', () {
      final user1 = AppUser.fromMap({
        'uid': 'u1',
        'email': 'a@b.com',
        'name': 'Test',
        'role': 'client',
        'photoUrl': 'https://example.com/photo1.jpg',
      }, 'u1');

      final user2 = AppUser.fromMap({
        'uid': 'u1',
        'email': 'a@b.com',
        'name': 'Test',
        'role': 'client',
        'photoUrl': 'https://example.com/photo2.jpg',
      }, 'u1');

      expect(user1 == user2, isFalse);
    });

    test('users with same photoURL are equal', () {
      final user1 = AppUser.fromMap({
        'uid': 'u1',
        'email': 'a@b.com',
        'name': 'Test',
        'role': 'client',
        'photoUrl': 'https://example.com/photo.jpg',
      }, 'u1');

      final user2 = AppUser.fromMap({
        'uid': 'u1',
        'email': 'a@b.com',
        'name': 'Test',
        'role': 'client',
        'photoUrl': 'https://example.com/photo.jpg',
      }, 'u1');

      expect(user1 == user2, isTrue);
    });

    test('users with different displayName are NOT equal', () {
      final user1 = AppUser.fromMap({
        'uid': 'u1',
        'email': 'a@b.com',
        'displayName': 'Alice',
        'role': 'client',
      }, 'u1');

      final user2 = AppUser.fromMap({
        'uid': 'u1',
        'email': 'a@b.com',
        'displayName': 'Bob',
        'role': 'client',
      }, 'u1');

      expect(user1 == user2, isFalse);
    });

    test('users with different name are NOT equal', () {
      final user1 = AppUser.fromMap({
        'uid': 'u1',
        'email': 'a@b.com',
        'name': 'Alice',
        'role': 'client',
      }, 'u1');

      final user2 = AppUser.fromMap({
        'uid': 'u1',
        'email': 'a@b.com',
        'name': 'Bob',
        'role': 'client',
      }, 'u1');

      expect(user1 == user2, isFalse);
    });

    test('users with different phoneNumber are NOT equal', () {
      final user1 = AppUser.fromMap({
        'uid': 'u1',
        'email': 'a@b.com',
        'role': 'client',
        'phoneNumber': '+33600000000',
      }, 'u1');

      final user2 = AppUser.fromMap({
        'uid': 'u1',
        'email': 'a@b.com',
        'role': 'client',
        'phoneNumber': '+33611111111',
      }, 'u1');

      expect(user1 == user2, isFalse);
    });

    test('photoURL null vs non-null are NOT equal', () {
      final user1 = AppUser.fromMap({
        'uid': 'u1',
        'email': 'a@b.com',
        'role': 'client',
      }, 'u1');

      final user2 = AppUser.fromMap({
        'uid': 'u1',
        'email': 'a@b.com',
        'role': 'client',
        'photoUrl': 'https://example.com/photo.jpg',
      }, 'u1');

      expect(user1 == user2, isFalse);
    });
  });
}
