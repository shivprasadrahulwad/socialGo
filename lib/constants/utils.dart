import 'package:flutter/material.dart';

class CustomSnackBar {
  static void show(BuildContext context, String text) {
    final snackBar = SnackBar(
      elevation: 6.0,
      backgroundColor: Colors.black87,
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 10.0,
      ),
      content: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Regular',
              color: Colors.white,
            ),
          ),
        ),
      ),
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.horizontal,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.1, // 10% from bottom
        right: 30.0,
        left: 30.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      duration: const Duration(seconds: 2),
    );

    // Remove current SnackBar if any
    // ScaffoldMessenger.of(context).clearSnackBars();
    
    // Show new SnackBar
    // ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
