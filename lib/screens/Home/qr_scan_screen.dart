import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social/constants/global_variables.dart';

// class QRScanScreen extends StatefulWidget {
//   static const String routeName = '/scan';

//   @override
//   State<StatefulWidget> createState() => _QRScanScreenState();
// }

// class _QRScanScreenState extends State<QRScanScreen> {
//   String qrCode = 'Unknown';

//   @override
//   void initState() {
//     super.initState();
//     // Trigger the QR code scanner when the page loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       scanQRCode();
//     });
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//   appBar: AppBar(
//     backgroundColor: Colors.transparent,
//     elevation: 0,
//     leading: IconButton(
//       icon: const Icon(
//         Icons.arrow_back, // Back arrow icon
//         color: GlobalVariables.greenColor, // Set the color to match your design
//       ),
//       onPressed: () {
//         Navigator.pop(context); // Navigate back to the previous screen
//       },
//     ),
//     title: const Text(
//       'Scan QR',
//       style: TextStyle(
//         fontFamily: 'Regular',
//         fontSize: 16,
//         fontWeight: FontWeight.bold,
//         color: GlobalVariables.greenColor,
//       ),
//     ),
//   ),
//   body: Stack(
//     children: [
//       const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Scan Result',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.white54,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 8),
//             // You can add the QR code result text here if needed
//           ],
//         ),
//       ),
//       Align(
//         alignment: Alignment.bottomCenter,
//         child: Padding(
//           padding: const EdgeInsets.only(bottom: 50.0), // 50 pixels from the bottom
//           child: IconButton(
//             icon: const Icon(
//               Icons.qr_code_scanner,
//               color: Colors.black,
//               size: 25,
//             ), // Scan icon
//             onPressed: () async {
//               Navigator.pushNamed(context, '/scan');
//             },
//           ),
//         ),
//       ),
//     ],
//   ),
// );


//   Future<void> scanQRCode() async {
//     try {
//       final qrCode = await FlutterBarcodeScanner.scanBarcode(
//         '#ff6666',
//         'Cancel',
//         true,
//         ScanMode.QR,
//       );

//       if (!mounted) return;

//       // Pass the scanned result back to the parent screen
//       Navigator.pop(context, qrCode);
//     } on PlatformException {
//       qrCode = 'Failed to get platform version.';
//       Navigator.pop(context, qrCode); // Pass the error back if scanning fails
//     }
//   }
// }





import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanScreen extends StatefulWidget {
  static const String routeName = '/scan';

  @override
  State<StatefulWidget> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  late MobileScannerController cameraController;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: GlobalVariables.greenColor,
            ),
            onPressed: () {
              Navigator.pop(context);
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
          actions: [
            IconButton(
              icon: ValueListenableBuilder(
                valueListenable: cameraController.torchState,
                builder: (context, state, child) {
                  return Icon(
                    state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                    color: GlobalVariables.greenColor,
                  );
                },
              ),
              onPressed: () => cameraController.toggleTorch(),
            ),
            IconButton(
              icon: ValueListenableBuilder(
                valueListenable: cameraController.cameraFacingState,
                builder: (context, state, child) {
                  return Icon(
                    state == CameraFacing.front
                        ? Icons.camera_front
                        : Icons.camera_rear,
                    color: GlobalVariables.greenColor,
                  );
                },
              ),
              onPressed: () => cameraController.switchCamera(),
            ),
          ],
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  // Return the first valid barcode
                  if (barcode.rawValue != null) {
                    Navigator.pop(context, barcode.rawValue);
                    return;
                  }
                }
              },
              overlay: QRScannerOverlay(
                overlayColor: Colors.black.withOpacity(0.5),
              ),
            ),
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
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.black,
                    size: 25,
                  ),
                  onPressed: () {
                    // Reset scanner if needed
                    cameraController.start();
                  },
                ),
              ),
            ),
          ],
        ),
      );
}

// Custom overlay widget for scanner
class QRScannerOverlay extends StatelessWidget {
  const QRScannerOverlay({
    Key? key,
    required this.overlayColor,
  }) : super(key: key);

  final Color overlayColor;

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final size = MediaQuery.of(context).size;
    // Calculate the scan area size
    final scanAreaSize = size.width * 0.7;

    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            overlayColor,
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Center(
                  child: Container(
                    height: scanAreaSize,
                    width: scanAreaSize,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Container(
            width: scanAreaSize,
            height: scanAreaSize,
            decoration: BoxDecoration(
              border: Border.all(
                color: GlobalVariables.greenColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}