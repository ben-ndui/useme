import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smoothandesign_package/smoothandesign.dart' show SmoothResponse;
import 'package:uzme/widgets/common/permission_dialog.dart';

/// Service for picking and uploading session tracking photos
class SessionPhotoService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Shows source picker, captures/selects image, uploads to Firebase Storage.
  /// Returns the download URL on success, null on cancellation.
  Future<SmoothResponse<String?>> pickAndUploadPhoto({
    required BuildContext context,
    required String sessionId,
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return SmoothResponse(code: 0, message: 'Cancelled');

    if (!context.mounted) return SmoothResponse(code: 0, message: 'Cancelled');
    final permissionType = source == ImageSource.camera
        ? AppPermissionType.camera
        : AppPermissionType.photos;
    final granted =
        await PermissionDialog.requestPermission(context, type: permissionType);
    if (!granted) return SmoothResponse(code: 0, message: 'Permission denied');

    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFile == null) return SmoothResponse(code: 0, message: 'No file');

    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
      final ref = _storage
          .ref()
          .child('sessions')
          .child(sessionId)
          .child('photos')
          .child(fileName);

      final uploadTask = ref.putFile(
        File(pickedFile.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return SmoothResponse(code: 200, message: 'OK', data: downloadUrl);
    } on FirebaseException catch (e) {
      return SmoothResponse(
          code: 500, message: 'Erreur Firebase: ${e.message}');
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e');
    }
  }
}
