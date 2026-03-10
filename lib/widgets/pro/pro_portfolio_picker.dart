import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Widget for picking and displaying portfolio images for pro profiles.
class ProPortfolioPicker extends StatefulWidget {
  final String userId;
  final List<String> portfolioUrls;
  final ValueChanged<List<String>> onChanged;

  const ProPortfolioPicker({
    super.key,
    required this.userId,
    required this.portfolioUrls,
    required this.onChanged,
  });

  @override
  State<ProPortfolioPicker> createState() => _ProPortfolioPickerState();
}

class _ProPortfolioPickerState extends State<ProPortfolioPicker> {
  static const _maxPhotos = 6;
  bool _isUploading = false;

  Future<void> _pickAndUpload() async {
    if (widget.portfolioUrls.length >= _maxPhotos) return;

    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (images.isEmpty) return;

    final remaining = _maxPhotos - widget.portfolioUrls.length;
    final toUpload = images.take(remaining).toList();

    setState(() => _isUploading = true);

    try {
      final storage = FirebaseStorage.instance;
      final newUrls = <String>[];

      for (final image in toUpload) {
        final ext = image.path.split('.').last;
        final ts = DateTime.now().millisecondsSinceEpoch;
        final ref = storage.ref('pro_portfolio/${widget.userId}/$ts.$ext');
        await ref.putFile(File(image.path));
        final url = await ref.getDownloadURL();
        newUrls.add(url);
      }

      widget.onChanged([...widget.portfolioUrls, ...newUrls]);
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, AppLocalizations.of(context)!.uploadError);
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _removePhoto(int index) async {
    final url = widget.portfolioUrls[index];
    final updated = List<String>.from(widget.portfolioUrls)..removeAt(index);
    widget.onChanged(updated);

    // Delete from storage in background
    try {
      await FirebaseStorage.instance.refFromURL(url).delete();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final count = widget.portfolioUrls.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FaIcon(FontAwesomeIcons.images, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              l10n.proPortfolio,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '$count/$_maxPhotos',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...widget.portfolioUrls.asMap().entries.map((entry) =>
                  _buildPhotoTile(theme, entry.key, entry.value)),
              if (count < _maxPhotos) _buildAddButton(theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoTile(ThemeData theme, int index, String url) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 120,
                height: 120,
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.broken_image, size: 32),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removePhoto(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(ThemeData theme) {
    return GestureDetector(
      onTap: _isUploading ? null : _pickAndUpload,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: _isUploading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.plus, size: 20,
                      color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context)!.addPhoto,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
