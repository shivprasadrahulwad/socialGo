import 'package:flutter/material.dart';
import 'package:social/login_signup/services/auth_services.dart';
import 'package:social/widgets/custom_text_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController usernameEmailNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();

  @override
  void dispose() {
    usernameEmailNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signInUser() {
    print('🔵 Attempting to sign in...');
    print('👤 Username/Email/Number: ${usernameEmailNumberController.text}');
    print('🔑 Password: ${passwordController.text}');

    String email = '';
    String username = '';
    String number = '';

    String input = usernameEmailNumberController.text;

    // Determine if the input is email, username, or number
    if (input.contains('@') && RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(input)) {
      // It looks like a valid email
      email = input;
    } else if (RegExp(r'^[0-9]{10}$').hasMatch(input)) {
      // It looks like a valid phone number (exactly 10 digits)
      number = input;
    } else {
      // It's treated as a username
      username = input;
    }

    authService.signInUser(
      context: context,
      email: email.isNotEmpty ? email : '',
      username: username.isNotEmpty ? username : '',
      number: number.isNotEmpty ? number : '',
      password: passwordController.text,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sign In to Your Account',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: "Username, Email Address, or Mobile Number",
                controller: usernameEmailNumberController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  // Additional validation for email or number
                  // if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value) && !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                  //   return 'Please enter a valid email or 10-digit phone number';
                  // }
                  return null;
                },
                prefixIcon: const Icon(Icons.person),
                keyboardType: TextInputType.emailAddress, // Set to email keyboard by default
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: "Password",
                controller: passwordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
                prefixIcon: const Icon(Icons.lock),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    signInUser();
                  }
                },
                child: const Text('Sign In'),
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
