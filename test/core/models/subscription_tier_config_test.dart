import 'package:flutter_test/flutter_test.dart';
import 'package:uzme/core/models/subscription_tier_config.dart';

void main() {
  group('isUnlimited', () {
    test('returns true for -1', () {
      const tier = SubscriptionTierConfig(id: 't', name: 'T');
      expect(tier.isUnlimited(-1), isTrue);
    });

    test('returns false for positive values', () {
      const tier = SubscriptionTierConfig(id: 't', name: 'T');
      expect(tier.isUnlimited(10), isFalse);
      expect(tier.isUnlimited(0), isFalse);
    });
  });

  group('isFree', () {
    test('returns true when both prices are 0', () {
      expect(SubscriptionTierConfig.defaultFree.isFree, isTrue);
    });

    test('returns false when monthly > 0', () {
      expect(SubscriptionTierConfig.defaultPro.isFree, isFalse);
    });
  });

  group('yearlyDiscount', () {
    test('returns 0 for free tier', () {
      expect(SubscriptionTierConfig.defaultFree.yearlyDiscount, 0);
    });

    test('calculates correct discount for Pro', () {
      final pro = SubscriptionTierConfig.defaultPro;
      // 19 * 12 = 228 - 190 = 38
      expect(pro.yearlyDiscount, 38);
    });

    test('calculates correct discount for Enterprise', () {
      final enterprise = SubscriptionTierConfig.defaultEnterprise;
      // 79 * 12 = 948 - 790 = 158
      expect(enterprise.yearlyDiscount, 158);
    });
  });

  group('freeMonthsWithYearly', () {
    test('returns 0 for free tier', () {
      expect(SubscriptionTierConfig.defaultFree.freeMonthsWithYearly, 0);
    });

    test('calculates free months for Pro', () {
      final pro = SubscriptionTierConfig.defaultPro;
      // discount=38, monthly=19 => 38/19 = 2 months
      expect(pro.freeMonthsWithYearly, 2);
    });

    test('calculates free months for Enterprise', () {
      final enterprise = SubscriptionTierConfig.defaultEnterprise;
      // discount=158, monthly=79 => 158/79 = 2 months
      expect(enterprise.freeMonthsWithYearly, 2);
    });
  });

  group('defaultTiers', () {
    test('contains 3 tiers', () {
      expect(SubscriptionTierConfig.defaultTiers.length, 3);
    });

    test('ordered free -> pro -> enterprise', () {
      final tiers = SubscriptionTierConfig.defaultTiers;
      expect(tiers[0].id, 'free');
      expect(tiers[1].id, 'pro');
      expect(tiers[2].id, 'enterprise');
    });

    test('sortOrder is ascending', () {
      final tiers = SubscriptionTierConfig.defaultTiers;
      expect(tiers[0].sortOrder, 0);
      expect(tiers[1].sortOrder, 1);
      expect(tiers[2].sortOrder, 2);
    });
  });

  group('defaultFree', () {
    test('has correct limits', () {
      final free = SubscriptionTierConfig.defaultFree;
      expect(free.maxSessions, 20);
      expect(free.maxRooms, 3);
      expect(free.maxServices, 5);
      expect(free.maxEngineers, 3);
    });

    test('has no premium features', () {
      final free = SubscriptionTierConfig.defaultFree;
      expect(free.hasDiscoveryVisibility, isFalse);
      expect(free.hasAnalytics, isFalse);
      expect(free.hasAdvancedAnalytics, isFalse);
      expect(free.hasMultiStudios, isFalse);
      expect(free.hasVerifiedBadge, isFalse);
    });

    test('has basic AI', () {
      final free = SubscriptionTierConfig.defaultFree;
      expect(free.hasAIAssistant, isTrue);
      expect(free.hasAdvancedAI, isFalse);
      expect(free.aiMessagesPerMonth, 50);
    });
  });

  group('defaultPro', () {
    test('has unlimited sessions and services', () {
      final pro = SubscriptionTierConfig.defaultPro;
      expect(pro.isUnlimited(pro.maxSessions), isTrue);
      expect(pro.isUnlimited(pro.maxServices), isTrue);
      expect(pro.isUnlimited(pro.maxRooms), isFalse); // 10
    });

    test('has discovery and verified badge', () {
      final pro = SubscriptionTierConfig.defaultPro;
      expect(pro.hasDiscoveryVisibility, isTrue);
      expect(pro.hasVerifiedBadge, isTrue);
      expect(pro.hasAnalytics, isTrue);
    });
  });

  group('defaultEnterprise', () {
    test('has all unlimited', () {
      final e = SubscriptionTierConfig.defaultEnterprise;
      expect(e.isUnlimited(e.maxSessions), isTrue);
      expect(e.isUnlimited(e.maxRooms), isTrue);
      expect(e.isUnlimited(e.maxServices), isTrue);
      expect(e.isUnlimited(e.maxEngineers), isTrue);
      expect(e.isUnlimited(e.aiMessagesPerMonth), isTrue);
    });

    test('has all features', () {
      final e = SubscriptionTierConfig.defaultEnterprise;
      expect(e.hasDiscoveryVisibility, isTrue);
      expect(e.hasAnalytics, isTrue);
      expect(e.hasAdvancedAnalytics, isTrue);
      expect(e.hasMultiStudios, isTrue);
      expect(e.hasApiAccess, isTrue);
      expect(e.hasPrioritySupport, isTrue);
      expect(e.hasVerifiedBadge, isTrue);
      expect(e.hasAIAssistant, isTrue);
      expect(e.hasAdvancedAI, isTrue);
    });
  });

  group('copyWith', () {
    test('modifies specified fields', () {
      final free = SubscriptionTierConfig.defaultFree;
      final modified = free.copyWith(
        name: 'Starter',
        maxSessions: 50,
        hasAnalytics: true,
      );
      expect(modified.name, 'Starter');
      expect(modified.maxSessions, 50);
      expect(modified.hasAnalytics, isTrue);
      expect(modified.id, 'free'); // unchanged
      expect(modified.maxRooms, 3); // unchanged
    });
  });

  group('equality', () {
    test('same config is equal', () {
      final a = SubscriptionTierConfig.defaultFree;
      final b = SubscriptionTierConfig.defaultFree;
      expect(a, equals(b));
    });

    test('different config is not equal', () {
      expect(
        SubscriptionTierConfig.defaultFree,
        isNot(equals(SubscriptionTierConfig.defaultPro)),
      );
    });
  });
}
