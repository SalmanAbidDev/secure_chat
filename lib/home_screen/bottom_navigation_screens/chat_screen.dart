import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:secure_chat/api_section/api.dart';
import 'package:secure_chat/helping_widgets/dialogs.dart';
import 'package:secure_chat/models/chat_user.dart';
import 'package:secure_chat/widgets/chat_user_card.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatUser> _list =[];
  final List<ChatUser> _searchList =[];
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    APIs.getSelfUserInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      if(APIs.auth.currentUser != null){
        if(message.toString().contains('resume')) APIs.updateActiveStatus(true);
        if(message.toString().contains('pause')) APIs.updateActiveStatus(false);
      }
      return Future.value(message);
    });
  }
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 1;
    final width = MediaQuery.sizeOf(context).width * 1;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if(_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          }else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: height * .01, left: width * .02, right: width * .02),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search user by name or email...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2
                      )
                    ),
                    prefixIcon: const Icon(Icons.search,size: 30),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  ),
                  onTap: (){
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  onChanged: (val) {
                    _searchList.clear();
                    for (var i in _list){
                      if (i.name.toLowerCase().contains(val.toLowerCase()) || i.email.toLowerCase().contains(val.toLowerCase())){
                        _searchList.add(i);
                      }
                      setState(() {
                        _searchList;
                      });
                    }
                  },
                ),
              ),

              Expanded(
                child: StreamBuilder(
                  stream: APIs.getMyUsersID(),
                  builder: (context, snapshot){
                    switch(snapshot.connectionState){
                    // if data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(child: CircularProgressIndicator(color: Colors.black87,),);
                    // if data is loaded, then show it
                      case ConnectionState.active:
                      case ConnectionState.done:
                      return StreamBuilder(
                          stream: APIs.getAllUsers(snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                          builder: (context, snapshot){

                            switch(snapshot.connectionState){
                            // if data is loading
                              case ConnectionState.waiting:
                              case ConnectionState.none:
                                //return const Center(child: CircularProgressIndicator(color: Colors.black87,),);
                            // if data is loaded, then show it
                              case ConnectionState.active:
                              case ConnectionState.done:
                                final data = snapshot.data?.docs;
                                _list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
                                if(_list.isNotEmpty){
                                  return ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      padding: EdgeInsets.only(top: height*.01),
                                      itemCount: _isSearching ? _searchList.length : _list.length,
                                      itemBuilder: (context, index){
                                        return ChatUserCard(user: _isSearching ? _searchList[index] : _list[index]);
                                        // return Text('Name: ${list[index]}');
                                      }
                                  );
                                }else{
                                  return const Center(
                                      child: Text(
                                        'Add some users to chat securely!',
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18
                                        ),
                                      )
                                  );
                                }
                            }
                          }
                      );
                    }
                  },
                )
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.black87,
              onPressed: () {
                _addChatUserDialog();
              },
            child: const Icon(Icons.add_comment_rounded,color: Colors.white,),
          ),
        ),
      ),
    );
  }
  void _addChatUserDialog(){
    String email = '';
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      title: const Row(
        children: [
          Icon(
            Icons.person_add,
            size: 28,
            color: Colors.black87,
          ),
          Text('  Add User')
        ],
      ),
      content: TextFormField(
        maxLines: null,
        onChanged: (value) => email = value,
        decoration: InputDecoration(
          hintText: 'Enter the email id',
          prefixIcon: const Icon(Icons.email_outlined,color: Colors.black87,),
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
            onPressed: () async {
              Navigator.pop(context);
              if(email.isNotEmpty) {
                await APIs.addChatUser(email).then((value) {
                  if(!value){
                   Dialogs.showSnackBar(context, "User doesn't exist");
                  }
                });
              }
            },
            color: Colors.black87,
            child: const Text(
              'Add',
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
