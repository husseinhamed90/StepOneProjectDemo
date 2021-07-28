import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:steponedemo/Models/Order.dart';
import 'package:steponedemo/OrdersCubit/ordersCubit.dart';
import 'package:steponedemo/OrdersCubit/ordersStates.dart';
// import 'package:stepone/SellingPolicyCubit/PolicyCubit.dart';
// import 'package:stepone/SellingPolicyCubit/PolicyCubitState.dart';
import 'package:steponedemo/Widgets/CircularProgressIndicatorForDownload.dart';
import 'package:steponedemo/Widgets/CircularProgressParForUpload.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import '../Helpers/Shared.dart';
import 'package:path/path.dart' as p;
import '../Helpers/Utilites.dart';
import 'package:toast/toast.dart';


class AddnewOrder extends StatelessWidget {
  TextEditingController title = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ordersCubit,ordersStates>(
      listener: (context, state) {
        if(state is emptystringfoundinpolicydata){
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
        else if(state is Ordersloaded){
          Toast.show("تم الحفظ بنجاح", context, duration: 2, gravity: Toast.BOTTOM);
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        ordersCubit v =ordersCubit.get(context);
        if(state is Policyisuploading){
          return Scaffold(body: Container(child: Center(child: CircularProgressIndicator(),),));
        }
        else if(state is fileisuploadingprogress){
          return CircularProgressParForUpload(state.percentage);
        }
        return  Scaffold(
          appBar: PreferredSize(
            child: CustomAppbar("اضافة جرد جديد"),
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
                  child: v.OrderImage == null ?
                  (v.OrderDocumentFile!=null)?

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
                          (lookupMimeType("${p.basename(v.OrderDocumentFile.path)}"+".${p.extension(v.OrderDocumentFile.path).split('.')[1]}").split("/")[0])=="application"?Image.asset('assets/document.png',height: (MediaQuery.of(context).size.height * 0.2)*0.5,):
                          Image.network('https://www.clipartmax.com/png/full/225-2253433_music-video-play-function-comments-video-gallery-icon-png.png',height: (MediaQuery.of(context).size.height * 0.2)*0.5,),

                          // SizedBox(height:  (MediaQuery.of(context).size.height * 0.2)*0.1,),
                          // Image.asset('assets/document.png',height: (MediaQuery.of(context).size.height * 0.2)*0.5,),
                          Spacer(),
                          Container(
                            alignment: Alignment.bottomCenter,
                            height: (MediaQuery.of(context).size.height * 0.2)*0.4,
                            child: Text(v.OrderDocumentFile.path.substring(49,v.OrderDocumentFile.path.length),style: TextStyle(
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
                          "اضافة صورة او ملف او فيديو".tr,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ) : InkWell(
                      onTap: () {
                        showbootomsheeat(context,v);
                      },
                      child: Image.file(v.OrderImage)),
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
          floatingActionButton:FloatingActionButton(
            onPressed: () async {
              Order neworder=new Order(title.text);
              v.addnewOrders(neworder,title);
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.blueAccent,
          ),
        );
      },
    );
  }

  void showbootomsheeat(BuildContext context,ordersCubit v){
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
                      v.getOrdersImagefromSource(ImageSource.gallery,v.OrderImage),
                  child: Image.asset(
                    "assets/gallery.png",
                    height: 70,
                  )),
              SizedBox(
                width: 20,
              ),
              InkWell(
                  onTap: () => v.getOrdersImagefromSource(ImageSource.camera,v.OrderImage),
                  child: Image.asset(
                    "assets/camera.png",
                    height: 80,
                  )),
              InkWell(
                  onTap: () async{
                    File file =await uploaddocument(v.OrderImage,v.OrderDocumentFile);
                    v.updateOrderimagestate(file);
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