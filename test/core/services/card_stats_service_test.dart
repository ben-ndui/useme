import 'package:flutter_test/flutter_test.dart';
import 'package:useme/core/services/card_stats_service.dart';

void main() {
  group('CardStats', () {
    test('default has zero counts', () {
      const stats = CardStats();
      expect(stats.scanCount, 0);
      expect(stats.viewCount, 0);
      expect(stats.lastScannedAt, isNull);
      expect(stats.lastViewedAt, isNull);
    });

    test('fromMap parses counts correctly', () {
      final stats = CardStats.fromMap({
        'scanCount': 42,
        'viewCount': 128,
      });
      expect(stats.scanCount, 42);
      expect(stats.viewCount, 128);
    });

    test('fromMap handles null map', () {
      final stats = CardStats.fromMap(null);
      expect(stats.scanCount, 0);
      expect(stats.viewCount, 0);
    });

    test('fromMap handles missing fields', () {
      final stats = CardStats.fromMap({'scanCount': 5});
      expect(stats.scanCount, 5);
      expect(stats.viewCount, 0);
    });

    test('fromMap parses ISO string dates', () {
      final stats = CardStats.fromMap({
        'lastScannedAt': '2026-03-31T12:00:00.000',
        'lastViewedAt': '2026-03-30T08:00:00.000',
      });
      expect(stats.lastScannedAt, isNotNull);
      expect(stats.lastScannedAt!.day, 31);
      expect(stats.lastViewedAt!.day, 30);
    });
  });
}
