import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:secure_chat/api_section/api.dart';
import 'package:secure_chat/helping_widgets/dialogs.dart';
import 'package:secure_chat/helping_widgets/my_date_util.dart';

import '../models/message.dart';

class MessagesCard extends StatefulWidget {
  const MessagesCard({super.key, required this.message});

  final Message message;
  @override
  State<MessagesCard> createState() => _MessagesCardState();
}

class _MessagesCardState extends State<MessagesCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _whiteMessage()
      : _blackMessage(),
    );
  }

  // receiver message
  Widget _blackMessage(){
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    if(widget.message.read.isEmpty){
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              border: Border.all(
                width: 2,
                color: Colors.black
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
                bottomRight: Radius.circular(25)
              )
            ),
            padding: EdgeInsets.all(widget.message.type == Type.image ? 10 : 14),
            margin: EdgeInsets.symmetric(horizontal: width*.03,vertical: height*.01),
            child: widget.message.type == Type.text ?
            Text(
              widget.message.msg,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ) :  ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: widget.message.msg,
                placeholder: (context, url) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    color: Colors.black87,
                  ),
                ),
                errorWidget: (context, url, error) => const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.image,
                    size: 70,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: width*.04),
          child: Text(
            MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black45
            ),
          ),
        ),
      ],
    );
  }

  // sender message
  Widget _whiteMessage(){
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: width*.04,),
            if(widget.message.read.isNotEmpty)
            const Icon(
                Icons.done_all,
              color: Colors.blue,
              size: 20,
            ),
            const SizedBox(width: 4,),
            Text(
              MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black45
              ),
            ),
          ],
        ),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white38,
                border: Border.all(
                    width: 2,
                    color: Colors.black
                ),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25)
                )
            ),
            padding: EdgeInsets.all(widget.message.type == Type.image ? 10 : 14),
            margin: EdgeInsets.symmetric(horizontal: width*.03,vertical: height*.01),
            child: widget.message.type == Type.text ?
            Text(
              widget.message.msg,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ) :  ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: widget.message.msg,
                placeholder: (context, url) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.image,
                    size: 70,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(bool isMe){
    final height = MediaQuery.sizeOf(context).height * 1;
    final width = MediaQuery.sizeOf(context).width * 1;
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(25),
                topLeft: Radius.circular(25)
            )
        ),
        builder: (_){
          return Container(
            decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    topLeft: Radius.circular(25)
                )
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                Container(
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: height*.015,horizontal: width*.3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                ),
                widget.message.type == Type.text ?
                _OptionItem(
                    icon: const Icon(
                      Icons.copy_outlined,
                      color: Colors.blue,
                    ),
                    name: 'Copy Text',
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: widget.message.msg)).then((value) {
                        Navigator.pop(context);
                        Dialogs.showSnackBar(context, 'Text Copied!');
                      });
                    }
                ) :
                _OptionItem(
                    icon: const Icon(
                      Icons.download,
                      color: Colors.blue,
                    ),
                    name: 'Save Image',
                    onTap: () async {
                      bool isSaved = await _saveImage();
                      if(isSaved){
                        if(mounted) {
                          Navigator.pop(context);
                          Dialogs.showSnackBar(
                              context, 'Image saved successfully');
                        }
                      }else{
                        if(mounted){
                        Navigator.pop(context);
                        Dialogs.showSnackBar(context, 'Failed to saved image');
                        }
                      }
                    }
                ),
                if(isMe)
                Divider(
                  endIndent: width*.07,
                  indent: width*.07,
                ),
                if(widget.message.type == Type.text && isMe)
                _OptionItem(
                    icon: const Icon(
                        Icons.edit,
                      color: Colors.white,
                    ),
                    name: 'Edit Message',
                    onTap: (){
                      Navigator.pop(context);
                      _showMessageUpdateDialog();
                    }
                ),
                if(isMe)
                _OptionItem(
                    icon: const Icon(
                      Icons.delete_forever_outlined,
                      color: Colors.red,
                    ),
                    name: 'Delete Message',
                    onTap: () async {
                      await APIs.deleteMessage(widget.message).then((value) {
                        Navigator.pop(context);
                      });
                    }
                ),
                Divider(
                  endIndent: width*.07,
                  indent: width*.07,
                ),
                _OptionItem(
                    icon: const Icon(
                      Icons.mark_chat_read,
                      color: Colors.blueAccent,
                    ),
                    name: 'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                    onTap: (){}
                ),
                _OptionItem(
                    icon: const Icon(
                      Icons.remove_red_eye_rounded,
                      color: Colors.greenAccent,
                    ),
                    name: widget.message.read.isEmpty ? 'Read At: Not seen yet' :
                    'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                    onTap: (){}
                )
              ],
            ),
          );
        });
  }

  Future<bool> _saveImage() async {
    try {
      var response = await Dio().get(
          widget.message.msg,
          options: Options(responseType: ResponseType.bytes));
      await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 60,
          name: "Secure Chat",
      );
      return true;
    } catch (e) {
      log('Error while saving image: $e');
      return false;
    }
  }

  void _showMessageUpdateDialog(){
    String updatedMsg = widget.message.msg;
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      title: const Row(
        children: [
          Icon(
              Icons.message,
            size: 28,
            color: Colors.black87,
          ),
          Text('  Update Message')
        ],
      ),
      content: TextFormField(
        initialValue: updatedMsg,
        maxLines: null,
        onChanged: (value) => updatedMsg =value,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
            ),
            padding: const EdgeInsets.all(15),
              onPressed: (){
                Navigator.pop(context);
              },
            color: Colors.black87,
            child: const Text(
                'Cancel',
              style: TextStyle(
                color: Colors.red
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: MaterialButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
            ),
            padding: const EdgeInsets.all(15),
            onPressed: (){
              Navigator.pop(context);
              APIs.updateMessage(widget.message, updatedMsg);
            },
            color: Colors.black87,
            child: const Text(
              'Update',
              style: TextStyle(
                  color: Colors.white
              ),
            ),
          ),
        ),
      ],
    ));
  }

}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem({required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(left: width *.06,top: height*.02,bottom: height*.02),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
                    '    $name',
                  style: const TextStyle(
                    color: Colors.white,
                    letterSpacing: 1
                  ),
                ),
            )
          ],
        ),
      ),
    );
  }
}
