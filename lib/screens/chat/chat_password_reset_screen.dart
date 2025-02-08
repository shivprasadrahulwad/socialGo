import 'package:flutter/material.dart';
import 'package:social/screens/services/chat_services.dart';
import 'package:social/widgets/custom_text_field.dart';

class ChatPasswordResetScreen extends StatefulWidget {
  final String chatId;

  const ChatPasswordResetScreen({
    Key? key,
    required this.chatId,
  }) : super(key: key);

  @override
  State<ChatPasswordResetScreen> createState() => _ChatPasswordResetScreenState();
}

class _ChatPasswordResetScreenState extends State<ChatPasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController reenterPasswordController = TextEditingController();
  final ChatServices _chatService = ChatServices();
  bool _isLoading = false;

  @override
  void dispose() {
    passwordController.dispose();
    reenterPasswordController.dispose();
    super.dispose();
  }

  Future<void> handleNext() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _chatService.updateChatPassword(
          context: context,
          chatId: widget.chatId,
          password: passwordController.text.trim(),
        );

        print('passwordController:  ${passwordController.text}');
        if (success && mounted) {
          Navigator.pop(context); // Return to previous screen
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Reset your password',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Enter your new password and confirm it',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'For security, your password must be at least 6 characters or more',
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: "Re-enter Password",
                  controller: reenterPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  prefixIcon: const Icon(Icons.lock),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: handleNext,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Set new password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}