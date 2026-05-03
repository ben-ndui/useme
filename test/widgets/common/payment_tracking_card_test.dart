import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uzme/core/models/session.dart';
import 'package:uzme/widgets/common/payment_tracking_card.dart';

import '../../helpers/test_factories.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  Session makeSession({
    PaymentStatus paymentStatus = PaymentStatus.depositPending,
    double? totalAmount = 200,
    double? depositAmount = 60,
    String? paymentMethodLabel = 'Virement',
    DateTime? depositPaidAt,
    DateTime? fullyPaidAt,
  }) {
    final start = DateTime(2026, 5, 1, 10, 0);
    return SessionFactory.create(
      scheduledStart: start,
      scheduledEnd: start.add(const Duration(hours: 2)),
      status: SessionStatus.confirmed,
    ).copyWith(
      paymentStatus: paymentStatus,
      totalAmount: totalAmount,
      depositAmount: depositAmount,
      paymentMethodLabel: paymentMethodLabel,
      depositPaidAt: depositPaidAt,
      fullyPaidAt: fullyPaidAt,
    );
  }

  Widget buildCard({
    required Session session,
    bool canManage = false,
    VoidCallback? onMarkDepositReceived,
    VoidCallback? onMarkFullyPaid,
  }) {
    return buildTestApp(
      child: Scaffold(
        body: SingleChildScrollView(
          child: PaymentTrackingCard(
            session: session,
            canManage: canManage,
            onMarkDepositReceived: onMarkDepositReceived,
            onMarkFullyPaid: onMarkFullyPaid,
          ),
        ),
      ),
    );
  }

  group('PaymentTrackingCard', () {
    testWidgets('hidden when no payment tracking', (tester) async {
      final session = makeSession(paymentStatus: PaymentStatus.none);
      await tester.pumpWidget(buildCard(session: session));
      await tester.pumpAndSettle();

      expect(find.text('Payment tracking'), findsNothing);
    });

    testWidgets('shows header and status badge for depositPending',
        (tester) async {
      final session = makeSession();
      await tester.pumpWidget(buildCard(session: session));
      await tester.pumpAndSettle();

      expect(find.text('Payment tracking'), findsOneWidget);
      expect(find.text('Deposit pending'), findsWidgets);
    });

    testWidgets('shows total amount', (tester) async {
      final session = makeSession(totalAmount: 200);
      await tester.pumpWidget(buildCard(session: session));
      await tester.pumpAndSettle();

      expect(find.textContaining('200'), findsWidgets);
    });

    testWidgets('shows deposit amount', (tester) async {
      final session = makeSession(depositAmount: 60);
      await tester.pumpWidget(buildCard(session: session));
      await tester.pumpAndSettle();

      expect(find.textContaining('60'), findsWidgets);
    });

    testWidgets('shows payment method', (tester) async {
      final session = makeSession(paymentMethodLabel: 'Virement');
      await tester.pumpWidget(buildCard(session: session));
      await tester.pumpAndSettle();

      expect(find.text('Virement'), findsOneWidget);
    });

    testWidgets('shows remaining amount when deposit paid', (tester) async {
      final session = makeSession(
        paymentStatus: PaymentStatus.depositPaid,
        totalAmount: 200,
        depositAmount: 60,
        depositPaidAt: DateTime(2026, 5, 2),
      );
      await tester.pumpWidget(buildCard(session: session));
      await tester.pumpAndSettle();

      // Remaining = 200 - 60 = 140
      expect(find.textContaining('140'), findsWidgets);
    });

    testWidgets('shows "Mark deposit received" button when canManage and depositPending',
        (tester) async {
      final session = makeSession(paymentStatus: PaymentStatus.depositPending);
      await tester.pumpWidget(buildCard(
        session: session,
        canManage: true,
        onMarkDepositReceived: () {},
      ));
      await tester.pumpAndSettle();

      expect(find.text('Mark deposit received'), findsOneWidget);
    });

    testWidgets('shows "Mark fully paid" button when canManage and depositPaid',
        (tester) async {
      final session = makeSession(
        paymentStatus: PaymentStatus.depositPaid,
        depositPaidAt: DateTime(2026, 5, 2),
      );
      await tester.pumpWidget(buildCard(
        session: session,
        canManage: true,
        onMarkFullyPaid: () {},
      ));
      await tester.pumpAndSettle();

      expect(find.text('Mark fully paid'), findsOneWidget);
    });

    testWidgets('hides action buttons when canManage is false',
        (tester) async {
      final session = makeSession(paymentStatus: PaymentStatus.depositPending);
      await tester.pumpWidget(buildCard(session: session, canManage: false));
      await tester.pumpAndSettle();

      expect(find.text('Mark deposit received'), findsNothing);
      expect(find.text('Mark fully paid'), findsNothing);
    });

    testWidgets('hides action buttons when fully paid', (tester) async {
      final session = makeSession(
        paymentStatus: PaymentStatus.fullyPaid,
        depositPaidAt: DateTime(2026, 5, 2),
        fullyPaidAt: DateTime(2026, 5, 5),
      );
      await tester.pumpWidget(buildCard(
        session: session,
        canManage: true,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Mark deposit received'), findsNothing);
      expect(find.text('Mark fully paid'), findsNothing);
    });

    testWidgets('calls onMarkDepositReceived when button tapped',
        (tester) async {
      var called = false;
      final session = makeSession(paymentStatus: PaymentStatus.depositPending);
      await tester.pumpWidget(buildCard(
        session: session,
        canManage: true,
        onMarkDepositReceived: () => called = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mark deposit received'));
      expect(called, isTrue);
    });

    testWidgets('calls onMarkFullyPaid when button tapped', (tester) async {
      var called = false;
      final session = makeSession(
        paymentStatus: PaymentStatus.depositPaid,
        depositPaidAt: DateTime(2026, 5, 2),
      );
      await tester.pumpWidget(buildCard(
        session: session,
        canManage: true,
        onMarkFullyPaid: () => called = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mark fully paid'));
      expect(called, isTrue);
    });

    testWidgets('shows fullyPaid badge in green', (tester) async {
      final session = makeSession(
        paymentStatus: PaymentStatus.fullyPaid,
        depositPaidAt: DateTime(2026, 5, 2),
        fullyPaidAt: DateTime(2026, 5, 5),
      );
      await tester.pumpWidget(buildCard(session: session));
      await tester.pumpAndSettle();

      expect(find.text('Fully paid'), findsWidgets);
    });
  });
}
