// import 'package:flutter/material.dart';
// import 'package:social/match/match_screen.dart';
// import 'package:social/screens/Home/home_screen.dart';
// import 'package:social/screens/account/profile_screen.dart';
// import 'package:social/screens/search/search_screen.dart';

// class BottomNavigationMenu extends StatefulWidget {
//   const BottomNavigationMenu({super.key});

//   @override
//   State<BottomNavigationMenu> createState() => _BottomNavigationMenuState();
// }

// class _BottomNavigationMenuState extends State<BottomNavigationMenu> {
//   int _selectedIndex = 0;

//   // Add your screens here
//   final List<Widget> _screens = [
//     const HomeScreen(chatmodels: [], sourchat:  ,),
//     const SearchScreen(),
//     const MatchScreen(),
//      const ProfileScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: Theme(
//          data: Theme.of(context).copyWith(
//           navigationBarTheme: NavigationBarThemeData(
//             backgroundColor: Colors.white, // Background of the NavigationBar
//             indicatorColor: Colors.teal, // Color of the selected indicator
//             labelTextStyle: MaterialStateProperty.all(
//               const TextStyle(
//                 color: Colors.teal,
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             iconTheme: MaterialStateProperty.resolveWith(
//               (states) {
//                 if (states.contains(MaterialState.selected)) {
//                   return const IconThemeData(color: Colors.teal);
//                 }
//                 return const IconThemeData(color: Colors.grey);
//               },
//             ),
//           ),
//          ),
//         child: NavigationBar(
//           height: 80,
//           elevation: 0,
//           selectedIndex: _selectedIndex,
//           onDestinationSelected: (index) {
//             setState(() {
//               _selectedIndex = index;
//             });
//           },
//           destinations: [
//             NavigationDestination(
//               icon: Image.asset(
//                 'assets/images/store-alt.png',
//                 width: 24,
//                 height: 24,
//               ),
//               label: 'Store',
//             ),
//             NavigationDestination(
//               icon: Image.asset(
//                 'assets/images/users.png',
//                 width: 24,
//                 height: 24,
//               ),
//               label: 'Orders',
//             ),
//             NavigationDestination(
//               icon: Image.asset(
//                 'assets/images/users.png',
//                 width: 24,
//                 height: 24,
//               ),
//               label: 'Analytics',
//             ),
//             NavigationDestination(
//               icon: Image.asset(
//                 'assets/images/settings.png',
//                 width: 24,
//                 height: 24,
//               ),
//               label: 'setting',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
