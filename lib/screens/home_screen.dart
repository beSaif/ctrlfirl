import 'package:ctrlfirl/screens/chat_screen.dart';
import 'package:ctrlfirl/screens/ocr_screen.dart';
import 'package:ctrlfirl/screens/previous_chats_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  final List<Widget> _screens = [
    const OCRScreen(),
    const ChatScreen(),
    const PreviousChatsScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _screens[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          showUnselectedLabels: false,
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Home',
                activeIcon: Icon(Icons.home_filled)),
            BottomNavigationBarItem(
                icon: Icon(Icons.message_outlined),
                label: 'Chat',
                activeIcon: Icon(Icons.message)),
            BottomNavigationBarItem(
                icon: Icon(Icons.data_object_outlined),
                label: 'Previous Chats',
                activeIcon: Icon(Icons.data_object)),
          ],
        ),
      ),
    );
  }
}
