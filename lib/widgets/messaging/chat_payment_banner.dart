import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:uzme/core/models/models_exports.dart';
import 'package:uzme/l10n/app_localizations.dart';

/// Banner shown at the top of a chat when sessions between the two
/// participants have pending in-app payments.
class ChatPaymentBanner extends StatelessWidget {
  final String currentUserId;
  final List<String> participantIds;

  const ChatPaymentBanner({
    super.key,
    required this.currentUserId,
    required this.participantIds,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const SizedBox.shrink();

    // Find the other participant (the studio/pro)
    final otherIds = participantIds
        .where((id) => id != currentUserId)
        .toList();
    if (otherIds.isEmpty) return const SizedBox.shrink();

    // Query sessions where artist is participant and payment is pending
    // (arrayContains + single whereIn is supported by Firestore)
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('useme_sessions')
          .where('artistIds', arrayContains: currentUserId)
          .where('status', isEqualTo: 'confirmed')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final sessions = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return Session.fromMap(data);
        }).where((s) {
          final isStripe =
              s.paymentMethodLabel == PaymentMethodType.stripeInApp.label;
          final isForThisConversation = otherIds.contains(s.studioId);
          return isForThisConversation &&
              isStripe &&
              (s.canPayDeposit || s.canPayRemaining);
        }).toList();

        if (sessions.isEmpty) return const SizedBox.shrink();

        return _BannerContent(sessions: sessions);
      },
    );
  }
}

class _BannerContent extends StatelessWidget {
  final List<Session> sessions;

  const _BannerContent({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = sessions.first;
    final isDeposit = session.canPayDeposit;
    final amount = isDeposit
        ? session.depositAmount ?? 0
        : session.remainingAmount;
    const accent = Colors.amber;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/artist/sessions/${session.id}'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0.18),
                    accent.withValues(alpha: 0.06),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: accent.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.creditCard,
                        size: 14,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isDeposit
                          ? l10n.payDepositAmount(
                              '${amount.toStringAsFixed(2)} €')
                          : l10n.payRemainingAmount(
                              '${amount.toStringAsFixed(2)} €'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ),
                  if (sessions.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '+${sessions.length - 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  const FaIcon(
                    FontAwesomeIcons.arrowRight,
                    size: 12,
                    color: accent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
