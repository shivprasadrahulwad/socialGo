// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:local_auth/local_auth.dart';

// class ChatLockScreen extends StatefulWidget {
//   const ChatLockScreen({super.key});

//   @override
//   State<ChatLockScreen> createState() => _ChatLockScreenState();
// }

// class _ChatLockScreenState extends State<ChatLockScreen> {
//   late final LocalAuthentication auth;
//   bool _supportState = false;

//   @override
//   void initState() {
//     super.initState();
//     auth = LocalAuthentication();
//     auth.isDeviceSupported().then((bool isSupported) => setState(() {
//           _supportState = isSupported;
//         }));
//   }

//   Future<void> _getAvailableBiometrics() async {
//     List<BiometricType> ava = await auth.getAvailableBiometrics();
//     print("list of availableBiometrics: $ava");

//     if (!mounted) {
//       // Fixed the mounting check logic
//       return;
//     }
//   }

//   Future<void> _authenticate() async {
//     try {
//       bool authenticated = await auth.authenticate(
//           localizedReason:
//               'Subscribe or you will never find any stack overflow answers',
//           options: const AuthenticationOptions(
//             stickyAuth: true,
//             biometricOnly: false,
//           ));

//           print('authenticated:  $authenticated');
//     } on PlatformException catch (e) {
//       print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       // Added MaterialApp wrapper
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Authentication'),
//         ),
//         body: Column(
//           children: [
//             if (_supportState)
//               const Text('This device is supported')
//             else
//               const Text('This device is not supported'),
//             const Divider(height: 100),
//             ElevatedButton(
//                 onPressed: _getAvailableBiometrics,
//                 child: const Text('Get available biometrics')),
//             const Divider(height: 100),
//             ElevatedButton(
//                 onPressed: _authenticate, child: const Text('_authenticate')),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:flutter/services.dart';

// class ChatLockScreen extends StatefulWidget {
//   const ChatLockScreen({super.key});

//   @override
//   State<ChatLockScreen> createState() => _ChatLockScreenState();
// }

// class _ChatLockScreenState extends State<ChatLockScreen> {
//   late final LocalAuthentication auth;
//   bool _supportState = false;

//   @override
//   void initState() {
//     super.initState();
//     auth = LocalAuthentication();
//     _checkBiometrics();
//   }

//   // Check if the device supports biometric authentication
//   Future<void> _checkBiometrics() async {
//     try {
//       bool isSupported = await auth.isDeviceSupported();
//       setState(() {
//         _supportState = isSupported;
//       });

//       if (_supportState) {
//         // Immediately start biometric authentication if supported
//         _authenticate();
//       } else {
//         // Handle the case where biometric is not supported
//         print("Device does not support biometric authentication.");
//       }
//     } on PlatformException catch (e) {
//       print("Error checking biometrics: $e");
//     }
//   }

//   // Method to authenticate the user
//   Future<void> _authenticate() async {
//     try {
//       bool authenticated = await auth.authenticate(
//         localizedReason: 'Please authenticate to continue',
//         options: const AuthenticationOptions(
//           biometricOnly: true, // Only biometric authentication
//           stickyAuth: true,    // Keep the authentication screen active until successful
//         ),
//       );

//       if (authenticated) {
//         // Handle successful authentication
//         print('Authentication successful');
//         setState(() {
//           // Update UI or navigate to the next screen after successful authentication
//         });
//       } else {
//         // Handle failed authentication
//         print('Authentication failed');
//       }
//     } on PlatformException catch (e) {
//       // Handle platform-specific errors
//       print("Error during authentication: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Authentication'),
//       ),
//       body: Center(
//         child: _supportState
//             ? const Text('Please authenticate to continue')
//             : const Text('Device does not support biometric authentication'),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:flutter/services.dart';

// class ChatLockScreen extends StatefulWidget {
//   const ChatLockScreen({super.key});

//   @override
//   State<ChatLockScreen> createState() => _ChatLockScreenState();
// }

// class _ChatLockScreenState extends State<ChatLockScreen> {
//   late final LocalAuthentication auth;
//   bool _supportState = false;

//   @override
//   void initState() {
//     super.initState();
//     auth = LocalAuthentication();
//     _checkBiometrics();
//   }

//   Future<void> _checkBiometrics() async {
//     try {
//       bool isSupported = await auth.isDeviceSupported();
//       setState(() {
//         _supportState = isSupported;
//       });

//       if (_supportState) {
//         // Don't start authentication immediately, let user initiate it
//         print("Biometric authentication is supported");
//       } else {
//         print("Device does not support biometric authentication.");
//       }
//     } on PlatformException catch (e) {
//       print("Error checking biometrics: $e");
//     }
//   }

//   Future<void> _authenticate() async {
//     try {
//       bool authenticated = await auth.authenticate(
//         localizedReason: 'Please authenticate to view your chat lock code',
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           stickyAuth: true,
//         ),
//       );

//       if (authenticated) {
//         // Show a mock chat lock code - in real app, retrieve from secure storage
//         _showLockCodeDialog();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Authentication failed')),
//         );
//       }
//     } on PlatformException catch (e) {
//       print("Error during authentication: $e");
//     }
//   }

//   void _showLockCodeDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Your Chat Lock Code'),
//         content: const Text('1234'), // Replace with actual stored code
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           'Retrieve chat lock code',
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 20),
//               // Lock image
//               Image.asset(
//                 'assets/lock_image.png', // Add your lock image to assets
//                 height: 150,
//                 width: 150,
//               ),
//               const SizedBox(height: 30),
//               const Text(
//                 'Chat lock keeps your chats locked and hidden in same chat',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'If you have locked chats and you forgot the lock code, then you are in the correct place. Use your authentication and check your locked chat code.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 40),
//               if (_supportState)
//                 ElevatedButton(
//                   onPressed: _authenticate,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF075E54), // WhatsApp green
//                     minimumSize: const Size(200, 50),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                   ),
//                   child: const Text(
//                     'Authenticate to View Code',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white,
//                     ),
//                   ),
//                 )
//               else
//                 const Text(
//                   'Your device does not support biometric authentication',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Colors.red,
//                     fontSize: 16,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:social/screens/settings/get_chat_code_screen.dart';

// First Screen
class ChatLockScreen extends StatefulWidget {
  const ChatLockScreen({super.key});

  @override
  State<ChatLockScreen> createState() => _ChatLockScreenState();
}

class _ChatLockScreenState extends State<ChatLockScreen> {
  late final LocalAuthentication auth;
  bool _supportState = false;

  @override
  void initState() {
    super.initState();
    auth = LocalAuthentication();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      bool isSupported = await auth.isDeviceSupported();
      setState(() {
        _supportState = isSupported;
      });
    } on PlatformException catch (e) {
      print("Error checking biometrics: $e");
    }
  }

  Future<void> _authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to view your chat lock code',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        // Navigate to GetChatCodeScreen on successful authentication
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GetChatCodeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication failed')),
        );
      }
    } on PlatformException catch (e) {
      print("Error during authentication: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Retrieve chat lock code',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/settings.png',
                height: 150,
                width: 150,
              ),
              const SizedBox(height: 30),
              const Text(
                'Chat lock keeps your chats locked and hidden in same chat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'If you have locked chats and you forgot the lock code, then you are in the correct place. Use your authentication, after that use remote userId and then check your locked chat code.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              if (_supportState)
                ElevatedButton(
                  onPressed: _authenticate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6200EE),
                    minimumSize: Size(MediaQuery.of(context).size.width - 32, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Authenticate to Continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                const Text(
                  'Your device does not support biometric authentication',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}