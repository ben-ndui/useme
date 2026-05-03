import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uzme/core/models/user_contact.dart';
import 'package:uzme/core/services/network_service.dart';
import 'package:uzme/l10n/app_localizations.dart';

/// Helper for launching invite actions (email/SMS) for contacts.
class ContactInviteHelper {
  static Future<void> launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  static Future<void> launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  static Future<void> sendEmailInvite(
    BuildContext context,
    UserContact contact,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri(
      scheme: 'mailto',
      path: contact.contactEmail,
      queryParameters: {
        'subject': l10n.networkInviteEmailSubject,
        'body': l10n.networkInviteEmailBody,
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      if (context.mounted) {
        _trackInvitation(context, contact, 'email',
            email: contact.contactEmail);
      }
    }
  }

  static Future<void> sendSmsInvite(
    BuildContext context,
    UserContact contact,
  ) async {
    final storeLink = Platform.isIOS
        ? 'https://apps.apple.com/app/uzme/id6745136498'
        : 'https://play.google.com/store/apps/details?id=com.smoothandesign.useme';
    final body = 'Rejoins-moi sur UZME ! $storeLink';

    final uri = Uri(
      scheme: 'sms',
      path: contact.contactPhone,
      queryParameters: {'body': body},
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      if (context.mounted) {
        _trackInvitation(context, contact, 'sms',
            phone: contact.contactPhone);
      }
    }
  }

  static Future<void> _trackInvitation(
    BuildContext context,
    UserContact contact,
    String method, {
    String? email,
    String? phone,
  }) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      await NetworkService().trackInvitation(
        senderId: authState.user.uid,
        contactId: contact.id,
        method: method,
        email: email,
        phone: phone,
      );
    }
  }
}
