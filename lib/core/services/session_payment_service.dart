import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:useme/core/models/session_payment_intent.dart';

/// Base URL for the Cloud Functions API.
const _apiBaseUrl =
    'https://us-central1-smoothandesign.cloudfunctions.net/api';

/// Service handling Stripe session payments and Connect onboarding.
class SessionPaymentService {
  final http.Client _client;

  SessionPaymentService({http.Client? client})
      : _client = client ?? http.Client();

  // ------------------------------------------------------------------ //
  //  Session payment
  // ------------------------------------------------------------------ //

  /// Creates a PaymentIntent on the backend and returns the data
  /// needed to present the Stripe PaymentSheet.
  Future<SessionPaymentIntent> createPaymentIntent({
    required String userId,
    required String sessionId,
    required int amountCents,
    required String studioId,
    required bool isDeposit,
    String currency = 'eur',
  }) async {
    final response = await _post('/api/stripe/useme/session-payment', {
      'userId': userId,
      'sessionId': sessionId,
      'amount': amountCents,
      'currency': currency,
      'studioId': studioId,
      'isDeposit': isDeposit,
    });

    return SessionPaymentIntent.fromMap(
      response,
      sessionId: sessionId,
      amountCents: amountCents,
      isDeposit: isDeposit,
    );
  }

  /// Initialises and presents the Stripe PaymentSheet.
  /// Returns `true` on success, throws on failure/cancellation.
  Future<bool> presentPaymentSheet(SessionPaymentIntent intent) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'PaymentSheet is not supported on web. Use checkout URL instead.',
      );
    }

    if (intent.publishableKey != null) {
      Stripe.publishableKey = intent.publishableKey!;
      await Stripe.instance.applySettings();
    }

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: intent.clientSecret,
        customerEphemeralKeySecret: intent.ephemeralKey,
        customerId: intent.customerId,
        merchantDisplayName: 'UZME',
        googlePay: PaymentSheetGooglePay(
          merchantCountryCode: 'FR',
          testEnv: !kReleaseMode,
        ),
        style: ThemeMode.system,
      ),
    );

    await Stripe.instance.presentPaymentSheet();
    return true;
  }

  // ------------------------------------------------------------------ //
  //  Payment confirmation (updates session status server-side)
  // ------------------------------------------------------------------ //

  /// Confirms a successful payment by updating the session status
  /// via the backend. The backend verifies the PaymentIntent with Stripe.
  Future<void> confirmPayment({
    required String sessionId,
    required String paymentIntentId,
    required bool isDeposit,
  }) async {
    await _post('/api/stripe/useme/confirm-payment', {
      'sessionId': sessionId,
      'paymentIntentId': paymentIntentId,
      'isDeposit': isDeposit,
    });
  }

  /// Requests a refund for a cancelled session.
  /// The backend calculates the refund based on cancellation policy.
  Future<Map<String, dynamic>> requestRefund({
    required String sessionId,
    required String userId,
    required String reason,
    String? customReason,
    required bool isCancelledByStudio,
  }) async {
    return _post('/api/stripe/useme/refund-session', {
      'sessionId': sessionId,
      'userId': userId,
      'reason': reason,
      'customReason': customReason,
      'isCancelledByStudio': isCancelledByStudio,
    });
  }

  // ------------------------------------------------------------------ //
  //  Stripe Connect onboarding
  // ------------------------------------------------------------------ //

  /// Creates a Stripe Connect Express account (if needed) and returns
  /// the onboarding URL that the studio owner must visit.
  Future<String> createConnectOnboardingUrl({
    required String userId,
    String? returnUrl,
    String? refreshUrl,
  }) async {
    debugPrint('[StripeConnect] connect-onboard userId=$userId');
    final response = await _post('/api/stripe/useme/connect-onboard', {
      'userId': userId,
      'returnUrl': returnUrl ?? 'https://uzme.app/connect/return',
      'refreshUrl': refreshUrl ?? 'https://uzme.app/connect/refresh',
    });
    return response['url'] as String;
  }

  /// Opens the onboarding URL in an external browser.
  Future<void> launchOnboarding({required String userId}) async {
    debugPrint('[StripeConnect] launchOnboarding userId=$userId');
    final url = await createConnectOnboardingUrl(userId: userId);
    debugPrint('[StripeConnect] onboarding URL: $url');
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  /// Returns the current Stripe Connect status for a studio.
  Future<ConnectStatus> getConnectStatus({required String userId}) async {
    debugPrint('[StripeConnect] connect-status userId=$userId');
    final response = await _post('/api/stripe/useme/connect-status', {
      'userId': userId,
    });
    return ConnectStatus.fromMap(response);
  }

  // ------------------------------------------------------------------ //
  //  HTTP helper
  // ------------------------------------------------------------------ //

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_apiBaseUrl$path');

    // Get Firebase Auth token for authenticated requests
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final response = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    debugPrint('[StripeService] ${response.statusCode} ${response.body.length > 300 ? response.body.substring(0, 300) : response.body}');

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      final msg = error['error'] ?? 'Erreur serveur (${response.statusCode})';
      debugPrint('[StripeService] ERROR: $msg');
      throw Exception(msg);
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

/// Stripe Connect account status for a studio.
class ConnectStatus {
  final bool connected;
  final String? accountId;
  final bool chargesEnabled;
  final bool payoutsEnabled;
  final bool detailsSubmitted;

  const ConnectStatus({
    required this.connected,
    this.accountId,
    this.chargesEnabled = false,
    this.payoutsEnabled = false,
    this.detailsSubmitted = false,
  });

  factory ConnectStatus.fromMap(Map<String, dynamic> map) {
    return ConnectStatus(
      connected: map['connected'] as bool? ?? false,
      accountId: map['accountId'] as String?,
      chargesEnabled: map['chargesEnabled'] as bool? ?? false,
      payoutsEnabled: map['payoutsEnabled'] as bool? ?? false,
      detailsSubmitted: map['detailsSubmitted'] as bool? ?? false,
    );
  }

  /// Account is fully active when charges and payouts are enabled.
  /// In test mode, detailsSubmitted is sufficient.
  bool get isFullyActive =>
      (chargesEnabled && payoutsEnabled) || detailsSubmitted;
}
