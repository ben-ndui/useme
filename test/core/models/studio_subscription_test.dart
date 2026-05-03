import 'package:flutter_test/flutter_test.dart';
import 'package:uzme/core/models/studio_subscription.dart';

void main() {
  group('isActive', () {
    test('free tier is always active', () {
      const sub = StudioSubscription(tierId: 'free');
      expect(sub.isActive, isTrue);
    });

    test('active when no expiry set', () {
      const sub = StudioSubscription(tierId: 'pro');
      expect(sub.isActive, isTrue);
    });

    test('active when expiry in future', () {
      final sub = StudioSubscription(
        tierId: 'pro',
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
      expect(sub.isActive, isTrue);
    });

    test('expired when expiry in past', () {
      final sub = StudioSubscription(
        tierId: 'pro',
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(sub.isActive, isFalse);
      expect(sub.isExpired, isTrue);
    });
  });

  group('tier checks', () {
    test('isFree', () {
      expect(const StudioSubscription(tierId: 'free').isFree, isTrue);
      expect(const StudioSubscription(tierId: 'pro').isFree, isFalse);
    });

    test('isPro', () {
      expect(const StudioSubscription(tierId: 'pro').isPro, isTrue);
      expect(const StudioSubscription(tierId: 'free').isPro, isFalse);
    });

    test('isEnterprise', () {
      expect(
          const StudioSubscription(tierId: 'enterprise').isEnterprise, isTrue);
      expect(const StudioSubscription(tierId: 'pro').isEnterprise, isFalse);
    });

    test('isPaid', () {
      expect(const StudioSubscription(tierId: 'pro').isPaid, isTrue);
      expect(const StudioSubscription(tierId: 'enterprise').isPaid, isTrue);
      expect(const StudioSubscription(tierId: 'free').isPaid, isFalse);
    });
  });

  group('daysUntilExpiration', () {
    test('returns -1 when no expiry', () {
      const sub = StudioSubscription(tierId: 'pro');
      expect(sub.daysUntilExpiration, -1);
    });

    test('returns 0 when expired', () {
      final sub = StudioSubscription(
        tierId: 'pro',
        expiresAt: DateTime.now().subtract(const Duration(days: 5)),
      );
      expect(sub.daysUntilExpiration, 0);
    });

    test('returns correct days when active', () {
      final sub = StudioSubscription(
        tierId: 'pro',
        expiresAt: DateTime.now().add(const Duration(days: 15)),
      );
      // Allow ±1 day tolerance for time-of-day differences
      expect(sub.daysUntilExpiration, inInclusiveRange(14, 15));
    });
  });

  group('shouldResetSessions', () {
    test('true when sessionsResetAt is null', () {
      const sub = StudioSubscription();
      expect(sub.shouldResetSessions, isTrue);
    });

    test('true when reset was last month', () {
      final lastMonth = DateTime(
        DateTime.now().year,
        DateTime.now().month - 1,
        15,
      );
      final sub = StudioSubscription(sessionsResetAt: lastMonth);
      expect(sub.shouldResetSessions, isTrue);
    });

    test('false when reset was this month', () {
      final thisMonth = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        1,
      );
      final sub = StudioSubscription(sessionsResetAt: thisMonth);
      expect(sub.shouldResetSessions, isFalse);
    });
  });

  group('incrementSessions', () {
    test('increments count', () {
      final sub = StudioSubscription(
        sessionsThisMonth: 5,
        sessionsResetAt: DateTime.now(),
      );
      final updated = sub.incrementSessions();
      expect(updated.sessionsThisMonth, 6);
    });

    test('resets before incrementing if needed', () {
      final lastMonth = DateTime(
        DateTime.now().year,
        DateTime.now().month - 1,
        15,
      );
      final sub = StudioSubscription(
        sessionsThisMonth: 10,
        sessionsResetAt: lastMonth,
      );
      final updated = sub.incrementSessions();
      expect(updated.sessionsThisMonth, 1); // reset to 0 then +1
    });
  });

  group('copyWith', () {
    test('modifies specified fields', () {
      const sub = StudioSubscription(tierId: 'free', sessionsThisMonth: 3);
      final modified = sub.copyWith(tierId: 'pro', sessionsThisMonth: 0);
      expect(modified.tierId, 'pro');
      expect(modified.sessionsThisMonth, 0);
    });
  });

  group('defaults', () {
    test('default values', () {
      const sub = StudioSubscription();
      expect(sub.tierId, 'free');
      expect(sub.sessionsThisMonth, 0);
      expect(sub.startedAt, isNull);
      expect(sub.expiresAt, isNull);
      expect(sub.stripeSubscriptionId, isNull);
    });
  });
}
