import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:uzme/core/utils/app_logger.dart';

/// Service for writing UZME profile URLs to NFC tags.
class NfcShareService {
  /// Check if NFC is available on this device.
  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      final availability = await NfcManager.instance.checkAvailability();
      return availability == NfcAvailability.enabled;
    } catch (e) {
      appLog('NfcShareService.isAvailable error: $e');
      return false;
    }
  }

  /// Start an NFC session to write the user's profile URL to a tag.
  Future<void> writeProfileUrl({
    required String userId,
    required void Function() onSuccess,
    required void Function(String message) onError,
  }) async {
    try {
      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443},
        alertMessageIos: 'Approche un tag NFC',
        onDiscovered: (NfcTag tag) async {
          try {
            final message = _buildUriMessage(userId);

            if (Platform.isAndroid) {
              final ndef = NdefAndroid.from(tag);
              if (ndef == null || !ndef.isWritable) {
                throw Exception('Tag non compatible NDEF');
              }
              await ndef.writeNdefMessage(message);
            } else if (Platform.isIOS) {
              final ndef = NdefIos.from(tag);
              if (ndef == null) {
                throw Exception('Tag non compatible NDEF');
              }
              await ndef.writeNdef(message);
            }

            await NfcManager.instance.stopSession(
              alertMessageIos: 'Profil UZME ecrit !',
            );
            onSuccess();
          } catch (e) {
            await NfcManager.instance.stopSession(
              errorMessageIos: e.toString(),
            );
            onError(e.toString());
          }
        },
      );
    } catch (e) {
      appLog('NfcShareService.writeProfileUrl error: $e');
      onError(e.toString());
    }
  }

  /// Build an NDEF message with a URI record pointing to the user's profile.
  NdefMessage _buildUriMessage(String userId) {
    // NFC Forum URI RTD: prefix 0x04 = "https://"
    final uriBody = 'uzme.app/u/$userId';
    final payload = Uint8List.fromList([0x04, ...uriBody.codeUnits]);

    return NdefMessage(
      records: [
        NdefRecord(
          typeNameFormat: TypeNameFormat.wellKnown,
          type: Uint8List.fromList([0x55]), // 'U' = URI record type
          identifier: Uint8List(0),
          payload: payload,
        ),
      ],
    );
  }

  /// Stop any active NFC session.
  void stopSession() {
    try {
      NfcManager.instance.stopSession();
    } catch (_) {}
  }
}
