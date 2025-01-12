// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:social/login_signup/screens/email_number_screen.dart';
import 'package:social/widgets/custom_text_field.dart';

class CreatePassowrdScreen extends StatefulWidget {
  final String username;
  final String name;
  const CreatePassowrdScreen({
    Key? key,
    required this.username,
    required this.name,
  }) : super(key: key);

  @override
  State<CreatePassowrdScreen> createState() => _CreatePassowrdScreenState();
}

class _CreatePassowrdScreenState extends State<CreatePassowrdScreen> {
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
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
              const Text('Create a password'),
              const Text(
                  'For security, your password must be at least 6 characters or more'),
              CustomTextField(
                hintText: "Password",
                controller: passwordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
                prefixIcon: const Icon(Icons.lock),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Validate the form
                  if (_formKey.currentState?.validate() ?? false) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmailNumberScreen(
                          name:widget.name,
                          username: widget.username,
                          password: passwordController.text,
                        ),
                      ),
                    );
                  } else {
                    // Show validation errors if the form is invalid
                  }
                },
                child: const Text('Next'),
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
