import 'package:flutter_test/flutter_test.dart';
import 'package:uzme/core/models/studio_service.dart';

void main() {
  final now = DateTime(2026, 3, 9);

  final testService = StudioService(
    id: 'svc-1',
    studioId: 'studio-1',
    name: 'Recording',
    description: 'Full recording session',
    hourlyRate: 50.0,
    minDurationHours: 2,
    maxDurationHours: 8,
    roomIds: ['room-1', 'room-2'],
    isActive: true,
    createdAt: now,
  );

  group('calculatePrice', () {
    test('calculates price for 60 minutes', () {
      expect(testService.calculatePrice(60), 50.0);
    });

    test('calculates price for 120 minutes', () {
      expect(testService.calculatePrice(120), 100.0);
    });

    test('calculates price for 30 minutes', () {
      expect(testService.calculatePrice(30), 25.0);
    });

    test('calculates price for 0 minutes', () {
      expect(testService.calculatePrice(0), 0.0);
    });
  });

  group('getFormattedPrice', () {
    test('formats whole number', () {
      expect(testService.getFormattedPrice(), '50 \u20AC/h');
    });

    test('formats with decimal truncated', () {
      final svc = testService.copyWith(hourlyRate: 45.99);
      expect(svc.getFormattedPrice(), '46 \u20AC/h');
    });
  });

  group('getDurationRange', () {
    test('shows range when max is set', () {
      expect(testService.getDurationRange(), '2-8h');
    });

    test('shows min only when no max', () {
      testService.copyWith(maxDurationHours: null);
      // copyWith won't clear nullable, create manually
      final noMax = StudioService(
        id: 'svc-1',
        studioId: 'studio-1',
        name: 'Recording',
        hourlyRate: 50,
        minDurationHours: 2,
        createdAt: now,
      );
      expect(noMax.getDurationRange(), 'Min 2h');
    });
  });

  group('fromMap / toMap round-trip', () {
    test('preserves all fields', () {
      final map = testService.toMap();
      final restored = StudioService.fromMap(map);

      expect(restored.id, 'svc-1');
      expect(restored.studioId, 'studio-1');
      expect(restored.name, 'Recording');
      expect(restored.description, 'Full recording session');
      expect(restored.hourlyRate, 50.0);
      expect(restored.minDurationHours, 2);
      expect(restored.maxDurationHours, 8);
      expect(restored.roomIds, ['room-1', 'room-2']);
      expect(restored.isActive, isTrue);
    });
  });

  group('fromMap backward compatibility', () {
    test('reads price field as hourlyRate', () {
      final svc = StudioService.fromMap({
        'id': 'svc-2',
        'studioId': 'studio-1',
        'name': 'Mixing',
        'price': 75.0,
        'createdAt': now.millisecondsSinceEpoch,
      });
      expect(svc.hourlyRate, 75.0);
    });

    test('reads duration in minutes as minDurationHours', () {
      final svc = StudioService.fromMap({
        'id': 'svc-3',
        'studioId': 'studio-1',
        'name': 'Mastering',
        'duration': 180, // 3 hours in minutes
        'createdAt': now.millisecondsSinceEpoch,
      });
      expect(svc.minDurationHours, 3);
    });

    test('handles missing fields with defaults', () {
      final svc = StudioService.fromMap({});
      expect(svc.id, '');
      expect(svc.name, '');
      expect(svc.hourlyRate, 0.0);
      expect(svc.minDurationHours, 1);
      expect(svc.isActive, isTrue);
      expect(svc.roomIds, isEmpty);
    });
  });

  group('copyWith', () {
    test('creates modified copy', () {
      final modified = testService.copyWith(
        name: 'Mixing',
        hourlyRate: 75.0,
        isActive: false,
      );
      expect(modified.name, 'Mixing');
      expect(modified.hourlyRate, 75.0);
      expect(modified.isActive, isFalse);
      expect(modified.id, 'svc-1'); // unchanged
      expect(modified.studioId, 'studio-1'); // unchanged
    });
  });
}
