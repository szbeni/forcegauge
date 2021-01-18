import 'package:flutter/material.dart';

class NavBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.bar_chart),
        label: 'MinMax',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.timer),
        label: 'Tabata',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.assessment),
        label: 'Taget',
      ),
    ]);
  }
}
