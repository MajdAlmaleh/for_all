import 'package:flutter/material.dart';
import 'package:for_all/screens/chats.dart';
import 'package:for_all/screens/home_page.dart';
import 'package:for_all/screens/settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int screenIndex = 2;
  List<Widget> screens =const [HomePageScreen(),ChatsScreen(),SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'home',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline_sharp), label: 'chats'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'settings'),
          ],
          currentIndex: screenIndex,
          onTap: (value) {
            setState(() {
              screenIndex = value;
            });
          },
        ),
        body: screens[screenIndex]);
  }
}
