import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uzme/core/utils/app_logger.dart';

/// Export format presets for social media sharing.
enum CardExportFormat {
  /// Instagram/TikTok story — 1080 x 1920.
  story(1080, 1920, 'Story'),

  /// Square post — 1080 x 1080.
  post(1080, 1080, 'Post'),

  /// Landscape (Twitter/LinkedIn banner) — 1920 x 1080.
  landscape(1920, 1080, 'Paysage');

  final int width;
  final int height;
  final String label;

  const CardExportFormat(this.width, this.height, this.label);

  double get aspectRatio => width / height;
}

/// Captures a RepaintBoundary widget to PNG and shares it.
class CardExportService {
  /// Capture a [RenderRepaintBoundary] at the given [format] resolution.
  /// Returns the PNG bytes, or null on failure.
  Future<Uint8List?> capture(
    RenderRepaintBoundary boundary,
    CardExportFormat format,
  ) async {
    try {
      // Calculate pixel ratio to reach target resolution
      final logicalSize = boundary.size;
      final pixelRatio = format.width / logicalSize.width;

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) return null;
      return byteData.buffer.asUint8List();
    } catch (e) {
      appLog('CardExportService.capture error: $e');
      return null;
    }
  }

  /// Save PNG bytes to a temp file and share via the native share sheet.
  Future<void> share(Uint8List pngBytes, {String? text}) async {
    try {
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/uzme_card_$timestamp.png');
      await file.writeAsBytes(pngBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: text,
        ),
      );
    } catch (e) {
      appLog('CardExportService.share error: $e');
    }
  }
}
