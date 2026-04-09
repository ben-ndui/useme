import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:useme/config/useme_theme.dart';

/// Custom map pin generator for studios - adapted from Viba
class CustomStudioPin {
  /// Create a pin with studio image
  ///
  /// When [isSelected] is true, the pin is drawn larger with a bright
  /// glow ring to highlight it on the map.
  static Future<BitmapDescriptor> createPinWithImage({
    required String? imageUrl,
    Color pinColor = UseMeTheme.primaryColor,
    double size = 80,
    bool isSelected = false,
    bool isDark = true,
  }) async {
    // Selected pins are 30% larger with a glow ring
    final double effectiveSize = isSelected ? size * 1.3 : size;
    final double glowPadding = isSelected ? effectiveSize * 0.12 : 0;
    final double totalSize = effectiveSize + glowPadding * 2;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // Offset drawing to leave room for the glow
    if (isSelected) canvas.translate(glowPadding, glowPadding);

    final double shadowWidth = effectiveSize / 20;
    final double pinWidth = effectiveSize * 0.8;
    final double pinHeight = effectiveSize;
    final double imageSize = effectiveSize * 0.55;

    // Draw glow ring behind pin when selected
    if (isSelected) {
      final glowColor = isDark
          ? Colors.white.withValues(alpha: 0.7)
          : pinColor.withValues(alpha: 0.5);
      final Paint glowPaint = Paint()
        ..color = glowColor
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowPadding);

      final Path glowPath = Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(-glowPadding / 2, -glowPadding / 2,
              pinWidth + glowPadding, pinHeight * 0.75 + glowPadding),
          Radius.circular(pinWidth * 0.25),
        ));

      canvas.drawPath(glowPath, glowPaint);
    }

    // Draw shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowWidth);

    final Path shadowPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(shadowWidth, shadowWidth, pinWidth, pinHeight * 0.75),
        Radius.circular(pinWidth * 0.2),
      ))
      ..moveTo(pinWidth / 2 + shadowWidth, pinHeight * 0.75 + shadowWidth)
      ..lineTo(pinWidth / 2 + shadowWidth, pinHeight + shadowWidth);

    canvas.drawPath(shadowPath, shadowPaint);

    // Draw pin body
    final Paint pinPaint = Paint()..color = pinColor;

    final Path pinPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, pinWidth, pinHeight * 0.75),
        Radius.circular(pinWidth * 0.2),
      ))
      ..moveTo(pinWidth / 2 - 8, pinHeight * 0.75)
      ..lineTo(pinWidth / 2, pinHeight * 0.92)
      ..lineTo(pinWidth / 2 + 8, pinHeight * 0.75)
      ..close();

    canvas.drawPath(pinPath, pinPaint);

    // Load image
    ui.Image? image;
    try {
      Uint8List? imageBytes;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(imageUrl)).timeout(
              const Duration(seconds: 5),
            );
        if (response.statusCode == 200) {
          imageBytes = response.bodyBytes;
        }
      }

      if (imageBytes != null) {
        image = await _loadImage(imageBytes);
      }
    } catch (e) {
      // Use placeholder
    }

    final Rect imageRect = Rect.fromLTWH(
      (pinWidth - imageSize) / 2,
      (pinHeight * 0.75 - imageSize) / 2,
      imageSize,
      imageSize,
    );

    if (image != null) {
      // Draw image with rounded corners
      final Path clipPath = Path()
        ..addRRect(RRect.fromRectAndRadius(
          imageRect,
          Radius.circular(imageSize * 0.15),
        ));

      canvas.save();
      canvas.clipPath(clipPath);
      _paintImage(canvas: canvas, rect: imageRect, image: image);
      canvas.restore();

      // Add white border
      final Paint borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          imageRect,
          Radius.circular(imageSize * 0.15),
        ),
        borderPaint,
      );
    } else {
      // Draw placeholder with music icon
      final Paint placeholderPaint = Paint()..color = Colors.white;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          imageRect,
          Radius.circular(imageSize * 0.15),
        ),
        placeholderPaint,
      );

      // Draw music note
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: '♪',
          style: TextStyle(
            color: pinColor,
            fontSize: imageSize * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (pinWidth - textPainter.width) / 2,
          (pinHeight * 0.75 - textPainter.height) / 2,
        ),
      );
    }

    // Convert to image
    final int canvasSize = totalSize.toInt();
    final ui.Image finalImage = await pictureRecorder.endRecording().toImage(
          canvasSize,
          canvasSize,
        );

    final ByteData? byteData =
        await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8list = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(uint8list);
  }

  /// Create user location pin (circular with profile image)
  static Future<BitmapDescriptor> createUserLocationPin({
    String? profileImageUrl,
    double size = 60,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final double radius = size / 2;

    // Draw outer shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(Offset(radius + 2, radius + 2), radius, shadowPaint);

    // Draw white outer circle
    final Paint outerCirclePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(radius, radius), radius, outerCirclePaint);

    // Draw blue border
    final Paint blueBorderPaint = Paint()..color = UseMeTheme.primaryColor;
    canvas.drawCircle(Offset(radius, radius), radius - 3, blueBorderPaint);

    // Load profile image or draw placeholder
    ui.Image? profileImage;
    try {
      if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(profileImageUrl)).timeout(
              const Duration(seconds: 5),
            );
        if (response.statusCode == 200) {
          profileImage = await _loadImage(response.bodyBytes);
        }
      }
    } catch (e) {
      // Use placeholder
    }

    final double imageRadius = radius - 6;
    final Rect imageRect = Rect.fromCircle(
      center: Offset(radius, radius),
      radius: imageRadius,
    );

    if (profileImage != null) {
      // Draw profile image with circular clip
      final Path clipPath = Path()..addOval(imageRect);
      canvas.save();
      canvas.clipPath(clipPath);
      _paintImage(canvas: canvas, rect: imageRect, image: profileImage);
      canvas.restore();
    } else {
      // Draw white placeholder
      final Paint placeholderBgPaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(radius, radius), imageRadius, placeholderBgPaint);

      // Draw music icon
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: '♪',
          style: TextStyle(
            color: UseMeTheme.primaryColor,
            fontSize: imageRadius * 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          radius - textPainter.width / 2,
          radius - textPainter.height / 2,
        ),
      );
    }

    // Convert to image
    final ui.Image finalImage = await pictureRecorder.endRecording().toImage(
          size.toInt(),
          size.toInt(),
        );

    final ByteData? byteData =
        await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8list = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(uint8list);
  }

  /// Simple pin for partner studios (green)
  static Future<BitmapDescriptor> createPartnerPin({double size = 80}) async {
    return createPinWithImage(imageUrl: null, pinColor: Colors.green, size: size);
  }

  /// Simple pin for non-partner studios (blue)
  static Future<BitmapDescriptor> createDefaultPin({double size = 80}) async {
    return createPinWithImage(
      imageUrl: null,
      pinColor: UseMeTheme.primaryColor,
      size: size,
    );
  }

  static Future<ui.Image> _loadImage(Uint8List bytes) async {
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  static void _paintImage({
    required Canvas canvas,
    required Rect rect,
    required ui.Image image,
  }) {
    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final FittedSizes sizes = applyBoxFit(BoxFit.cover, imageSize, rect.size);
    final Rect outputSubrect = Alignment.center.inscribe(sizes.destination, rect);
    final Rect inputSubrect = Alignment.center.inscribe(
      sizes.source,
      Rect.fromLTWH(0, 0, imageSize.width, imageSize.height),
    );

    canvas.drawImageRect(image, inputSubrect, outputSubrect, Paint());
  }
}
