import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secure_chat/api_section/api.dart';
import 'package:secure_chat/handle_login_state/login_screen.dart';
import 'package:secure_chat/helping_widgets/dialogs.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key,});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 1;
    final width = MediaQuery.sizeOf(context).width * 1;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: _formKey,
        child: Scaffold(
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
                  child: Stack(
                    children: [
                      _image != null ?
                      ClipRRect(
                        borderRadius: BorderRadius.circular(height*.1),
                        child: Image.file(
                          File(_image!),
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ) :
                      ClipRRect(
                        borderRadius: BorderRadius.circular(height*.1),
                        child: CachedNetworkImage(
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                          imageUrl: APIs.me.image.toString(),
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
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: width*.25,
                        child: MaterialButton(
                            onPressed: (){
                              _showBottomSheet();
                            },
                          color: Colors.black87,
                          shape: const CircleBorder(),
                          child: const Icon(
                              Icons.edit,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: height*.02,left: width*.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                          'Name: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),
                      ),
                      Text(
                          APIs.user.displayName.toString(),
                        style: const TextStyle(
                          fontSize: 18
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: height*.03,left: width*.03,right: width*.03),
                  child: TextFormField(
                    initialValue: APIs.user.displayName.toString(),
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                          Icons.person,
                        color: Colors.black87,
                      ),
                      hintText: 'Eg. Ahmed Raza',
                      label: const Text(
                          'Enter your name',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.black87,
                          width: 5,
                        )
                      )
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: height*.03,left: width*.03,right: width*.03),
                  child: TextFormField(
                    initialValue: APIs.me.about,
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.info_outline,
                          color: Colors.black87,
                        ),
                        hintText: 'Eg. I am feeling happy.',
                        label: const Text(
                          'Enter your about',
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.black87,
                              width: 5,
                            )
                        )
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: height*.02),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: height*.015,horizontal: width*.055),
                      backgroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                    ),
                      onPressed: (){
                        if(_formKey.currentState!.validate()){
                          _formKey.currentState!.save();
                          APIs.updateUserInfo().then((value) {
                            Dialogs.showSnackBar(context, 'Profile Updated Successfully!');
                          });
                        }
                      },
                      icon: const Icon(
                          Icons.edit_note_outlined,
                        color: Colors.white,
                      ),
                    label: const Text(
                        'Update',
                      style: TextStyle(
                        color: Colors.white
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height*.04,),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Colors.black87,
            onPressed: () async {
              Dialogs.showProgressBar(context);
              await APIs.updateActiveStatus(false);
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  Navigator.pop(context);
                  APIs.auth = FirebaseAuth.instance;
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()
                      )
                  );
                });
              });
              if(mounted) {
                Dialogs.showSnackBar(context, 'Logged out successfully');
              }
            },
            icon: const Icon(Icons.logout_outlined,color: Colors.white,),
            label: const Text(
                'Logout',
              style: TextStyle(
                color: Colors.white
              ),
            ),
          ),
        ),
      ),
    );
  }
  void _showBottomSheet(){
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
                Padding(
                  padding: EdgeInsets.only(top: height *.02,bottom: width*.03),
                  child: const Text(
                      'Choose your profile picture',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: height*.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(width*.3, height*.15)
                        ),
                          onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                              if(image!=null){
                                setState(() {
                                  _image = image.path;
                                });
                                log('Image Path: ${image.path} -- MineType: ${image.mimeType}');
                                APIs.updateProfilePicture(File(_image!));
                                if(mounted){
                                  Navigator.pop(context);
                                }
                              }
                          },
                          child: Image.asset('images/gallery.png')
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: const CircleBorder(),
                              fixedSize: Size(width*.3, height*.15)
                          ),
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                            if(image!=null){
                              log('Image Path: ${image.path} -- MineType: ${image.mimeType}');
                              setState(() {
                                _image = image.path;
                              });
                              APIs.updateProfilePicture(File(_image!));
                              if(mounted){
                                Navigator.pop(context);
                              }
                            }
                          },
                          child: Image.asset('images/camera.png')
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

}
