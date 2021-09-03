import 'package:flutter/material.dart';
import 'package:grocery_checkout/history/history.dart';
import 'package:grocery_checkout/home.dart';
import 'package:grocery_checkout/profile/profile.dart';
import 'package:grocery_checkout/userdata.dart';

// import 'package:salesman/home/home.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    Home(),
    History(),
    Profile(),
  ];

  void initState() {
    super.initState();
  }

  void onTappedBar(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: ColorData.secondColor,
          onTap: onTappedBar,
          type: BottomNavigationBarType.fixed,
          currentIndex:
              _currentIndex, // this will be set when a new tab is tapped
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.home),
              label: 'Transaction',
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.swap_horiz),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            )
          ],
        ),
      ),
    );
  }
}
