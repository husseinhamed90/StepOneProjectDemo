import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:steponedemo/Models/Catalog.dart';
import 'package:steponedemo/Widgets/CircularProgressIndicatorForDownload.dart';
import 'package:steponedemo/Widgets/CircularProgressParForUpload.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import '../Helpers/Shared.dart';
import '../Helpers/Utilites.dart';
import 'package:steponedemo/CatalogCubit/CatalogCubit.dart';
import 'package:steponedemo/CatalogCubit/CatalogStates.dart';

import 'package:toast/toast.dart';

class AddnewCatalog extends StatelessWidget {
  TextEditingController title = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CatalogCubit,CatalogStates>(
      listener: (context, state) {
        if(state is emptystringfound){
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
        else if(state is upladingisfinished){
          //showToast();
          Toast.show("تم الحفظ بنجاح", context, duration: 2, gravity: Toast.BOTTOM);
          Navigator.pop(context);
          return null;
        }
      },
      builder: (context, state) {
        CatalogCubit v =CatalogCubit.get(context);
        if(state is fileisuploading || state is Catalogisuploading){
          return Scaffold(body: Container(child: Center(child: CircularProgressIndicator(),),));
        }
        else if(state is fileisuploadingprogress){
          return CircularProgressParForUpload(state.percentage);
        }
        return  Scaffold(
            appBar: PreferredSize(
              child: CustomAppbar("اضافة كاتالوج جديد"),
              preferredSize: Size.fromHeight(70),
            ),
            body: Container(
              child: ListView(
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    color: Colors.grey,
                    width: MediaQuery.of(context).size.width - 20,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: v.mainimage == null ?
                    InkWell(
                      onTap: () {
                        showbootomsheeatWithoutDocument(context,v);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/addimage.png",
                            height: 55,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "اضافة صورة".tr,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ) :
                    InkWell(
                        onTap: () {
                          showbootomsheeatWithoutDocument(context,v);
                        },
                        child: Image.file(v.mainimage)),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    color: Colors.grey,
                    width: MediaQuery.of(context).size.width - 20,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: v.CatalogImage == null ?
                    (v.pdfFile!=null)?

                    InkWell(
                      onTap: () {
                        showbootomsheeat(context,v);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width - 20,
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: Column(
                          children: [
                            SizedBox(height:  (MediaQuery.of(context).size.height * 0.2)*0.1,),
                            Image.asset('assets/document.png',height: (MediaQuery.of(context).size.height * 0.2)*0.6,),
                            Spacer(),
                            Container(
                              height: (MediaQuery.of(context).size.height * 0.2)*0.3,
                              alignment: Alignment.bottomCenter,
                              child: Text(v.pdfFile.path.substring(49,v.pdfFile.path.length),style: TextStyle(
                                  fontSize: 20,fontWeight: FontWeight.bold
                              ),),
                            )
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
                          Image.asset(
                            "assets/addimage.png",
                            height: 55,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "اضافة صورة او ملف".tr,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    )
                        : InkWell(
                        onTap: () {
                          showbootomsheeat(context,v);
                        },
                        child: Image.file(v.CatalogImage)),
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
                  Catalog catalog=new Catalog(title.text);
                  v.addCatalog(catalog,title);
                },
                child: Icon(Icons.save),
                backgroundColor: Colors.blueAccent,
              ),
        );
      },
    );
  }


  void showbootomsheeat(BuildContext context,CatalogCubit v){
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
                  onTap: () => v.getImagefromSourse(ImageSource.gallery,v.CatalogImage),
                  child: Image.asset(
                    "assets/gallery.png",
                    height: 70,
                  )),
              SizedBox(
                width: 20,
              ),
              InkWell(
                  onTap: () => v.getImagefromSourse(ImageSource.camera,v.CatalogImage),
                  child: Image.asset(
                    "assets/camera.png",
                    height: 80,
                  )),
              InkWell(
                  onTap: () async{
                    File file =await uploaddocument(v.CatalogImage,v.pdfFile);
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
  void showbootomsheeatWithoutDocument(BuildContext context,CatalogCubit v){
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
                      v.getMainImagefromSourse(ImageSource.gallery,v.mainimage),
                  child: Image.asset(
                    "assets/gallery.png",
                    height: 70,
                  )),
              SizedBox(
                width: 20,
              ),
              InkWell(
                  onTap: () => v.getMainImagefromSourse(ImageSource.camera,v.mainimage),
                  child: Image.asset(
                    "assets/camera.png",
                    height: 80,
                  )),
            ],
          ),
        );
      },
    );
  }

}