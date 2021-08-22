import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:steponedemo/Helpers/Shared.dart';
import 'package:steponedemo/SellingPolicyCubit/PolicyCubit.dart';
import 'package:steponedemo/SellingPolicyCubit/PolicyCubitState.dart';
import 'package:steponedemo/Widgets/CircularProgressParForUpload.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import 'package:path/path.dart' as p;
import 'package:steponedemo/Models/Sellingpolicy.dart';
import 'package:toast/toast.dart';


class AddnewSellingPolicyss extends StatelessWidget {
  TextEditingController title = new TextEditingController();
  @override
  Widget build(BuildContext context) {
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
        else if(state is policesloaded){
          Toast.show("تم الحفظ بنجاح", context, duration: 2, gravity: Toast.BOTTOM);
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        PolicyCubit sellingPolicyCubit =PolicyCubit.get(context);
        if(state is Policyisuploading){
          return Scaffold(body: Container(child: Center(child: CircularProgressIndicator(),),));
        }
        else if(state is fileisuploadingprogress){

          return CircularProgressParForUpload(state.percentage);
        }
        return  Scaffold(
          appBar: PreferredSize(
            child: CustomAppbar("اضافة سياسة بيع جديدة"),
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
                  child: sellingPolicyCubit.PolicyImage == null ?
                    (sellingPolicyCubit.PolicyDocumentFile!=null)?

                      InkWell(
                        onTap: () {
                          showbootomsheeat(context,sellingPolicyCubit);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width - 20,
                          height: MediaQuery.of(context).size.height * 0.2,
                          child: Column(
                            children: [
                              SizedBox(height:  (MediaQuery.of(context).size.height * 0.2)*0.1,),
                              (lookupMimeType("${p.basename(sellingPolicyCubit.PolicyDocumentFile.path)}"+".${p.extension(sellingPolicyCubit.PolicyDocumentFile.path).split('.')[1]}").split("/")[0])=="application"?Image.asset('assets/document.png',height: (MediaQuery.of(context).size.height * 0.2)*0.5,):
                              Image.network('https://www.clipartmax.com/png/full/225-2253433_music-video-play-function-comments-video-gallery-icon-png.png',height: (MediaQuery.of(context).size.height * 0.2)*0.5,),
                              Spacer(),
                              Container(
                                alignment: Alignment.bottomCenter,
                                  height: (MediaQuery.of(context).size.height * 0.2)*0.4,
                                child: Text(sellingPolicyCubit.PolicyDocumentFile.path.substring(49,sellingPolicyCubit.PolicyDocumentFile.path.length),style: TextStyle(
                                  fontSize: 20,fontWeight: FontWeight.bold
                                ),),
                              )
                            ],
                          ),
                        ),
                      ):
                  InkWell(
                    onTap: () {
                      showbootomsheeat(context,sellingPolicyCubit);
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
                  )
                  : InkWell(
                      onTap: () {
                        showbootomsheeat(context,sellingPolicyCubit);
                      },
                      child: Image.file(sellingPolicyCubit.PolicyImage)),
                ),
                gettextfeild((MediaQuery.of(context).size.width - 50),
                    "العنوان", 10, title),
              ],
            ),
          ),
          floatingActionButton:FloatingActionButton(
            onPressed: () async {
              Sellingpolicy newpolicy=new Sellingpolicy(title.text);
              sellingPolicyCubit.addnewsellingpolicy(newpolicy,title);
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.blueAccent,
          ),
        );
      },
    );
  }
}