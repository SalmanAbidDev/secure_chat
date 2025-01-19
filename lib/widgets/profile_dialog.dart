import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:secure_chat/home_screen/view_profile_screen.dart';
import 'package:secure_chat/models/chat_user.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});
  final ChatUser user;
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 1;
    final width = MediaQuery.sizeOf(context).width * 1;
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: SizedBox(
        width: width*.6,
        height: height*.35,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: height*.025),
              child: Align(
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(height*.15),
                  child: CachedNetworkImage(
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    imageUrl: user.image,
                    errorWidget: (context, url, error) => const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: width*.04,
              top: height*.012,
              width: width*.55,
              child: Text(
                  user.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: MaterialButton(
                shape: const CircleBorder(),
                  minWidth: 0,
                  padding: const EdgeInsets.all(0),
                  onPressed: (){
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => ViewProfileScreen(user: user),
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
                  },
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.black87,
                  size: 30,
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}
