import 'package:flutter_test/flutter_test.dart';
import 'package:uzme/core/models/google_calendar_event.dart';

void main() {
  final start = DateTime(2026, 3, 15, 10, 0);
  final end = DateTime(2026, 3, 15, 12, 30);

  group('fromJson', () {
    test('parses all fields', () {
      final event = GoogleCalendarEvent.fromJson({
        'id': 'evt-1',
        'title': 'Recording',
        'description': 'Desc',
        'start': '2026-03-15T10:00:00.000',
        'end': '2026-03-15T12:30:00.000',
        'isAllDay': true,
      });
      expect(event.id, 'evt-1');
      expect(event.title, 'Recording');
      expect(event.description, 'Desc');
      expect(event.start, DateTime(2026, 3, 15, 10, 0));
      expect(event.end, DateTime(2026, 3, 15, 12, 30));
      expect(event.isAllDay, isTrue);
    });

    test('handles missing title', () {
      final event = GoogleCalendarEvent.fromJson({
        'id': 'evt-2',
        'start': '2026-03-15T10:00:00.000',
        'end': '2026-03-15T12:00:00.000',
      });
      expect(event.title, 'Sans titre');
    });

    test('defaults isAllDay to false', () {
      final event = GoogleCalendarEvent.fromJson({
        'id': 'evt-3',
        'start': '2026-03-15T10:00:00.000',
        'end': '2026-03-15T12:00:00.000',
      });
      expect(event.isAllDay, isFalse);
    });

    test('defaults importType to skip', () {
      final event = GoogleCalendarEvent.fromJson({
        'id': 'evt-4',
        'start': '2026-03-15T10:00:00.000',
        'end': '2026-03-15T12:00:00.000',
      });
      expect(event.importType, ImportType.skip);
    });
  });

  group('durationMinutes', () {
    test('calculates duration correctly', () {
      final event = GoogleCalendarEvent(
        id: 'e',
        title: 'T',
        start: start,
        end: end,
      );
      expect(event.durationMinutes, 150); // 2h30 = 150 min
    });

    test('all day event duration', () {
      final event = GoogleCalendarEvent(
        id: 'e',
        title: 'T',
        start: DateTime(2026, 3, 15),
        end: DateTime(2026, 3, 16),
        isAllDay: true,
      );
      expect(event.durationMinutes, 1440); // 24h
    });
  });

  group('toImportJson', () {
    test('session type includes correct fields', () {
      final event = GoogleCalendarEvent(
        id: 'evt-1',
        title: 'Recording',
        start: start,
        end: end,
        importType: ImportType.session,
        selectedArtistId: 'artist-1',
        selectedArtistName: 'DJ Test',
      );

      final json = event.toImportJson();
      expect(json['googleEventId'], 'evt-1');
      expect(json['title'], 'Recording');
      expect(json['type'], 'session');
      expect(json['artistId'], 'artist-1');
      expect(json['artistName'], 'DJ Test');
      expect(json['start'], start.toIso8601String());
      expect(json['end'], end.toIso8601String());
    });

    test('unavailability type', () {
      final event = GoogleCalendarEvent(
        id: 'evt-2',
        title: 'Vacances',
        start: start,
        end: end,
        importType: ImportType.unavailability,
      );

      final json = event.toImportJson();
      expect(json['type'], 'unavailability');
      expect(json.containsKey('artistId'), isFalse);
    });

    test('includes externalArtistName when set', () {
      final event = GoogleCalendarEvent(
        id: 'evt-3',
        title: 'Session',
        start: start,
        end: end,
        importType: ImportType.session,
        externalArtistName: 'External Artist',
      );

      final json = event.toImportJson();
      expect(json['artistName'], 'External Artist');
    });
  });

  group('copyWith', () {
    test('modifies specified fields', () {
      final event = GoogleCalendarEvent(
        id: 'evt-1',
        title: 'Original',
        start: start,
        end: end,
      );

      final modified = event.copyWith(
        importType: ImportType.session,
        selectedArtistId: 'artist-1',
      );

      expect(modified.importType, ImportType.session);
      expect(modified.selectedArtistId, 'artist-1');
      expect(modified.title, 'Original'); // unchanged
      expect(modified.id, 'evt-1'); // unchanged
    });
  });

  group('equality', () {
    test('same props are equal', () {
      final a = GoogleCalendarEvent(
        id: 'evt-1',
        title: 'T',
        start: start,
        end: end,
      );
      final b = GoogleCalendarEvent(
        id: 'evt-1',
        title: 'T',
        start: start,
        end: end,
      );
      expect(a, equals(b));
    });

    test('different importType are not equal', () {
      final a = GoogleCalendarEvent(
        id: 'evt-1',
        title: 'T',
        start: start,
        end: end,
        importType: ImportType.skip,
      );
      final b = GoogleCalendarEvent(
        id: 'evt-1',
        title: 'T',
        start: start,
        end: end,
        importType: ImportType.session,
      );
      expect(a, isNot(equals(b)));
    });
  });
}
