import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/widgets/card/scanned_contact_sheet.dart';
import 'package:uzme/widgets/common/snackbar/app_snackbar.dart';

/// QR code scanner screen for scanning UZME profile cards.
/// Detects `uzme.app/u/{userId}` URLs and shows the scanned contact sheet.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    final url = barcode!.rawValue!;
    final userId = _extractUserId(url);

    if (userId == null) {
      AppSnackBar.warning(
          context, AppLocalizations.of(context)!.invalidQrCode);
      return;
    }

    _hasScanned = true;
    _controller.stop();

    // Pop scanner then show scanned contact sheet with HoloCard
    Navigator.pop(context);
    ScannedContactSheet.show(context, userId);
  }

  String? _extractUserId(String url) {
    final regex = RegExp(r'uzme\.app/u/([a-zA-Z0-9]+)');
    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    final scanArea = MediaQuery.sizeOf(context).width * 0.7;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Scanner', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Scan overlay
          Center(
            child: Container(
              width: scanArea,
              height: scanArea,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
            ),
          ),
          // Corner accents
          Center(
            child: SizedBox(
              width: scanArea,
              height: scanArea,
              child: CustomPaint(painter: _CornerPainter()),
            ),
          ),
          // Bottom hint
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                FaIcon(FontAwesomeIcons.qrcode,
                    size: 24, color: Colors.white.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                Text(
                  'Pointe la camera vers un QR code UZME',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws accent corners on the scan area.
class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 30.0;
    const r = 24.0;

    // Top-left
    canvas.drawArc(
        Rect.fromLTWH(0, 0, r * 2, r * 2), 3.14, 0.5, false, paint);
    canvas.drawLine(Offset(0, r), Offset(0, len), paint);
    canvas.drawLine(Offset(r, 0), Offset(len, 0), paint);

    // Top-right
    canvas.drawLine(
        Offset(size.width - len, 0), Offset(size.width, 0), paint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, len), paint);

    // Bottom-left
    canvas.drawLine(const Offset(0, 0), Offset(0, len), paint);
    canvas.drawLine(
        Offset(0, size.height), Offset(0, size.height - len), paint);
    canvas.drawLine(
        Offset(0, size.height), Offset(len, size.height), paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width - len, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - len), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
