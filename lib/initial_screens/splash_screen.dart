import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:secure_chat/api_section/api.dart';
import 'package:secure_chat/handle_login_state/login_screen.dart';
import 'package:secure_chat/home_screen/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _opacity = 0.0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });

    Timer(const Duration(seconds: 4), ()
    {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.black87,
        )
      );
      if(APIs.auth.currentUser != null) {
        log('\nUser: ${APIs.auth.currentUser}');
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Define the animation curve
              const curve = Curves.easeInOut;

              // Slide transition
              final offsetAnimation = Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
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
      }
      else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Define the animation curve
              const curve = Curves.easeInOut;

              // Slide transition
              final offsetAnimation = Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
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
      }
    }
    );
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 1;
    final width = MediaQuery.sizeOf(context).width * 1;
    return Scaffold(
      body: Container(
        height: height*1,
        width: width*1,
        color: Colors.black87,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: height*.23),
              child: AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(seconds: 1), // Adjust the duration as needed
                child: Image.asset(
                  'images/image.png',
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: MediaQuery.of(context).size.height * 0.35,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: height* .01),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context,child) {
                  double slidePosition = (1 - _controller.value) * 50;
                  double opacity = _controller.value;
                  return Opacity(
                      opacity: opacity,
                    child: Transform.translate(
                        offset: Offset(0, slidePosition),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Secure ',
                            style: TextStyle(
                              letterSpacing: .3,
                              color:Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            'Chat',
                            style: TextStyle(
                              letterSpacing: .3,
                              color:Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: height*.2),
              child: const CircularProgressIndicator(
                color: Colors.white,

              ),
            )
          ],
        ),
      ),
    );
  }
}
