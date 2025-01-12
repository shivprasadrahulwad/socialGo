import 'package:flutter/material.dart';
import 'package:social/login_signup/screens/Homes_screen.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    // case SignInScreen.routeName:
    //   return MaterialPageRoute(
    //     settings: routeSettings,
    //     builder: (_) => const SignInScreen(),
    //   );

    // case SignUpScreen.routeName:
    //   return MaterialPageRoute(
    //     settings: routeSettings,
    //     builder: (_) => const SignUpScreen(),
    //   );

        case HomesScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => HomesScreen(),
      );  

    default:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Scaffold(
          body: Center(
            child: Text("Screen Dosen't Exist !!!"),
          ),
        ),
      );
  }
}

Route<dynamic> _errorRoute(String message) {
  return MaterialPageRoute(
    builder: (_) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Text('Error: $message'),
      ),
    ),
  );
}
