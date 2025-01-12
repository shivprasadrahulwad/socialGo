// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social/screens/Home/login_screen.dart';

class ProfilePhotoScreen extends StatefulWidget {
  final String username;
  final String password;
  final String email;
  final String number;
  const ProfilePhotoScreen({
    Key? key,
    required this.username,
    required this.password,
    required this.email,
    required this.number,
  }) : super(key: key);

  @override
  State<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends State<ProfilePhotoScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isImagePicked = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isImagePicked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Skip',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add profile photo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Add profile photo to make your account more personal'),
            const SizedBox(height: 30),
            Spacer(),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 90,
                backgroundColor: Colors.grey[200],
                child: _image == null
                    ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                    : ClipOval(
                        child: Image.file(
                          _image!,
                          height: 180,
                          width: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
               'Shivprasad_rahulwad',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
                        Spacer(),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _isImagePicked
                  ? () {
                      Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                    }
                  : null, // Disable button if no photo is picked
              child: Text(_isImagePicked ? 'Next' : 'Add Photo'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
