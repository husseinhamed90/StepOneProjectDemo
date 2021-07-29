import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:steponedemo/Models/Order.dart';
import 'package:steponedemo/OrdersCubit/ordersCubit.dart';
import 'package:steponedemo/OrdersCubit/ordersStates.dart';
// import 'package:stepone/SellingPolicyCubit/PolicyCubit.dart';
// import 'package:stepone/SellingPolicyCubit/PolicyCubitState.dart';
import 'package:steponedemo/Widgets/CircularProgressIndicatorForDownload.dart';
import 'package:steponedemo/Widgets/CircularProgressParForUpload.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import '../Helpers/Shared.dart';
import '../Helpers/Utilites.dart';
import 'package:toast/toast.dart';


class EditOrder extends StatelessWidget {
  TextEditingController title = new TextEditingController();
  Order order;
  EditOrder(this.order);

  @override
  Widget build(BuildContext context) {
    title.text=order.title;
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
            child: CustomAppbar("تعديل الجرد"),
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
                  child:
                  v.OrderImage == null ?
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
                          Image.asset('assets/document.png',height: (MediaQuery.of(context).size.height * 0.2)*0.5,),
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
                        Image.network(
                          order.defauktphoto,
                          height: MediaQuery.of(context).size.height*0.2-30,
                        ),
                      ],
                    ),
                  ) :
                  InkWell(
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
              order.title=title.text;
              v.editOrder(order,title);
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.blueAccent,
          ),
        );
      },
    );
  }
}