import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:social/constants/global_variables.dart';

class QRCodeScreen extends StatefulWidget {
  static const String routeName = '/qrscreen';

  @override
  State<StatefulWidget> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  String qrCode = 'Unknown';

  @override
  void initState() {
    super.initState();
    // Trigger the QR code scanner when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scanQRCode();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(
        Icons.arrow_back, // Back arrow icon
        color: GlobalVariables.greenColor, // Set the color to match your design
      ),
      onPressed: () {
        Navigator.pop(context); // Navigate back to the previous screen
      },
    ),
    title: const Text(
      'Scan QR',
      style: TextStyle(
        fontFamily: 'Regular',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: GlobalVariables.greenColor,
      ),
    ),
  ),
  body: Stack(
    children: [
      const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Scan Result',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            // You can add the QR code result text here if needed
          ],
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50.0), // 50 pixels from the bottom
          child: IconButton(
            icon: const Icon(
              Icons.qr_code_scanner,
              color: Colors.black,
              size: 25,
            ), // Scan icon
            onPressed: () async {
              Navigator.pushNamed(context, '/scan');
            },
          ),
        ),
      ),
    ],
  ),
);


  Future<void> scanQRCode() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );

      if (!mounted) return;

      // Pass the scanned result back to the parent screen
      Navigator.pop(context, qrCode);
    } on PlatformException {
      qrCode = 'Failed to get platform version.';
      Navigator.pop(context, qrCode); // Pass the error back if scanning fails
    }
  }
}