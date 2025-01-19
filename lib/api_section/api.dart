import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:secure_chat/models/chat_user.dart';
import 'package:secure_chat/models/message.dart';

class APIs{
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for storing self information
  static late ChatUser me;

  // for accessing firebase messaging (Push Notifications)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    fMessaging.getToken().then((t){
      if(t != null){
        me.pushToken = t;
        log('Push Token: $t');
      }
    });
  }

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing cloud firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // to return current user
  static User get user => auth.currentUser!;

  // for checking if the user already exists
  static Future<bool> userExists () async {
   return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // for adding a chat user for our conversation
  static Future<bool> addChatUser (String email) async {
    final data = await firestore.collection('users').where('email', isEqualTo: email).get();
    if(data.docs.isNotEmpty && data.docs.first.id != user.uid){
      firestore.collection('users').doc(user.uid).collection('my_users').doc(data.docs.first.id).set({});
      return true;
    }else{
      return false;
    }
  }

  // for checking the details of current user
  static Future<void> getSelfUserInfo () async {
     await firestore.collection('users').doc(user.uid).get().then((user) async {
       if(user.exists){
         me = ChatUser.fromJson(user.data()!);
         await getFirebaseMessagingToken();
         APIs.updateActiveStatus(true);
       }else{
         await createUser().then((value) => getSelfUserInfo());
       }
     });
  }

  // for creating a new user
  static Future<void> createUser () async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        about: "Hey there, I am using Secure Chat",
        name: user.displayName.toString(),
        createdAt: time,
        lastActive: time,
        isOnline: false,
        id: user.uid,
        pushToken: '',
        email: user.email.toString(),
    );
    return (await firestore.collection('users').doc(user.uid).set(chatUser.toJson()));
  }

  // for getting all users from database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(List<String> userIds){
    return firestore.collection('users').where('id',whereIn: userIds)
        //.where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for getting id's of known users from database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersID(){
    return firestore.collection('users').doc(user.uid).collection('my_users').snapshots();
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(ChatUser chatUser) {
    return firestore.collection('users').where('id', isEqualTo: chatUser.id).snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active' : DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token' : me.pushToken,
    });
  }

  // for adding a user in my user when it is first user
  static Future<void> sendFirstMessage (ChatUser chatUser, String msg, Type type) async {
    await firestore.collection('users').doc(chatUser.id).collection('my_users').doc(user.uid).set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  // for updating user info
  static Future<void> updateUserInfo () async {
    await firestore.collection('users').doc(user.uid).update({
      'name' : me.name,
      'about' : me.about,
    });
  }

  // for updating profile picture
  static Future<void> updateProfilePicture (File file) async {
    final ext = file.path.split('.').last;
    log('Extension: $ext');
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
   await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((p0) {
     log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
   });
   me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image' : me.image,
    });
  }

  // for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode ? '${user.uid}_$id' : '${id}_${user.uid}';
  // for getting all message from database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user){
    return firestore.collection('chats/${getConversationID(user.id)}/messages/').orderBy('sent', descending: true).snapshots();
  }

  // for sending message
  static Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message message = Message(toId: chatUser.id, msg: msg, read: '', type: type, sent: time, fromId: user.uid);
    final ref = firestore.collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore.collection('chats/${getConversationID(message.fromId)}/messages/').doc(message.sent).update({'read':DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // get last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user) {
    return firestore.collection('chats/${getConversationID(user.id)}/messages/').orderBy('sent', descending: true).limit(1).snapshots();
  }

  // for sending image in chat
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    log('Extension: $ext');
    final ref = storage.ref().child('images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });
    final imageURL = await ref.getDownloadURL();
    await sendMessage(chatUser, imageURL, Type.image);
  }

  // for deleting message
  static Future<void> deleteMessage(Message message) async {
    await firestore.collection('chats/${getConversationID(message.toId)}/messages/').doc(message.sent).delete();
    if(message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  // for updating message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore.collection('chats/${getConversationID(message.toId)}/messages/').doc(message.sent).update({'msg': updatedMsg});
    
  }
}