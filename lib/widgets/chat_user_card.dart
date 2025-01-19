import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:secure_chat/api_section/api.dart';
import 'package:secure_chat/helping_widgets/my_date_util.dart';
import 'package:secure_chat/home_screen/chat.dart';
import 'package:secure_chat/models/message.dart';
import 'package:secure_chat/widgets/profile_dialog.dart';

import '../models/chat_user.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 1;
    final width = MediaQuery.sizeOf(context).width * 1;
    return Card(
      margin: EdgeInsets.only(
        top: height*.01,
        left: width*.01,
        right: width*.01
      ),
      elevation: 0,
      surfaceTintColor: Colors.white,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: Colors.black87
        ),
        borderRadius: BorderRadius.circular(10)
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => Chat(user: widget.user),
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
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if(list.isNotEmpty) _message = list[0];
            return ListTile(
                leading: InkWell(
                  onTap: (){
                    showDialog(context: context, builder: (_) => ProfileDialog(user: widget.user,));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                        backgroundColor: Colors.black87,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),

                // user name
                title: Text(
                  widget.user.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),

                // user last message
                subtitle: Text(
                  _message != null ?
                  _message!.type == Type.image ? '📸 Image' :
                  _message!.msg:
                  widget.user.about,
                  maxLines: 1,
                  style: const TextStyle(
                      color: Colors.grey
                  ),
                ),

                // user last message time
                trailing: _message == null ? null :
                _message!.read.isEmpty && _message!.fromId != APIs.user.uid ?
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: Colors.lightGreenAccent,
                      borderRadius: BorderRadius.circular(10)
                  ),
                ) :
                    Text(
                        MyDateUtil.getLastMessageTime(
                            context: context,
                            time: _message!.sent
                        )
                    )
            );
          },
        )
      ),
    );
  }
}
