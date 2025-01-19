import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:secure_chat/helping_widgets/my_date_util.dart';
import 'package:secure_chat/models/chat_user.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({super.key, required this.user,});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 1;
    final width = MediaQuery.sizeOf(context).width * 1;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
          centerTitle: true,
          title: Text(
              widget.user.name,
            style: const TextStyle(
              color: Colors.white
            ),
          ),
          iconTheme: const IconThemeData(
            color: Colors.white, // Set the color of the back icon here
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Joined On: ',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              ),
            ),
            Flexible(
              child: Text(
                MyDateUtil.getLastMessageTime(context: context, time: widget.user.createdAt,showYear: true),
                style: const TextStyle(
                    fontSize: 18,
                  color: Colors.grey
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: width,),
              Padding(
                padding: EdgeInsets.only(top: height*.05),
                // user profile picture
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(height*.1),
                  child: CachedNetworkImage(
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    imageUrl: widget.user.image.toString(),
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
              Padding(
                padding: EdgeInsets.only(top: height*.03,left: width*.05),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email: ',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Flexible(
                      child: Text(
                        widget.user.email,
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: height*.02,left: width*.05),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About: ',
                      style: TextStyle(
                          fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Flexible(
                      child: Text(
                        widget.user.about,
                        style: const TextStyle(
                            fontSize: 18,
                          color: Colors.grey
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
