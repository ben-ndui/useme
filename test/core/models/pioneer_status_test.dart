import 'package:flutter_test/flutter_test.dart';
import 'package:uzme/core/models/pioneer_status.dart';

void main() {
  group('PioneerStatus', () {
    test('default values are non-pioneer', () {
      const status = PioneerStatus();
      expect(status.isPioneer, false);
      expect(status.pioneerNumber, 0);
      expect(status.isFreeSubscriptionActive, false);
      expect(status.isCommissionExempt, false);
      expect(status.daysUntilBenefitsExpire, 0);
    });

    test('active pioneer with future benefits', () {
      final future = DateTime.now().add(const Duration(days: 90));
      final status = PioneerStatus(
        isPioneer: true,
        pioneerNumber: 3,
        pioneerType: 'studio',
        pioneerSince: DateTime.now(),
        freeSubscriptionUntil: future,
        commissionExemptUntil: future,
        grantedBy: 'auto',
      );

      expect(status.isPioneer, true);
      expect(status.isFreeSubscriptionActive, true);
      expect(status.isCommissionExempt, true);
      expect(status.daysUntilBenefitsExpire, greaterThan(80));
      expect(status.badgeLabel, 'Pioneer #3');
    });

    test('expired pioneer keeps badge but loses benefits', () {
      final past = DateTime.now().subtract(const Duration(days: 10));
      final status = PioneerStatus(
        isPioneer: true,
        pioneerNumber: 1,
        pioneerType: 'pro',
        pioneerSince: DateTime(2026, 1, 1),
        freeSubscriptionUntil: past,
        commissionExemptUntil: past,
      );

      expect(status.isPioneer, true);
      expect(status.isFreeSubscriptionActive, false);
      expect(status.isCommissionExempt, false);
      expect(status.daysUntilBenefitsExpire, 0);
      expect(status.badgeLabel, 'Pioneer #1');
    });

    test('fromMap creates correct instance', () {
      final map = {
        'isPioneer': true,
        'pioneerNumber': 2,
        'pioneerType': 'studio',
        'pioneerSince': '2026-03-21T10:00:00.000Z',
        'freeSubscriptionUntil': '2026-09-21T10:00:00.000Z',
        'commissionExemptUntil': '2026-09-21T10:00:00.000Z',
        'grantedBy': 'auto',
      };

      final status = PioneerStatus.fromMap(map);
      expect(status.isPioneer, true);
      expect(status.pioneerNumber, 2);
      expect(status.pioneerType, 'studio');
      expect(status.grantedBy, 'auto');
      expect(status.pioneerSince, isNotNull);
    });

    test('fromMap handles null', () {
      final status = PioneerStatus.fromMap(null);
      expect(status.isPioneer, false);
      expect(status.pioneerNumber, 0);
    });

    test('toMap serializes correctly', () {
      const status = PioneerStatus(
        isPioneer: true,
        pioneerNumber: 5,
        pioneerType: 'pro',
        grantedBy: 'admin123',
      );

      final map = status.toMap();
      expect(map['isPioneer'], true);
      expect(map['pioneerNumber'], 5);
      expect(map['pioneerType'], 'pro');
      // grantedBy is omitted from toMap (security: avoids admin UID leak)
      expect(map.containsKey('grantedBy'), false);
    });

    test('copyWith preserves unchanged values', () {
      const original = PioneerStatus(
        isPioneer: true,
        pioneerNumber: 4,
        pioneerType: 'studio',
      );

      final copy = original.copyWith(pioneerNumber: 5);
      expect(copy.isPioneer, true);
      expect(copy.pioneerNumber, 5);
      expect(copy.pioneerType, 'studio');
    });

    test('Equatable works correctly', () {
      const a = PioneerStatus(isPioneer: true, pioneerNumber: 1);
      const b = PioneerStatus(isPioneer: true, pioneerNumber: 1);
      const c = PioneerStatus(isPioneer: true, pioneerNumber: 2);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
