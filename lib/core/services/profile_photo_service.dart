import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Service pour gérer les photos de profil utilisateur
class ProfilePhotoService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Affiche un bottom sheet pour choisir la source de l'image
  Future<File?> pickImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ImageSourceSheet(),
    );

    if (source == null) return null;

    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile == null) return null;
    return File(pickedFile.path);
  }

  /// Upload une photo de profil et retourne l'URL
  Future<SmoothResponse<String>> uploadProfilePhoto({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final ref = _storage.ref().child('profile_photos').child(userId).child('photo.jpg');

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return SmoothResponse(
        data: downloadUrl,
        message: 'Photo uploadée',
        code: 200,
      );
    } on FirebaseException catch (e) {
      return SmoothResponse(
        data: '',
        message: 'Erreur Firebase: ${e.message}',
        code: 500,
      );
    } catch (e) {
      return SmoothResponse(
        data: '',
        message: 'Erreur: $e',
        code: 500,
      );
    }
  }

  /// Supprime la photo de profil
  Future<SmoothResponse<bool>> deleteProfilePhoto(String userId) async {
    try {
      final ref = _storage.ref().child('profile_photos').child(userId).child('photo.jpg');
      await ref.delete();
      return SmoothResponse(data: true, message: 'Photo supprimée', code: 200);
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return SmoothResponse(data: true, message: 'OK', code: 200);
      }
      return SmoothResponse(data: false, message: 'Erreur: ${e.message}', code: 500);
    }
  }
}

class _ImageSourceSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.changePhoto,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.camera_alt, color: theme.colorScheme.primary),
              ),
              title: Text(l10n.takePhoto),
              subtitle: Text(
                l10n.useCamera,
                style: theme.textTheme.bodySmall,
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.photo_library, color: theme.colorScheme.secondary),
              ),
              title: Text(l10n.chooseFromGallery),
              subtitle: Text(
                l10n.selectExistingPhoto,
                style: theme.textTheme.bodySmall,
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
