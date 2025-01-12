import 'package:flutter/material.dart';


String uri = 'http://192.168.2.140:5000';

// const String google_api_key ="AIzaSyBbzSbqNS28snAxOWn4EMP5j9HW0jLNMYs";
class GlobalVariables {
  // COLORS
  static const appBarGradient = LinearGradient( 
    colors: [
      Color.fromARGB(255, 29, 201, 192),
      Color.fromARGB(255, 125, 221, 216),
    ],
    stops: [0.5, 1.0],
  );

  static const primaryColor = Color.fromRGBO(255, 153, 0, 1);
  static const secondaryColor = Color.fromRGBO(255, 153, 0, 1);
  static const blueTextColor = Color(0xFF326BDC);
  static const lightBlueTextColor = Color.fromARGB(255, 115, 144, 189);
  static const savingColor = Color(0xFFDCE8FF);
  static const yelloColor = Color(0xFFfbcb44);
  static const lightGreen = Color(0xFFE9FFEE);
  static const greenColor = Color(0xFF328616);
  static const blueBackground = Color(0xFFdce8ff);
  static const backgroundColor = Color(0xFFF5F6FB);
  static const dividerColor = Color(0xFFE1E1E1);
  static const greyTextColor = Color.fromARGB(255, 125, 125, 125);
  static const Color greyBackgroundCOlor = Color(0xffebecee);
  static const greyBlueBackgroundColor=Color.fromARGB(255, 228, 232, 245);
  static const faintBlackColor =  Color.fromARGB(255, 70, 70, 70);
  
  static var selectedNavBarColor = Colors.cyan[800]!;
  static const unselectedNavBarColor = Colors.black87;
  static const greyBlueColor= Color(0xFF9197A5);
  static const cartFontWeight = FontWeight.bold;

}
