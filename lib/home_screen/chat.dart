import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secure_chat/api_section/api.dart';
import 'package:secure_chat/helping_widgets/my_date_util.dart';
import 'package:secure_chat/home_screen/view_profile_screen.dart';
import 'package:secure_chat/models/chat_user.dart';
import 'package:secure_chat/models/message.dart';
import 'package:secure_chat/widgets/messages_card.dart';

class Chat extends StatefulWidget {
  final ChatUser user;
  const Chat({super.key, required this.user});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.black87));
  }

  List<Message> _list = [];
  final _textController = TextEditingController();
  bool _showEmoji = false, _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    //final width = MediaQuery.sizeOf(context).width;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: APIs.getAllMessages(widget.user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          // if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const Center(
                              child: SizedBox(),
                            );
                          // if data is loaded, then show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            _list = data
                                    ?.map((e) => Message.fromJson(e.data()))
                                    .toList() ??
                                [];
                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  reverse: true,
                                  padding: EdgeInsets.only(top: height * .01),
                                  itemCount: _list.length,
                                  itemBuilder: (context, index) {
                                    return MessagesCard(message: _list[index]);
                                  });
                            } else {
                              return const Center(
                                  child: Text(
                                'Say Hi! 👋 ',
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ));
                            }
                        }
                      }),
                ),
                if(_isUploading)
                const Align(
                  alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black87,
                      ),
                    )
                ),
                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        checkPlatformCompatibility: true,
                        emojiViewConfig: EmojiViewConfig(
                          backgroundColor: Colors.white,
                          columns: 8,
                          emojiSizeMax: 28 * (Platform.isIOS ? 1.20 : 1.0),
                        ),
                        swapCategoryAndBottomBar: false,
                        skinToneConfig: const SkinToneConfig(),
                        categoryViewConfig: const CategoryViewConfig(
                          initCategory: Category.SMILEYS,
                          backgroundColor: Colors.white,
                          backspaceColor: Colors.black87,
                          showBackspaceButton: true,
                          indicatorColor: Colors.black87,
                          iconColorSelected: Colors.black87,
                        ),
                        bottomActionBarConfig: const BottomActionBarConfig(
                            showBackspaceButton: false,
                            showSearchViewButton: false),
                        searchViewConfig: const SearchViewConfig(),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ViewProfileScreen(user: widget.user,),
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
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot){
          final data = snapshot.data?.docs;
          final list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
          return Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  width: 35,
                  height: 35,
                  fit: BoxFit.cover,
                  imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
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
              const SizedBox(
                width: 15,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.isNotEmpty ? list[0].name : widget.user.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    list.isNotEmpty ?
                    list[0].isOnline ? 'Online' :
                    MyDateUtil.getLastActiveTime(context: context, lastActive: list[0].lastActive) :
                    MyDateUtil.getLastActiveTime(context: context, lastActive: widget.user.lastActive),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 14),
                  )
                ],
              )
            ],
          );
        },
      )
    );
  }

  Widget _chatInput() {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: height * .01, horizontal: width * .03),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        FocusScope.of(context).unfocus();
                        _showEmoji = !_showEmoji;
                      });
                    },
                    icon: const Icon(
                      Icons.emoji_emotions_outlined,
                      color: Colors.black87,
                    ),
                  ),
                  Expanded(
                      child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: () {
                      if (_showEmoji) {
                        setState(() {
                          FocusScope.of(context).unfocus();
                          _showEmoji = !_showEmoji;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Type something...',
                      hintStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w300),
                      border: InputBorder.none,
                    ),
                  )),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final List<XFile> images = await picker.pickMultiImage(imageQuality: 70);
                      for (var i in images){
                        setState(() {
                          _isUploading = true;
                        });
                        await APIs.sendChatImage(widget.user,File(i.path));
                        setState(() {
                          _isUploading = false;
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.image_outlined,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                      if(image!=null){
                        log('Image Path: ${image.path} -- MineType: ${image.mimeType}');
                        setState(() {
                          _isUploading = true;
                        });
                        await APIs.sendChatImage(widget.user,File(image.path));
                        setState(() {
                          _isUploading = false;
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                if(_list.isEmpty){
                  APIs.sendFirstMessage(widget.user, _textController.text, Type.text);
                }else {
                  APIs.sendMessage(widget.user, _textController.text, Type.text);
                }
                _textController.text = '';
              }
            },
            shape: const CircleBorder(),
            minWidth: 0,
            color: Colors.black87,
            padding:
                const EdgeInsets.only(top: 7, bottom: 7, left: 7, right: 7),
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 28,
            ),
          )
        ],
      ),
    );
  }
}
