import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:steponedemo/Models/News.dart';
import 'package:steponedemo/NewsCubit/NewsCubit.dart';
import 'package:steponedemo/NewsCubit/NewsCubitState.dart';
import 'package:steponedemo/Widgets/CircularProgressParForUpload.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import '../Helpers/Utilites.dart';
import 'package:path/path.dart' as p;
import 'package:toast/toast.dart';

class EditNew extends StatelessWidget {
  News currentnew;
  EditNew(this.currentnew);
  TextEditingController title = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    title.text=currentnew.title;
    return BlocConsumer<NewsCubit,NewsCubitState>(
      listener: (context, state) {
        if(state is emptystringfoundinNewdata){
          final snackBar = SnackBar(
            content: Text("غير مسموح بحقول فارغة"),
            action: SnackBarAction(
              label: 'تراجع',
              onPressed: () {
                // Some code to undo the change.
              },
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        else if(state is newsloaded){
          //showToast();
          Toast.show("تم الحفظ بنجاح", context, duration: 2, gravity: Toast.BOTTOM);
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        NewsCubit v =NewsCubit.get(context);
        if(state is newisuploading){
          return Scaffold(body: Container(child: Center(child: CircularProgressIndicator(),),));
        }
        else if(state is fileisuploadingprogress){
          return CircularProgressParForUpload(state.percentage);
        }
        return  Scaffold(
            appBar: PreferredSize(
              child: CustomAppbar("تعديل الخبر"),
              preferredSize: Size.fromHeight(70),
            ),
            body: Container(
              child: ListView(
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    color: Colors.grey,
                    width: MediaQuery.of(context).size.width - 20,
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: v.NewImage == null ?
                    (v.pdfFile!=null)?

                    InkWell(
                      onTap: () {
                        showbootomsheeat(context,v);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width - 20,
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: Column(
                          children: [

                            // Image.asset('assets/document.png',height: MediaQuery.of(context).size.height * 0.25,),
                            // Spacer(),
                            // Text(v.pdfFile.path.substring(49,v.pdfFile.path.length),style: TextStyle(
                            //     fontSize: 20,fontWeight: FontWeight.bold
                            // ),)
                            SizedBox(height:  (MediaQuery.of(context).size.height * 0.2)*0.1,),
                            (lookupMimeType("${p.basename(v.pdfFile.path)}"+".${p.extension(v.pdfFile.path).split('.')[1]}").split("/")[0])=="application"?Image.asset('assets/document.png',height: (MediaQuery.of(context).size.height * 0.2)*0.5,):
                            Image.network('https://www.clipartmax.com/png/full/225-2253433_music-video-play-function-comments-video-gallery-icon-png.png',height: (MediaQuery.of(context).size.height * 0.2)*0.5,),
                          ],
                        ),
                      ),
                    ):
                    InkWell(
                      onTap: () {
                        showbootomsheeat(context,v);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            currentnew.defauktphoto,
                            height: MediaQuery.of(context).size.height*0.2-30,
                          ),
                        ],
                      ),
                    )
                        : InkWell(
                        onTap: () {
                          showbootomsheeat(context,v);
                        },
                        child: Image.file(v.NewImage)),
                  ),
                  Row(
                    children: [
                      gettextfeild((MediaQuery.of(context).size.width - 50),
                          "العنوان", 10, title),
                    ],
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                currentnew.title=title.text;
                v.editNew(currentnew,title);
              },
              child: Icon(Icons.save),
              backgroundColor: Colors.blueAccent,
            )
        );
      },
    );
  }
  Container gettextfeild(double width, String lable, double mergin, TextEditingController controller) {
    return Container(
      width: width,
      margin: EdgeInsets.all(mergin),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            labelText: lable,
            hintText: lable,
            labelStyle: TextStyle(fontSize: 20),
            hintStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.normal)),
      ),
    );
  }
  void showbootomsheeat(BuildContext context,NewsCubit v){
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                  onTap: () =>
                      v.getImagefromSourse(ImageSource.gallery,v.NewImage),
                  child: Image.asset(
                    "assets/gallery.png",
                    height: 70,
                  )),
              SizedBox(
                width: 20,
              ),
              InkWell(
                  onTap: () => v.getImagefromSourse(ImageSource.camera,v.NewImage),
                  child: Image.asset(
                    "assets/camera.png",
                    height: 80,
                  )),
              InkWell(
                  onTap: () async{
                    File file =await uploaddocument(v.NewImage,v.pdfFile);
                    v.updateimagestate(file);
                  },
                  child: Image.asset(
                    "assets/document.png",
                    height: 80,
                  )),
            ],
          ),
        );
      },
    );
  }
}