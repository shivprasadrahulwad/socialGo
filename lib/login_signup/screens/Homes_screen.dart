import 'package:flutter/material.dart';
import 'package:social/login_signup/screens/signin_screen.dart';
import 'package:social/login_signup/screens/signup_screen.dart';

class HomesScreen extends StatefulWidget {
    static const String routeName = '/homes';
  const HomesScreen({super.key});

  @override
  State<HomesScreen> createState() => _HomesScreenState();
}

class _HomesScreenState extends State<HomesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
        },
        child: Text('Signup Screen')),
    );
  }
}