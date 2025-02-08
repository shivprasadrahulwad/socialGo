import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;
import 'package:share_plus/share_plus.dart';



class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({Key? key}) : super(key: key);

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String qrData = "https://example.com"; // Example QR data
  bool isScannerActive = true;
  final GlobalKey _qrKey = GlobalKey();
  MobileScannerController scannerController = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Camera permission is required to scan QR codes')),
      );
    }
  }

  Future<void> _shareQRCode() async {
    try {
      // Capture the widget as an image
      final RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        // Convert to bytes
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        
        // Create a temporary file
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/qr_code.png');
        await file.writeAsBytes(pngBytes);
        
        // Share the file
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Scan this code using the SocialGo camera to get my number',
        );
      }
    } catch (e) {
      print('Error sharing QR code: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to share QR code')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code', style: TextStyle(fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareQRCode,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              print('More button pressed');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code),
                  SizedBox(width: 8),
                  Text('MY CODE'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner),
                  SizedBox(width: 8),
                  Text('SCAN'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Container(
            color: Colors.white,
            child: Center(
              child: SingleChildScrollView(
                child: RepaintBoundary(
                  key: _qrKey,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: const StyledQRCode(
                            data: "Shivprasad Rahulwad",
                            height: 400,
                            imageUrl: "assets/images/shrutika.png",
                            primaryColor: Color(0xFF6B4EFF),
                            secondaryColor: Color(0xFF00D1FF),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Scan this code using the SocialGo camera to get my number',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Stack(
            children: [
              MobileScanner(
                controller: scannerController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    debugPrint('Barcode found! ${barcode.rawValue}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Scanned: ${barcode.rawValue}')),
                    );
                  }
                },
              ),
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  onPressed: () => scannerController.toggleTorch(),
                  child: ValueListenableBuilder(
                    valueListenable: scannerController.torchState,
                    builder: (context, state, child) {
                      return Icon(
                        state == TorchState.on
                            ? Icons.flash_on
                            : Icons.flash_off,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StyledQRCode extends StatelessWidget {
  final String data;
  final double height;
  final Color primaryColor;
  final Color secondaryColor;
  final String imageUrl;

  const StyledQRCode({
    Key? key,
    required this.data,
    required this.height,
    this.primaryColor = const Color(0xFF6B4EFF),
    this.secondaryColor = const Color(0xFF00D1FF),
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth =
        screenWidth - 20; // Account for padding (10 on each side)
    final qrSize = containerWidth * 0.5; // QR code takes 60% of container width

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: containerWidth,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                      height: 20), // Space for overlapping profile image
                  const Text(
                    'Shivprasad Rahulwad',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    'SocialGo contact',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: qrSize,
                    height: qrSize,
                    child: CustomPaint(
                      size: Size(qrSize, qrSize),
                      painter: GradientQrPainter(
                        data: data,
                        version: QrVersions.auto,
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                        primaryColor: primaryColor,
                        secondaryColor: secondaryColor,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Colors.black,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.circle,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -30,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GradientQrPainter extends QrPainter {
  final Color primaryColor;
  final Color secondaryColor;

  GradientQrPainter({
    required String data,
    required int version,
    required this.primaryColor,
    required this.secondaryColor,
    required int errorCorrectionLevel,
    required QrEyeStyle eyeStyle,
    required QrDataModuleStyle dataModuleStyle,
  }) : super(
          data: data,
          version: version,
          errorCorrectionLevel: errorCorrectionLevel,
          eyeStyle: eyeStyle,
          dataModuleStyle: dataModuleStyle,
        );

  @override
  void paint(Canvas canvas, Size size) {
    // Create gradient shader
    final Rect rect = Offset.zero & size;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryColor, secondaryColor],
      ).createShader(rect);

    // Paint the QR code using the gradient
    final oldPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black;

    // Save canvas state
    canvas.saveLayer(rect, Paint());

    // Draw original QR code in black
    super.paint(canvas, size);

    // Apply gradient overlay
    canvas.drawRect(rect, paint..blendMode = BlendMode.srcIn);

    // Restore canvas state
    canvas.restore();

    // Draw decorative border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryColor, secondaryColor],
      ).createShader(rect);

    // Draw rounded border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(size.width * 0.1),
        Radius.circular(size.width * 0.05),
      ),
      borderPaint,
    );
  }
}
