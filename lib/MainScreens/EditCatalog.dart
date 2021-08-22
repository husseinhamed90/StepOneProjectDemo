import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:steponedemo/Models/Catalog.dart';
import 'package:steponedemo/Widgets/CircularProgressParForUpload.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import '../Helpers/Shared.dart';
import '../Helpers/Utilites.dart';
import 'package:steponedemo/CatalogCubit/CatalogCubit.dart';
import 'package:steponedemo/CatalogCubit/CatalogStates.dart';

import 'package:toast/toast.dart';

class EditCatalog extends StatelessWidget {
  Catalog catalog;
  EditCatalog(this.catalog);
  TextEditingController title = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    title.text=catalog.title;
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
        else if(state is dataiscome){
          //showToast();
          Toast.show("تم الحفظ بنجاح", context, duration: 2, gravity: Toast.BOTTOM);
          Navigator.pop(context);
          return null;
        }
      },
      builder: (context, state) {
        CatalogCubit catalogCubit =CatalogCubit.get(context);
        if(state is fileisuploading || state is Catalogisuploading){
          return Scaffold(body: Container(child: Center(child: CircularProgressIndicator(),),));
        }
        else if(state is fileisuploadingprogress){
          return CircularProgressParForUpload(state.percentage);
        }
        return  Scaffold(
          appBar: PreferredSize(
            child: CustomAppbar("تعديل كاتالوج"),
            preferredSize: Size.fromHeight(70),
          ),
          body: Container(
            child: ListView(
              children: [
                returnphotoConatiner("edit","تعديل الصورة",context,catalogCubit,catalogCubit.mainimage,path: catalog.mainimagepath,imagetype: "mainimage"),
                Container(
                  margin: EdgeInsets.all(10),
                  color: Colors.grey,
                  width: MediaQuery.of(context).size.width - 20,
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: catalogCubit.CatalogImage == null ?
                  (catalogCubit.pdfFile!=null)?

                  InkWell(
                    onTap: () {
                      showbootomsheeat(context,catalogCubit);
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
                            child: Text(catalogCubit.pdfFile.path.substring(49,catalogCubit.pdfFile.path.length),style: TextStyle(
                                fontSize: 20,fontWeight: FontWeight.bold
                            ),),
                          )
                        ],
                      ),
                    ),
                  ):
                  InkWell(
                    onTap: () {
                      showbootomsheeat(context,catalogCubit);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          catalog.defauktphoto,
                          height: MediaQuery.of(context).size.height*0.2-30,
                        ),
                      ],
                    ),
                  )
                      : InkWell(
                      onTap: () {
                        showbootomsheeat(context,catalogCubit);
                      },
                      child: Image.file(catalogCubit.CatalogImage)),
                ),
                gettextfeild((MediaQuery.of(context).size.width - 50),
                    "العنوان", 10, title),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              catalog.title=title.text;
              catalogCubit.editCatalog(catalog,title);
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.blueAccent,
          ),
        );
      },
    );
  }
}