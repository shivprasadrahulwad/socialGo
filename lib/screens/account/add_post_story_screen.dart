import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:math';

List<CameraDescription> cameras = [];

class AddPostStoryScreen extends StatefulWidget {
  const AddPostStoryScreen({Key? key}) : super(key: key);

  @override
  _AddPostStoryScreenState createState() => _AddPostStoryScreenState();
}

class _AddPostStoryScreenState extends State<AddPostStoryScreen> {
  String selectedOption = 'Post';
  late CameraController _cameraController;
  Future<void>? cameraValue;
  bool isRecording = false;
  bool flash = false;
  bool isCameraFront = true;
  double transform = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      if (cameras.isEmpty) {
        cameras = await availableCameras();
      }
      
      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.max,
        enableAudio: true,
      );

      cameraValue = _cameraController.initialize();
      await cameraValue;
      
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera initialization failed: $e');
    }
  }

  void takePhoto(BuildContext context) async {
    if (!_cameraController.value.isInitialized) return;
    
    try {
      XFile file = await _cameraController.takePicture();
      // Handle the captured photo here
      debugPrint('Photo captured: ${file.path}');
    } catch (e) {
      debugPrint('Error taking photo: $e');
    }
  }

  @override
  void dispose() {
    if (_cameraController.value.isInitialized) {
      _cameraController.dispose();
    }
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.grey[200],
  //     appBar: AppBar(
  //       title: const Text('Post & Story Toggle'),
  //       centerTitle: true,
  //     ),
  //     body: Stack(
  //       children: [
  //         if (selectedOption == 'Post')
  //           Column(
  //             children: [
  //               Image.asset('assets/images/shrutika.png'),
  //               Padding(
  //                 padding: const EdgeInsets.all(20),
  //                 child: Row(
  //                   children: [
  //                     const Text(
  //                       'Recents',
  //                       style: TextStyle(fontSize: 16),
  //                     ),
  //                     const SizedBox(width: 5),
  //                     Transform.rotate(
  //                       angle: 1.5,
  //                       child: const Icon(
  //                         Icons.arrow_forward_ios,
  //                         size: 15,
  //                       ),
  //                     ),
  //                     const Spacer(),
  //                     const Icon(Icons.camera)
  //                   ],
  //                 ),
  //               )
  //             ],
  //           ),

  //         if (selectedOption == 'Story')
  //           FutureBuilder(
  //             future: cameraValue,
  //             builder: (context, snapshot) {
  //               if (snapshot.connectionState == ConnectionState.done) {
  //                 return SizedBox(
  //                   width: MediaQuery.of(context).size.width,
  //                   height: MediaQuery.of(context).size.height,
  //                   child: CameraPreview(_cameraController),
  //                 );
  //               } else {
  //                 return const Center(
  //                   child: CircularProgressIndicator(),
  //                 );
  //               }
  //             },
  //           ),

  //         if (selectedOption == 'Story')
  //           Positioned(
  //             bottom: 70.0,
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
  //                         icon: Icon(
  //                           flash ? Icons.flash_on : Icons.flash_off,
  //                           color: Colors.white,
  //                           size: 28,
  //                         ),
  //                         onPressed: () {
  //                           setState(() {
  //                             flash = !flash;
  //                           });
  //                           flash
  //                               ? _cameraController.setFlashMode(FlashMode.torch)
  //                               : _cameraController.setFlashMode(FlashMode.off);
  //                         },
  //                       ),
  //                       GestureDetector(
  //                         onLongPress: () async {
  //                           await _cameraController.startVideoRecording();
  //                           setState(() {
  //                             isRecording = true;
  //                           });
  //                         },
  //                         onLongPressUp: () async {
  //                           XFile videopath =
  //                               await _cameraController.stopVideoRecording();
  //                           setState(() {
  //                             isRecording = false;
  //                           });
  //                           // Handle video recording here
  //                         },
  //                         onTap: () {
  //                           if (!isRecording) takePhoto(context);
  //                         },
  //                         child: isRecording
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
  //                         icon: Transform.rotate(
  //                           angle: transform,
  //                           child: const Icon(
  //                             Icons.flip_camera_ios,
  //                             color: Colors.white,
  //                             size: 28,
  //                           ),
  //                         ),
  //                         onPressed: () async {
  //                           if (cameras.length < 2) return;
                            
  //                           setState(() {
  //                             isCameraFront = !isCameraFront;
  //                             transform = transform + pi;
  //                           });

  //                           int cameraPos = isCameraFront ? 0 : 1;
                            
  //                           if (_cameraController.value.isInitialized) {
  //                             await _cameraController.dispose();
  //                           }

  //                           _cameraController = CameraController(
  //                             cameras[cameraPos],
  //                             ResolutionPreset.high,
  //                             enableAudio: true,
  //                           );

  //                           cameraValue = _cameraController.initialize();
  //                           if (mounted) setState(() {});
  //                         },
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 4),
  //                   const Text(
  //                     "Hold for Video, tap for photo",
  //                     style: TextStyle(color: Colors.white),
  //                     textAlign: TextAlign.center,
  //                   )
  //                 ],
  //               ),
  //             ),
  //           ),

  //         Positioned(
  //           left: 20,
  //           right: 20,
  //           bottom: 30,
  //           child: Container(
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(30),
  //               boxShadow: const [
  //                 BoxShadow(
  //                   color: Colors.black26,
  //                   blurRadius: 8,
  //                   spreadRadius: 1,
  //                 ),
  //               ],
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceAround,
  //               children: [
  //                 GestureDetector(
  //                   onTap: () {
  //                     setState(() {
  //                       selectedOption = 'Post';
  //                     });
  //                   },
  //                   child: Container(
  //                     padding: const EdgeInsets.symmetric(
  //                       vertical: 12,
  //                       horizontal: 24,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.circular(10),
  //                       color: selectedOption == 'Post'
  //                           ? Colors.blueAccent
  //                           : Colors.transparent,
  //                     ),
  //                     child: Text(
  //                       'Post',
  //                       style: TextStyle(
  //                         color: selectedOption == 'Post'
  //                             ? Colors.white
  //                             : Colors.black,
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 GestureDetector(
  //                   onTap: () {
  //                     setState(() {
  //                       selectedOption = 'Story';
  //                     });
  //                   },
  //                   child: Container(
  //                     padding: const EdgeInsets.symmetric(
  //                       vertical: 12,
  //                       horizontal: 24,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.circular(10),
  //                       color: selectedOption == 'Story'
  //                           ? Colors.blueAccent
  //                           : Colors.transparent,
  //                     ),
  //                     child: Text(
  //                       'Story',
  //                       style: TextStyle(
  //                         color: selectedOption == 'Story'
  //                             ? Colors.white
  //                             : Colors.black,
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview with border radius
          if (selectedOption == 'Story')
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FutureBuilder(
                  future: cameraValue,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return CameraPreview(_cameraController);
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),

          // Post view remains the same
          if (selectedOption == 'Post')
            Column(
              children: [
                Image.asset('assets/images/shrutika.png'),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Text(
                        'Recents',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 5),
                      Transform.rotate(
                        angle: 1.5,
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          size: 15,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.camera)
                    ],
                  ),
                )
              ],
            ),

          // Camera capture button above the container
          if (selectedOption == 'Story')
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onLongPress: () async {
                    await _cameraController.startVideoRecording();
                    setState(() {
                      isRecording = true;
                    });
                  },
                  onLongPressUp: () async {
                    XFile videopath = await _cameraController.stopVideoRecording();
                    setState(() {
                      isRecording = false;
                    });
                    // Handle video recording here
                  },
                  onTap: () {
                    if (!isRecording) takePhoto(context);
                  },
                  child: isRecording
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
              ),
            ),

          // Bottom white container with Post/Story toggle and camera controls
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Image picker icon
                  IconButton(
                    icon: const Icon(
                      Icons.photo_library,
                      color: Colors.black,
                      size: 24,
                    ),
                    onPressed: () {
                      // Add image picker functionality here
                    },
                  ),
                  // Post button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOption = 'Post';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: selectedOption == 'Post'
                            ? Colors.blueAccent
                            : Colors.transparent,
                      ),
                      child: Text(
                        'Post',
                        style: TextStyle(
                          color: selectedOption == 'Post'
                              ? Colors.white
                              : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Story button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOption = 'Story';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: selectedOption == 'Story'
                            ? Colors.blueAccent
                            : Colors.transparent,
                      ),
                      child: Text(
                        'Story',
                        style: TextStyle(
                          color: selectedOption == 'Story'
                              ? Colors.white
                              : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Camera rotate icon
                  IconButton(
                    icon: Transform.rotate(
                      angle: transform,
                      child: const Icon(
                        Icons.flip_camera_ios,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                    onPressed: () async {
                      if (cameras.length < 2) return;
                      
                      setState(() {
                        isCameraFront = !isCameraFront;
                        transform = transform + pi;
                      });

                      int cameraPos = isCameraFront ? 0 : 1;
                      
                      if (_cameraController.value.isInitialized) {
                        await _cameraController.dispose();
                      }

                      _cameraController = CameraController(
                        cameras[cameraPos],
                        ResolutionPreset.high,
                        enableAudio: true,
                      );

                      cameraValue = _cameraController.initialize();
                      if (mounted) setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}