import 'package:flutter_test/flutter_test.dart';
import 'package:useme/core/models/user_contact.dart';

void main() {
  group('ContactCategory', () {
    test('fromString parses valid values', () {
      expect(ContactCategory.fromString('artist'), ContactCategory.artist);
      expect(ContactCategory.fromString('engineer'), ContactCategory.engineer);
      expect(ContactCategory.fromString('producer'), ContactCategory.producer);
      expect(ContactCategory.fromString('studio'), ContactCategory.studio);
      expect(ContactCategory.fromString('other'), ContactCategory.other);
    });

    test('fromString defaults to other for invalid value', () {
      expect(ContactCategory.fromString('invalid'), ContactCategory.other);
      expect(ContactCategory.fromString(null), ContactCategory.other);
    });

    test('label returns correct string', () {
      expect(ContactCategory.artist.label, 'Artiste');
      expect(ContactCategory.engineer.label, 'Ingénieur');
      expect(ContactCategory.producer.label, 'Producteur');
      expect(ContactCategory.studio.label, 'Studio');
      expect(ContactCategory.other.label, 'Autre');
    });
  });

  group('UserContact', () {
    test('fromMap creates correct object', () {
      final map = {
        'ownerId': 'owner-1',
        'contactUserId': 'user-1',
        'contactName': 'John Doe',
        'contactEmail': 'john@test.com',
        'contactPhone': '+33612345678',
        'category': 'artist',
        'note': 'Great collab',
        'tags': ['vocalist', 'songwriter'],
        'isOnPlatform': true,
        'createdAt': '2024-01-01T00:00:00.000',
      };

      final contact = UserContact.fromMap(map, 'contact-1');

      expect(contact.id, 'contact-1');
      expect(contact.ownerId, 'owner-1');
      expect(contact.contactUserId, 'user-1');
      expect(contact.contactName, 'John Doe');
      expect(contact.contactEmail, 'john@test.com');
      expect(contact.contactPhone, '+33612345678');
      expect(contact.category, ContactCategory.artist);
      expect(contact.note, 'Great collab');
      expect(contact.tags, ['vocalist', 'songwriter']);
      expect(contact.isOnPlatform, true);
    });

    test('toMap produces correct map', () {
      final contact = UserContact(
        id: 'c1',
        ownerId: 'o1',
        contactUserId: 'u1',
        contactName: 'Jane',
        contactEmail: 'jane@test.com',
        category: ContactCategory.engineer,
        note: 'Mix engineer',
        tags: ['mix'],
        isOnPlatform: true,
        createdAt: DateTime(2024),
      );

      final map = contact.toMap();

      expect(map['ownerId'], 'o1');
      expect(map['contactUserId'], 'u1');
      expect(map['contactName'], 'Jane');
      expect(map['contactEmail'], 'jane@test.com');
      expect(map['category'], 'engineer');
      expect(map['note'], 'Mix engineer');
      expect(map['tags'], ['mix']);
      expect(map['isOnPlatform'], true);
    });

    test('toMap omits null optional fields', () {
      final contact = UserContact(
        id: 'c1',
        ownerId: 'o1',
        contactName: 'Jane',
        category: ContactCategory.other,
        createdAt: DateTime(2024),
      );

      final map = contact.toMap();

      expect(map.containsKey('contactUserId'), false);
      expect(map.containsKey('contactEmail'), false);
      expect(map.containsKey('contactPhone'), false);
      expect(map.containsKey('contactPhotoUrl'), false);
      expect(map.containsKey('note'), false);
    });

    test('copyWith creates modified copy', () {
      final contact = UserContact(
        id: 'c1',
        ownerId: 'o1',
        contactName: 'Original',
        category: ContactCategory.artist,
        createdAt: DateTime(2024),
      );

      final updated = contact.copyWith(
        contactName: 'Updated',
        category: ContactCategory.producer,
        note: 'New note',
        tags: ['tag1'],
      );

      expect(updated.contactName, 'Updated');
      expect(updated.category, ContactCategory.producer);
      expect(updated.note, 'New note');
      expect(updated.tags, ['tag1']);
      // Unchanged
      expect(updated.id, 'c1');
      expect(updated.ownerId, 'o1');
    });

    test('fromMap handles missing fields gracefully', () {
      final contact = UserContact.fromMap({}, 'id');

      expect(contact.ownerId, '');
      expect(contact.contactName, '');
      expect(contact.contactUserId, null);
      expect(contact.category, ContactCategory.other);
      expect(contact.tags, isEmpty);
      expect(contact.isOnPlatform, false);
    });

    test('equatable uses id, ownerId, contactUserId, contactName', () {
      final c1 = UserContact(
        id: 'c1',
        ownerId: 'o1',
        contactName: 'A',
        category: ContactCategory.artist,
        createdAt: DateTime(2024),
      );
      final c2 = UserContact(
        id: 'c1',
        ownerId: 'o1',
        contactName: 'A',
        category: ContactCategory.engineer,
        createdAt: DateTime(2025),
      );

      expect(c1, c2);
    });
  });
}
