// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:social/login_signup/services/auth_services.dart';

import 'package:social/profile/profile_photo_screen.dart';
import 'package:social/widgets/custom_text_field.dart';

class EmailNumberScreen extends StatefulWidget {
  final String username;
  final String password;
  final String name;
  const EmailNumberScreen({
    Key? key,
    required this.username,
    required this.password,
    required this.name,
  }) : super(key: key);

  @override
  State<EmailNumberScreen> createState() => _EmailNumberScreenState();
}

class _EmailNumberScreenState extends State<EmailNumberScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();

  @override
  void dispose() {
    emailController.dispose();
    numberController.dispose();
    super.dispose();
  }

    void signUpUser() {
    authService.signUpUser(
      context: context,
      email: emailController.text,
      number: numberController.text,
      password: widget.password,
      username: widget.username,
      name:widget.name
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Enter your email and phone number'),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: "Email",
                controller: emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  // Email validation regex
                  const emailRegex =
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                  if (!RegExp(emailRegex).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                prefixIcon: const Icon(Icons.email),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: "Phone Number",
                controller: numberController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required';
                  }
                  if (value.length != 10) {
                    return 'Phone number must be 10 digits';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Phone number must be numeric';
                  }
                  return null;
                },
                prefixIcon: const Icon(Icons.phone),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Validate the form
                  if (_formKey.currentState?.validate() ?? false) {
                    signUpUser();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePhotoScreen(
                          username: widget.username,
                          password: widget.password,
                          email: emailController.text,
                          number: numberController.text,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Sign Up'),
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
      ),
    );
  }
}