import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steponedemo/ClientsCubit/ClientsCubit.dart';
import 'package:steponedemo/Models/User.dart';

Widget getsnackbar(BuildContext context,String message){
  final snackBar = SnackBar(
    content: Text(message),
    action: SnackBarAction(
      label: 'تراجع',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Container gettextfeild(double width, String lable, double mergin,TextEditingController controller) {
  return Container(
    width: width,

    margin: EdgeInsets.all(mergin),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: width,
            height: 25,
            alignment: Alignment.centerRight,
            child: FittedBox(
              child: AutoSizeText(lable,
                style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,),maxLines: 1,),
            )),
        TextFormField(

          controller: controller,
          maxLines: 1,

          decoration: InputDecoration(
            //contentPadding: EdgeInsets.fromLTRB(0,0,0,0),
            //labelText: lable,
            //hintText: lable,
            hintMaxLines: 1,
            labelStyle: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,),
            hintStyle: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,),
          ),
        ),
      ],
    ),
  );
}

Container returnphotoConatiner(String typeofoperation,String text,BuildContext context,ClientsCubit v,File file,String numberofimage,{String path}){
  print("reload new data ");
  print(file);
  print(path);
  return  Container(
      margin: EdgeInsets.all(10),
      color: Colors.grey,
      width: (MediaQuery.of(context).size.width-20),
      height: MediaQuery.of(context).size.height*0.25,
      child:
      file== null
          ?  InkWell(
        onTap: () {
          showModalBottomSheet(context: context, builder: (context) {
            return Container(
              height: MediaQuery.of(context).size.height*0.2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(onTap: () => v.getImagefromSourse(ImageSource.gallery,file,numberofimage),child: Image.asset("assets/gallery.png",height: 70)),
                  SizedBox(width: 20,),
                  InkWell( onTap: () => v.getImagefromSourse(ImageSource.camera,file,numberofimage),child: Image.asset("assets/camera.png",height: 80)),
                ],
              ),
            );
          },);
        },
        child: (typeofoperation=="insert")?Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/addimage.png",height: 55,),
            SizedBox(
              height: 5,
            ),
            Text(text,style: TextStyle(
                fontSize: 20,fontWeight: FontWeight.bold
            ),)
          ],
        ):Image.network(path)) : InkWell(onTap: () {
        showModalBottomSheet(context: context, builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height*0.2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(onTap: () => v.getImagefromSourse(ImageSource.gallery,file,numberofimage),child: Image.asset("assets/gallery.png",height: 70)),
                SizedBox(width: 20,),
                InkWell( onTap: () => v.getImagefromSourse(ImageSource.camera,file,numberofimage),child: Image.asset("assets/camera.png",height: 80)),
              ],
            ),
          );
        },);
        },
          child: Image.file(file))

  );
}

Widget BuildRaw(BuildContext context,String label,TextEditingController controller){
  return Container(
    margin: EdgeInsets.all(10),
    width: MediaQuery.of(context).size.width-50,
    child: Row(
      children: [
        buildPercentageLable(label,((MediaQuery.of(context).size.width - 70))*0.4),
        gettextfeild(((MediaQuery.of(context).size.width - 70))*0.35,
            "", 10, controller),
        buildPercentageLable("%",((MediaQuery.of(context).size.width - 70))*0.25)
      ],
    ),
  );
}

Widget buildPercentageLable(String text,double width){
  return  Container(

    width: width,
    height: 70,child: FittedBox(
    child: AutoSizeText(text,style: TextStyle(
      fontSize: 20,
    ),maxLines: 1,),
  ),alignment: Alignment.center,);
}
void showdialogForExit(BuildContext context){
  showDialog(context: context, builder: (context) {
    return AlertDialog(
      content: Container(
        child: Text("هل تريد اغلاق التطبيق ؟"),
      ),
      actions: [
        TextButton(onPressed: () { SystemNavigator.pop();
        updateuserstatus('false',context);
        }, child: Text("نعم")),
        TextButton(onPressed: () => Navigator.pop(context), child: Text("لا")),
      ],
    );
  },);
}

void ShowDialogbox(BuildContext context,onPressed){
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Container(
          child: Text(
              "هل تريد مسح المستخدم ؟"),
        ),
        actions: [
          TextButton(
              onPressed: onPressed,
              child: Text("نعم")),
          TextButton(
              onPressed: () =>
                  Navigator.pop(
                      context),
              child: Text("لا")),
        ],
      );
    },
  );
}
List<user>users=[];
CollectionReference userscollection = FirebaseFirestore.instance.collection('Users');

Future<void> updateuserstatus(String newstatus,BuildContext context) async {
  users=[];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('id',"");
  userscollection.where("id",isEqualTo:ClientsCubit.get(context).userid).get().then((value) {
    userscollection.doc(value.docs.first.id).update({'isonline': newstatus}).then((value) async {
      await userscollection.get().then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          users.add(user.fromJson(doc.data()));
        });
      }).catchError((error){print(error);});
    });
  });
}