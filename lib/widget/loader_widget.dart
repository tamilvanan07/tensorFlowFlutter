import 'package:flutter/material.dart';

showLoaderDialog(BuildContext context, {String? title}){
  AlertDialog alert=AlertDialog(
    content:  Row(
      children: [
        const CircularProgressIndicator.adaptive(),
        Container(margin: const EdgeInsets.only(left: 7,),
            padding: const EdgeInsets.only(left: 7),
            child: Text( title ?? "Loading..." )),
      ],),
  );

  showDialog(barrierDismissible: false,
    context:context,

    builder:(BuildContext context){
      return alert;
    },
  );
}