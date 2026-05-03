import 'package:flutter_test/flutter_test.dart';
import 'package:uzme/core/models/favorite.dart';

void main() {
  final now = DateTime(2026, 3, 9, 10, 0);

  final testFavorite = Favorite(
    id: 'fav-1',
    userId: 'user-1',
    targetId: 'studio-1',
    type: FavoriteType.studio,
    createdAt: now,
    targetName: 'Cool Studio',
    targetPhotoUrl: 'https://photo.com/img.jpg',
    targetAddress: '1 rue de la Musique, Paris',
  );

  group('FavoriteType', () {
    test('fromString parses valid types', () {
      expect(FavoriteType.fromString('studio'), FavoriteType.studio);
      expect(FavoriteType.fromString('engineer'), FavoriteType.engineer);
      expect(FavoriteType.fromString('artist'), FavoriteType.artist);
    });

    test('fromString defaults to studio for unknown', () {
      expect(FavoriteType.fromString('unknown'), FavoriteType.studio);
      expect(FavoriteType.fromString(null), FavoriteType.studio);
    });
  });

  group('fromMap', () {
    test('parses all fields', () {
      final fav = Favorite.fromMap({
        'userId': 'user-1',
        'targetId': 'studio-1',
        'type': 'studio',
        'createdAt': '2026-03-09T10:00:00.000',
        'targetName': 'Cool Studio',
        'targetPhotoUrl': 'https://photo.com/img.jpg',
        'targetAddress': '1 rue de la Musique',
      }, 'fav-1');

      expect(fav.id, 'fav-1');
      expect(fav.userId, 'user-1');
      expect(fav.targetId, 'studio-1');
      expect(fav.type, FavoriteType.studio);
      expect(fav.targetName, 'Cool Studio');
      expect(fav.targetPhotoUrl, 'https://photo.com/img.jpg');
      expect(fav.targetAddress, '1 rue de la Musique');
    });

    test('parses engineer type', () {
      final fav = Favorite.fromMap({
        'userId': 'u',
        'targetId': 't',
        'type': 'engineer',
      }, 'fav-2');
      expect(fav.type, FavoriteType.engineer);
    });

    test('handles missing fields', () {
      final fav = Favorite.fromMap({}, 'fav-3');
      expect(fav.userId, '');
      expect(fav.targetId, '');
      expect(fav.type, FavoriteType.studio);
      expect(fav.targetName, isNull);
      expect(fav.targetPhotoUrl, isNull);
      expect(fav.targetAddress, isNull);
    });
  });

  group('toMap', () {
    test('includes all required fields', () {
      final map = testFavorite.toMap();
      expect(map['userId'], 'user-1');
      expect(map['targetId'], 'studio-1');
      expect(map['type'], 'studio');
      expect(map['createdAt'], isA<String>());
      expect(map['targetName'], 'Cool Studio');
      expect(map['targetPhotoUrl'], 'https://photo.com/img.jpg');
      expect(map['targetAddress'], '1 rue de la Musique, Paris');
    });

    test('omits null optional fields', () {
      final fav = Favorite(
        id: 'f',
        userId: 'u',
        targetId: 't',
        type: FavoriteType.artist,
        createdAt: now,
      );
      final map = fav.toMap();
      expect(map.containsKey('targetName'), isFalse);
      expect(map.containsKey('targetPhotoUrl'), isFalse);
      expect(map.containsKey('targetAddress'), isFalse);
    });
  });

  group('equality', () {
    test('same id/userId/targetId/type are equal', () {
      final a = testFavorite;
      final b = Favorite(
        id: 'fav-1',
        userId: 'user-1',
        targetId: 'studio-1',
        type: FavoriteType.studio,
        createdAt: DateTime(2020, 1, 1), // different date
        targetName: 'Different Name', // different name
      );
      expect(a, equals(b)); // Equatable uses props: [id, userId, targetId, type]
    });

    test('different targetId not equal', () {
      final b = Favorite(
        id: 'fav-1',
        userId: 'user-1',
        targetId: 'studio-2',
        type: FavoriteType.studio,
        createdAt: now,
      );
      expect(testFavorite, isNot(equals(b)));
    });
  });
}
