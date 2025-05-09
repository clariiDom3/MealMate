import 'package:flutter/material.dart';
import 'add/add.dart';
import 'home/home.dart';
import 'profile/profile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  int _currentPage = 1;

  List<Widget> pages = [AddPage(), HomePage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealMate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 77, 167, 240),
        ),
      ),
      home: Scaffold(
        body: Center(child: pages[_currentPage]),
        bottomNavigationBar: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 60,
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 77, 167, 240),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(icon: Icons.add, index: 0),
                  _navItem(
                    icon: Icons.home_outlined,
                    index: 1,
                  ), 
                  _navItem(icon: Icons.person_2_outlined, index: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({required IconData icon, required int index}) {
    bool isSelected = _currentPage == index;
    return GestureDetector(
      onTap: () => setState(() => _currentPage = index),
      child: Container(
        width: 50,
        height: 50, 
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.white : Colors.transparent,
        ),
        alignment: Alignment.center, 
        child: Icon(
          icon,
          color: isSelected ? Colors.black : Colors.white,
          size: 40,
        ),
      ),
    );
  }
}
