import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social/login_signup/screens/create_password_screen.dart';
import 'package:social/providers/user_provider.dart';
import 'package:social/widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    userNameController.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sign Up',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text('Enter your name and choose a username to continue.'),
              const SizedBox(height: 20),

              // Name Field
              CustomTextField(
                hintText: "Enter your full name",
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  if (value.length < 3) {
                    return 'Name must be at least 3 characters long';
                  }
                  return null;
                },
                prefixIcon: const Icon(Icons.person_outline),
              ),

              const SizedBox(height: 15),

              // Username Field
              CustomTextField(
                hintText: "Enter your username",
                controller: userNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username is required';
                  }
                  if (value.length < 4) {
                    return 'Username must be at least 4 characters long';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                    return 'Username can only contain letters, numbers, and underscores';
                  }
                  return null;
                },
                prefixIcon: const Icon(Icons.person),
              ),

              const SizedBox(height: 20),

              // Next Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Update name and username in Provider
                    final userProvider =
                        Provider.of<UserProvider>(context, listen: false);
                    userProvider.updateUser(
                      userProvider.user.copyWith(
                        name: nameController.text,
                        username: userNameController.text,
                      ),
                    );

                    // Navigate to the next screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePassowrdScreen(
                          name: nameController.text,
                          username: userNameController.text,
                        ),
                      ),
                    );
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
