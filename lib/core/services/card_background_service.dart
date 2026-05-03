import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uzme/core/utils/app_logger.dart';
import 'package:uzme/widgets/common/permission_dialog.dart';

/// Service for picking and uploading a custom card background image.
class CardBackgroundService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage;

  CardBackgroundService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Pick an image from gallery with permission handling.
  Future<File?> pickImage(BuildContext context) async {
    if (!context.mounted) return null;
    final granted = await PermissionDialog.requestPermission(
      context,
      type: AppPermissionType.photos,
    );
    if (!granted) return null;

    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 80,
    );

    if (pickedFile == null) return null;
    return File(pickedFile.path);
  }

  /// Upload image to Firebase Storage, returns download URL.
  Future<String?> upload({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child('card_backgrounds')
          .child(userId)
          .child('bg.jpg');

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      appLog('CardBackgroundService.upload error: $e');
      return null;
    }
  }

  /// Delete the background image from Storage.
  Future<void> delete(String userId) async {
    try {
      final ref = _storage
          .ref()
          .child('card_backgrounds')
          .child(userId)
          .child('bg.jpg');
      await ref.delete();
    } catch (e) {
      appLog('CardBackgroundService.delete error: $e');
    }
  }
}
