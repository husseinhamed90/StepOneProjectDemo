import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:steponedemo/Models/Order.dart';
import 'package:steponedemo/Models/Sellingpolicy.dart';
import 'package:steponedemo/OrdersCubit/ordersCubit.dart';
import 'package:steponedemo/SellingPolicyCubit/PolicyCubit.dart';
import 'package:steponedemo/SellingPolicyCubit/PolicyCubitState.dart';
// import 'package:stepone/SellingPolicyCubit/PolicyCubit.dart';
// import 'package:stepone/SellingPolicyCubit/PolicyCubitState.dart';
import 'package:steponedemo/Widgets/CircularProgressIndicatorForDownload.dart';
import 'package:steponedemo/Widgets/CircularProgressParForUpload.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import '../Helpers/Shared.dart';
import '../Helpers/Utilites.dart';
import 'package:toast/toast.dart';


class EditPolicy extends StatelessWidget {
  TextEditingController title = new TextEditingController();
  Sellingpolicy sellingpolicy;
  EditPolicy(this.sellingpolicy);

  @override
  Widget build(BuildContext context) {
    title.text=sellingpolicy.title;
    return BlocConsumer<PolicyCubit,PolicyCubitState>(
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
        else if(state is Policyloaded){
          Toast.show("تم الحفظ بنجاح", context, duration: 2, gravity: Toast.BOTTOM);
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        print(state);
        PolicyCubit policyCubit =PolicyCubit.get(context);
        if(state is Policyisuploading){
          return Scaffold(body: Container(child: Center(child: CircularProgressIndicator(),),));
        }
        else if(state is fileisuploadingprogress){
          return CircularProgressParForUpload(state.percentage);
        }
        return  Scaffold(
          appBar: PreferredSize(
            child: CustomAppbar("تعديل السياسة البيعية"),
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
                  policyCubit.PolicyImage == null ?
                  (policyCubit.PolicyDocumentFile!=null)?
                  InkWell(
                    onTap: () {
                      showbootomsheeat(context,policyCubit);
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
                            child: Text(policyCubit.PolicyDocumentFile.path.substring(49,policyCubit.PolicyDocumentFile.path.length),style: TextStyle(
                                fontSize: 20,fontWeight: FontWeight.bold
                            ),),
                          )
                        ],
                      ),
                    ),
                  ):
                  InkWell(
                    onTap: () {
                      showbootomsheeat(context,policyCubit);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          sellingpolicy.defauktphoto,
                          height: MediaQuery.of(context).size.height*0.2-30,
                        ),
                      ],
                    ),
                  ) :
                  InkWell(
                      onTap: () {
                        showbootomsheeat(context,policyCubit);
                      },
                      child: Image.file(policyCubit.PolicyImage)),
                ),
                gettextfeild((MediaQuery.of(context).size.width - 50),
                    "العنوان", 10, title),
              ],
            ),
          ),
          floatingActionButton:FloatingActionButton(
            onPressed: () async {
              sellingpolicy.title=title.text;
              policyCubit.editOrder(sellingpolicy,title);
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.blueAccent,
          ),
        );
      },
    );
  }

}