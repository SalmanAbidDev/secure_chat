import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:secure_chat/api_section/api.dart';
import 'package:secure_chat/helping_widgets/dialogs.dart';
import 'package:secure_chat/home_screen/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
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

  _handleGoogleButtonClick() {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      if (mounted) {
        Navigator.pop(context);
      }

      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if (await APIs.userExists()) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const curve = Curves.easeInOut;
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
        } else {
          await APIs.createUser().then((value) {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const curve = Curves.easeInOut;
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
          });
        }
      }
    });
  }


  Future<UserCredential?> _signInWithGoogle() async {
    try{
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    }catch (e) {
      log('\n_signInWithGoogle: $e');
      if(mounted){
        Dialogs.showSnackBar(context, 'Something went wrong, please try checking your internet connection');
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 1;
    final width = MediaQuery.sizeOf(context).width * 1;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        centerTitle: true,
        title: const Text(
          'Secure Chat',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: height*.1),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context,child){
                  double slidePosition = (1 - _controller.value) * 50;
                  double opacity = _controller.value;
                  return Opacity(
                      opacity: opacity,
                    child: Transform.translate(
                        offset: Offset(0, slidePosition),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'images/ic_launcher.png',  // Replace with your actual image path
                            width: 150,  // Adjust the size as needed
                            height: 150,
                          ),
                          SizedBox(height: height*.02,),
                          const Text(
                              'Welcome to Secure Chat!',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: height*.005,),
                          const Text(
                            'Login to get started.',
                            style: TextStyle(
                                fontSize: 22
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: height*.3,left: width*.15,right: width*.15),
            child: ElevatedButton(
                onPressed: (){
                  _handleGoogleButtonClick();
                },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                shadowColor: Colors.black,
                enableFeedback: true,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white10),
                )
              ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/google.png',  // Replace with your actual image path
                        width: 20,  // Adjust the size as needed
                        height: 20,
                      ),
                      SizedBox(width: width*.02,),
                      const Text(
                          'Login with ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const Text(
                          'Google',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
            ),
          )
        ],
      ),
    );
  }
}
