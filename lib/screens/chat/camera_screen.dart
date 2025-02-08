// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:social/screens/chat/camera_view_screen.dart';
import 'package:social/screens/chat/video_view_screen.dart';

late List<CameraDescription> cameras;

// class CameraScreen extends StatefulWidget {
//   const CameraScreen({
//     Key? key,
//     required this.onImageSend,
//   }) : super(key: key);

//   final Function onImageSend;

//   @override
//   State<CameraScreen> createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   late CameraController _cameraController;
//   Future<void>? cameraValue;
//   bool isRecoring = false;
//   bool flash = false;
//   bool iscamerafront = true;
//   double transform = 0;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     if (cameras.isNotEmpty) {
//       _cameraController = CameraController(cameras[0], ResolutionPreset.max);
//       cameraValue = _cameraController.initialize();
//       setState(() {});
//     } else {
//       debugPrint('No cameras found');
//     }
//   }

//   @override
//   void dispose() {
//     _cameraController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           FutureBuilder(
//               future: cameraValue,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   return Container(
//                       width: MediaQuery.of(context).size.width,
//                       height: MediaQuery.of(context).size.height,
//                       child: CameraPreview(_cameraController));
//                 } else {
//                   return const Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }
//               }),
//           Positioned(
//             bottom: 0.0,
//             child: Container(
//               color: Colors.black,
//               padding: const EdgeInsets.only(top: 5, bottom: 5),
//               width: MediaQuery.of(context).size.width,
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisSize: MainAxisSize.max,
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       IconButton(
//                           icon: Icon(
//                             flash ? Icons.flash_on : Icons.flash_off,
//                             color: Colors.white,
//                             size: 28,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               flash = !flash;
//                             });
//                             flash
//                                 ? _cameraController
//                                     .setFlashMode(FlashMode.torch)
//                                 : _cameraController.setFlashMode(FlashMode.off);
//                           }),
//                       GestureDetector(
//                         onLongPress: () async {
//                           await _cameraController.startVideoRecording();
//                           setState(() {
//                             isRecoring = true;
//                           });
//                         },
//                         onLongPressUp: () async {
//                           XFile videopath =
//                               await _cameraController.stopVideoRecording();
//                           setState(() {
//                             isRecoring = false;
//                           });
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (builder) => VideoViewPage(
//                                         path: videopath.path,
//                                       )));
//                         },
//                         onTap: () {
//                           if (!isRecoring) takePhoto(context);
//                         },
//                         child: isRecoring
//                             ? const Icon(
//                                 Icons.radio_button_on,
//                                 color: Colors.red,
//                                 size: 80,
//                               )
//                             : const Icon(
//                                 Icons.panorama_fish_eye,
//                                 color: Colors.white,
//                                 size: 70,
//                               ),
//                       ),
//                       IconButton(
//                           icon: Transform.rotate(
//                             angle: transform,
//                             child: const Icon(
//                               Icons.flip_camera_ios,
//                               color: Colors.white,
//                               size: 28,
//                             ),
//                           ),
//                           onPressed: () async {
//                             setState(() {
//                               iscamerafront = !iscamerafront;
//                               transform = transform + pi;
//                             });
//                             int cameraPos = iscamerafront ? 0 : 1;
//                             _cameraController = CameraController(
//                                 cameras[cameraPos], ResolutionPreset.high);
//                             cameraValue = _cameraController.initialize();
//                           }),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 4,
//                   ),
//                   const Text(
//                     "Hold for Video, tap for photo",
//                     style: TextStyle(
//                       color: Colors.white,
//                     ),
//                     textAlign: TextAlign.center,
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void takePhoto(BuildContext context) async {
//     XFile file = await _cameraController.takePicture();
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (builder) => CameraViewPage(
//                   path: file.path, onImageSend:widget.onImageSend,
//                 )));
//   }
// }







class CameraScreen extends StatefulWidget {
  const CameraScreen({
    Key? key,
    required this.onImageSend,
    required this.onVideoSend,
  }) : super(key: key);

  final Function onImageSend;
  final Function onVideoSend;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  Future<void>? cameraValue;
  bool isRecoring = false;
  bool flash = false;
  bool iscamerafront = true;
  double transform = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(cameras[0], ResolutionPreset.max);
      cameraValue = _cameraController.initialize();
      setState(() {});
    } else {
      debugPrint('No cameras found');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
              future: cameraValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: CameraPreview(_cameraController));
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
          Positioned(
            bottom: 0.0,
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          icon: Icon(
                            flash ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            setState(() {
                              flash = !flash;
                            });
                            flash
                                ? _cameraController
                                    .setFlashMode(FlashMode.torch)
                                : _cameraController.setFlashMode(FlashMode.off);
                          }),
                      GestureDetector(
                        onLongPress: () async {
                          await _cameraController.startVideoRecording();
                          setState(() {
                            isRecoring = true;
                          });
                        },
                        onLongPressUp: () async {
                          XFile videopath =
                              await _cameraController.stopVideoRecording();
                          setState(() {
                            isRecoring = false;
                          });
                          // Navigate to VideoViewPage first
                          final shouldSend = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => VideoViewPage(
                                        path: videopath.path,
                                        onVideoSend: widget.onVideoSend,
                                      )));
                          
                          // If user confirmed in VideoViewPage, send the video
                          if (shouldSend == true) {
                            widget.onVideoSend(videopath.path);
                            Navigator.pop(context); // Return to chat screen
                          }
                        },
                        onTap: () {
                          if (!isRecoring) takePhoto(context);
                        },
                        child: isRecoring
                            ? const Icon(
                                Icons.radio_button_on,
                                color: Colors.red,
                                size: 80,
                              )
                            : const Icon(
                                Icons.panorama_fish_eye,
                                color: Colors.white,
                                size: 70,
                              ),
                      ),
                      IconButton(
                          icon: Transform.rotate(
                            angle: transform,
                            child: const Icon(
                              Icons.flip_camera_ios,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          onPressed: () async {
                            setState(() {
                              iscamerafront = !iscamerafront;
                              transform = transform + pi;
                            });
                            int cameraPos = iscamerafront ? 0 : 1;
                            _cameraController = CameraController(
                                cameras[cameraPos], ResolutionPreset.high);
                            cameraValue = _cameraController.initialize();
                          }),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  const Text(
                    "Hold for Video, tap for photo",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

void takePhoto(BuildContext context) async {
    XFile file = await _cameraController.takePicture();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (builder) => CameraViewPage(
                  path: file.path, onImageSend:widget.onImageSend,
                )));
  }
}