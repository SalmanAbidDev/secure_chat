import 'package:flutter/material.dart';

class Dialogs{
  static void showSnackBar(BuildContext context, String msg){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg,style: const TextStyle(color: Colors.white),),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating
        ),
    );
  }

  static void showProgressBar(BuildContext context){
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.black87,)));
  }
}