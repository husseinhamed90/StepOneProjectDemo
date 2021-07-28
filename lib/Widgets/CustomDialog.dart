import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget CustomDialog(BuildContext context){
  showDialog(context: context, builder: (context){
    return AlertDialog(
      titlePadding: EdgeInsets.only(top: 10,right: 10),
      content: Container(
        height: 30,
        alignment: Alignment.center,
        child: Text("هذا الاختيار غير متاح لك",style: TextStyle(
            fontSize: 20
        ),),
      ),
      title: Container(
        alignment: Alignment.topRight,
        height: 35,
        child: InkWell(onTap: () {
          Navigator.pop(context);
        },child: Image.asset("assets/exit.jpg",)
        ),
      ),
    );
  },);
}
