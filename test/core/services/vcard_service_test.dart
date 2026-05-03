import 'package:flutter_test/flutter_test.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:uzme/core/models/app_user.dart';
import 'package:uzme/core/models/user_contact.dart';
import 'package:uzme/core/services/vcard_service.dart';

void main() {
  late VCardService service;

  setUp(() => service = VCardService());

  group('VCardService.fromContact', () {
    test('generates valid vCard 3.0 structure', () {
      final contact = UserContact(
        id: 'c1',
        ownerId: 'owner1',
        contactUserId: 'user123',
        contactName: 'DJ Smooth',
        contactEmail: 'dj@smooth.com',
        contactPhone: '+33612345678',
        contactPhotoUrl: 'https://example.com/photo.jpg',
        category: ContactCategory.artist,
        createdAt: DateTime(2026),
      );

      final vcard = service.fromContact(contact);

      expect(vcard, contains('BEGIN:VCARD'));
      expect(vcard, contains('VERSION:3.0'));
      expect(vcard, contains('FN:DJ Smooth'));
      expect(vcard, contains('EMAIL:dj@smooth.com'));
      expect(vcard, contains('TEL:+33612345678'));
      expect(vcard, contains('PHOTO;VALUE=uri:https://example.com/photo.jpg'));
      expect(vcard, contains('URL:https://uzme.app/u/user123'));
      expect(vcard, contains('NOTE:UZME Contact - Artiste'));
      expect(vcard, contains('END:VCARD'));
    });

    test('omits optional fields when null', () {
      final contact = UserContact(
        id: 'c2',
        ownerId: 'owner1',
        contactName: 'Test',
        category: ContactCategory.other,
        createdAt: DateTime(2026),
      );

      final vcard = service.fromContact(contact);

      expect(vcard, isNot(contains('EMAIL:')));
      expect(vcard, isNot(contains('TEL:')));
      expect(vcard, isNot(contains('PHOTO')));
      expect(vcard, contains('FN:Test'));
    });

    test('escapes commas in name', () {
      final contact = UserContact(
        id: 'c3',
        ownerId: 'owner1',
        contactName: 'Last, First',
        category: ContactCategory.other,
        createdAt: DateTime(2026),
      );

      final vcard = service.fromContact(contact);
      expect(vcard, contains(r'FN:Last\, First'));
    });
  });

  group('VCardService.fromUser', () {
    test('generates valid vCard from AppUser', () {
      const user = AppUser(
        uid: 'uid123',
        email: 'artist@uzme.app',
        displayName: 'MC Flow',
        phoneNumber: '+33698765432',
        city: 'Nice',
        role: BaseUserRole.client,
      );

      final vcard = service.fromUser(user);

      expect(vcard, contains('BEGIN:VCARD'));
      expect(vcard, contains('FN:MC Flow'));
      expect(vcard, contains('EMAIL:artist@uzme.app'));
      expect(vcard, contains('TEL:+33698765432'));
      expect(vcard, contains('ADR:;;Nice;;;;'));
      expect(vcard, contains('ORG:UZME'));
      expect(vcard, contains('URL:https://uzme.app/u/uid123'));
      expect(vcard, contains('END:VCARD'));
    });

    test('uses stageName over displayName', () {
      const user = AppUser(
        uid: 'uid456',
        email: 'test@test.com',
        displayName: 'Real Name',
        stageName: 'Stage Name',
        role: BaseUserRole.client,
      );

      final vcard = service.fromUser(user);
      expect(vcard, contains('FN:Stage Name'));
    });

    test('omits optional fields when null', () {
      const user = AppUser(
        uid: 'uid789',
        email: 'test@test.com',
        role: BaseUserRole.client,
      );

      final vcard = service.fromUser(user);
      expect(vcard, isNot(contains('TEL:')));
      expect(vcard, isNot(contains('ADR:')));
    });
  });
}
