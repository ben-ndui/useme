import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:useme/config/useme_theme.dart';

/// Custom map pin generator for studios - adapted from Viba
class CustomStudioPin {
  /// Create a pin with studio image
  static Future<BitmapDescriptor> createPinWithImage({
    required String? imageUrl,
    Color pinColor = UseMeTheme.primaryColor,
    double size = 80,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final double shadowWidth = size / 20;
    final double pinWidth = size * 0.8;
    final double pinHeight = size;
    final double imageSize = size * 0.55;

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
    final ui.Image finalImage = await pictureRecorder.endRecording().toImage(
          size.toInt(),
          size.toInt(),
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
