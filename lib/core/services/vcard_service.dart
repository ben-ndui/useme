import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/user_contact.dart';
import 'package:useme/core/utils/app_logger.dart';

/// Generates and shares vCard 3.0 (.vcf) files.
class VCardService {
  /// Generate a vCard string from a [UserContact].
  String fromContact(UserContact contact) {
    final buf = StringBuffer()
      ..writeln('BEGIN:VCARD')
      ..writeln('VERSION:3.0')
      ..writeln('FN:${_escape(contact.contactName)}')
      ..writeln('N:${_escape(contact.contactName)};;;;');

    if (contact.contactEmail != null) {
      buf.writeln('EMAIL:${contact.contactEmail}');
    }
    if (contact.contactPhone != null) {
      buf.writeln('TEL:${contact.contactPhone}');
    }
    if (contact.contactPhotoUrl != null) {
      buf.writeln('PHOTO;VALUE=uri:${contact.contactPhotoUrl}');
    }

    buf
      ..writeln('NOTE:UZME Contact - ${contact.category.label}')
      ..writeln('URL:https://uzme.app/u/${contact.contactUserId ?? ''}')
      ..writeln('END:VCARD');

    return buf.toString();
  }

  /// Generate a vCard string from an [AppUser].
  String fromUser(AppUser user) {
    final displayName = user.stageName ?? user.displayName ?? user.name ?? '';
    final buf = StringBuffer()
      ..writeln('BEGIN:VCARD')
      ..writeln('VERSION:3.0')
      ..writeln('FN:${_escape(displayName)}')
      ..writeln('N:${_escape(displayName)};;;;');

    buf.writeln('EMAIL:${user.email}');

    if (user.phoneNumber != null) {
      buf.writeln('TEL:${user.phoneNumber}');
    }
    if (user.displayPhotoUrl != null) {
      buf.writeln('PHOTO;VALUE=uri:${user.displayPhotoUrl}');
    }
    if (user.city != null) {
      buf.writeln('ADR:;;${_escape(user.city!)};;;;');
    }

    buf
      ..writeln('ORG:UZME')
      ..writeln('URL:https://uzme.app/u/${user.uid}')
      ..writeln('END:VCARD');

    return buf.toString();
  }

  /// Save vCard to temp file and share via native sheet.
  Future<void> share(String vcardString, {required String name}) async {
    try {
      final dir = await getTemporaryDirectory();
      final safeName = name.replaceAll(RegExp(r'[^\w]'), '_');
      final file = File('${dir.path}/$safeName.vcf');
      await file.writeAsString(vcardString);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/vcard')],
        ),
      );
    } catch (e) {
      appLog('VCardService.share error: $e');
    }
  }

  String _escape(String value) =>
      value.replaceAll(r'\', r'\\').replaceAll(',', r'\,');
}
