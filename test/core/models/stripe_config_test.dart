import 'package:flutter_test/flutter_test.dart';
import 'package:uzme/core/models/stripe_config.dart';

void main() {
  const fullConfig = StripeConfig(
    publishableKey: 'pk_live_abc123',
    encryptedSecretKey: 'encrypted_sk',
    encryptedWebhookSecret: 'encrypted_wh',
    isLiveMode: true,
    priceIds: {
      'pro_monthly': 'price_pro_m',
      'pro_yearly': 'price_pro_y',
      'enterprise_monthly': 'price_ent_m',
      'enterprise_yearly': 'price_ent_y',
    },
    updatedBy: 'admin-1',
  );

  group('isConfigured', () {
    test('true when keys present', () {
      expect(fullConfig.isConfigured, isTrue);
    });

    test('false when publishableKey empty', () {
      expect(
        fullConfig.copyWith(publishableKey: '').isConfigured,
        isFalse,
      );
    });

    test('false when secretKey empty', () {
      expect(
        fullConfig.copyWith(encryptedSecretKey: '').isConfigured,
        isFalse,
      );
    });

    test('false by default', () {
      expect(const StripeConfig().isConfigured, isFalse);
    });
  });

  group('hasWebhook', () {
    test('true when webhook secret present', () {
      expect(fullConfig.hasWebhook, isTrue);
    });

    test('false when empty', () {
      expect(const StripeConfig().hasWebhook, isFalse);
    });
  });

  group('hasAllPrices', () {
    test('true when all 4 prices present', () {
      expect(fullConfig.hasAllPrices, isTrue);
    });

    test('false when missing a price', () {
      final partial = fullConfig.copyWith(priceIds: {
        'pro_monthly': 'price_1',
        'pro_yearly': 'price_2',
      });
      expect(partial.hasAllPrices, isFalse);
    });

    test('false by default', () {
      expect(const StripeConfig().hasAllPrices, isFalse);
    });
  });

  group('getPriceId', () {
    test('returns monthly price', () {
      expect(fullConfig.getPriceId('pro'), 'price_pro_m');
    });

    test('returns yearly price', () {
      expect(fullConfig.getPriceId('pro', yearly: true), 'price_pro_y');
    });

    test('returns null for unknown tier', () {
      expect(fullConfig.getPriceId('unknown'), isNull);
    });
  });

  group('key type checks', () {
    test('isTestKey', () {
      const config = StripeConfig(publishableKey: 'pk_test_xyz');
      expect(config.isTestKey, isTrue);
      expect(config.isLiveKey, isFalse);
    });

    test('isLiveKey', () {
      expect(fullConfig.isLiveKey, isTrue);
      expect(fullConfig.isTestKey, isFalse);
    });

    test('neither when empty', () {
      const config = StripeConfig();
      expect(config.isTestKey, isFalse);
      expect(config.isLiveKey, isFalse);
    });
  });

  group('isKeyModeConsistent', () {
    test('true when live mode with live key', () {
      expect(fullConfig.isKeyModeConsistent, isTrue);
    });

    test('true when test mode with test key', () {
      const config = StripeConfig(
        publishableKey: 'pk_test_xyz',
        isLiveMode: false,
      );
      expect(config.isKeyModeConsistent, isTrue);
    });

    test('false when live mode with test key', () {
      const config = StripeConfig(
        publishableKey: 'pk_test_xyz',
        isLiveMode: true,
      );
      expect(config.isKeyModeConsistent, isFalse);
    });

    test('false when test mode with live key', () {
      const config = StripeConfig(
        publishableKey: 'pk_live_xyz',
        isLiveMode: false,
      );
      expect(config.isKeyModeConsistent, isFalse);
    });

    test('true when key is empty (not yet configured)', () {
      expect(const StripeConfig().isKeyModeConsistent, isTrue);
    });
  });

  group('fromMap', () {
    test('parses all fields', () {
      final config = StripeConfig.fromMap({
        'publishableKey': 'pk_test_abc',
        'encryptedSecretKey': 'enc_sk',
        'encryptedWebhookSecret': 'enc_wh',
        'isLiveMode': false,
        'priceIds': {'pro_monthly': 'price_1'},
        'updatedBy': 'admin',
      });

      expect(config.publishableKey, 'pk_test_abc');
      expect(config.encryptedSecretKey, 'enc_sk');
      expect(config.encryptedWebhookSecret, 'enc_wh');
      expect(config.isLiveMode, isFalse);
      expect(config.priceIds['pro_monthly'], 'price_1');
      expect(config.updatedBy, 'admin');
    });

    test('returns empty config for null map', () {
      final config = StripeConfig.fromMap(null);
      expect(config.publishableKey, '');
      expect(config.isConfigured, isFalse);
    });

    test('handles missing fields', () {
      final config = StripeConfig.fromMap({});
      expect(config.publishableKey, '');
      expect(config.encryptedSecretKey, '');
      expect(config.isLiveMode, isFalse);
      expect(config.priceIds, isEmpty);
    });
  });

  group('copyWith', () {
    test('modifies specified fields', () {
      final modified = fullConfig.copyWith(
        isLiveMode: false,
        publishableKey: 'pk_test_new',
      );
      expect(modified.isLiveMode, isFalse);
      expect(modified.publishableKey, 'pk_test_new');
      expect(modified.encryptedSecretKey, 'encrypted_sk'); // unchanged
      expect(modified.priceIds.length, 4); // unchanged
    });
  });

  group('defaults', () {
    test('default values', () {
      const config = StripeConfig();
      expect(config.publishableKey, '');
      expect(config.encryptedSecretKey, '');
      expect(config.encryptedWebhookSecret, '');
      expect(config.isLiveMode, isFalse);
      expect(config.priceIds, isEmpty);
      expect(config.updatedAt, isNull);
      expect(config.updatedBy, isNull);
    });
  });
}
