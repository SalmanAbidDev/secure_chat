import 'package:flutter/material.dart';
import 'package:secure_chat/about_secure_chat/about_secure_chat.dart';

import 'bottom_navigation_screens/chat_screen.dart';
import 'bottom_navigation_screens/settings_screen.dart';
import 'bottom_navigation_screens/status_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // This function will be called whenever the user taps on a bottom navigation item.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _screens = [
    const ChatScreen(),
    const StatusScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Image.asset(
                'images/image.png',  // Replace with your actual image path
                width: 30,  // Adjust the size as needed
                height: 30,
              ),
              const SizedBox(width: 10,),
              const Text(
                  'Secure Chat',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const AboutSecureChat(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      // Define the animation curve
                      const curve = Curves.easeInOut;

                      // Slide transition from bottom to top
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(0.0, 1.0), // Start from bottom
                        end: Offset.zero,              // End at top center
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: curve,
                        ),
                      );

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 700),
                  ),
                );
              },
              child: const Icon(
                  Icons.question_mark_outlined,
                size: 30,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
                Icons.chat,
              size: 30,
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(
                Icons.blur_circular_outlined,
              size: 30,
            ),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(
                Icons.settings_outlined,
              size: 30,
            ),
            label: 'Settings',
          ),
        ],
        selectedItemColor: Colors.black87,
      ),
    );
  }
}
