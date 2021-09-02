import 'package:flutter/material.dart';
import 'package:grocery_checkout/homescreen.dart';
import 'package:grocery_checkout/login.dart';

void main() {
  runApp(MyApp());
}

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Checkout',
//       theme: ThemeData(
//         primarySwatch: Colors.red,
//       ),
//       home: new MyLoginPage(),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checkout',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: new HomeScreen(),
    );
  }
}
