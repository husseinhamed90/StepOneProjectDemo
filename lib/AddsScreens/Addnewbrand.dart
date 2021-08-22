import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:steponedemo/BrandsCubit/BrandsCubit.dart';
import 'package:steponedemo/BrandsCubit/BrandsStates.dart';
import 'package:steponedemo/Helpers/Shared.dart';
import 'package:steponedemo/Widgets/CircularProgressParForUpload.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import 'package:toast/toast.dart';

class AddnewBrand extends StatelessWidget {
  TextEditingController title = new TextEditingController();
  TextEditingController code = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BrandsCubit,BrandsStates>(
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
          else if(state is brandadded){
            //showToast();
            Toast.show("تم الحفظ بنجاح", context, duration: 2, gravity: Toast.BOTTOM);
            Navigator.pop(context);
          }
        },
      builder: (context, state) {
        BrandsCubit brandsCubit =BrandsCubit.get(context);
        if(state is loadingbrangforupdate){
            return Scaffold(body: Container(child: Center(child: CircularProgressIndicator(),),));
        }
        else if(state is fileisuploadingprogress){
          return CircularProgressParForUpload(state.percentage);
        }
        else if(state is numberoffilestillNow){
          return CircularProgressParForUpload(state.numberOfLoadedFiles);
        }
        else if(state is readingexcelFileInProgess){
          return Scaffold(body: Container(child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child: CircularProgressIndicator(),),
              Text("جاري تحميل المنتجات من الملف",style: TextStyle(
                  fontSize: 25
              ),)
            ],
          ),));

        }

        else if(state is orderproductsInProgress){
          return Scaffold(body: Container(child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child: CircularProgressIndicator(),),
              Text("جاري ترتيب المنتجات",style: TextStyle(
                fontSize: 25
              ),)
            ],
          ),));

        }
        return  Scaffold(
          appBar: PreferredSize(
            child: CustomAppbar("اضافة براند جديد"),
            preferredSize: Size.fromHeight(70),
          ),
          body: Container(
            child: ListView(
              children: [
                returnphotoConatiner("insert","اضافة صورة",context,brandsCubit,brandsCubit.image,imagetype: "brand"),
                Container(
                    margin: EdgeInsets.all(10),
                    color: Colors.grey,
                    width: MediaQuery.of(context).size.width - 20,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: brandsCubit.orderedFile == null ?
                    InkWell(
                      onTap: () {
                        showbootomsheeatWithDocumentOnly(context,brandsCubit,"orderedFile");
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Image.asset(
                              "assets/addimage.png",
                              height: (MediaQuery.of(context).size.height * 0.2)*0.5,
                            ),
                          ),
                          Container(
                            height: (MediaQuery.of(context).size.height * 0.2)*0.5,
                            child: Center(
                              child: AutoSizeText(
                                "اضافة ملف الاكواد".tr,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),maxLines: 1,
                              ),
                            ),
                          )
                        ],
                      ),
                    ):
                    InkWell(
                      onTap: () {
                        showbootomsheeatWithDocumentOnly(context,brandsCubit,"orderedFile");
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
                              child: Text(brandsCubit.orderedFile.path.substring(49,brandsCubit.orderedFile.path.length),style: TextStyle(
                                  fontSize: 20,fontWeight: FontWeight.bold
                              ),),
                            )
                          ],
                        ),
                      ),
                    )
                ),
                Container(
                    margin: EdgeInsets.all(10),
                    color: Colors.grey,
                    width: MediaQuery.of(context).size.width - 20,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: brandsCubit.pdfFile == null ?
                    InkWell(
                      onTap: () {
                        showbootomsheeatWithDocumentOnly(context,brandsCubit,"mainFile");
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Image.asset(
                              "assets/addimage.png",
                              height: (MediaQuery.of(context).size.height * 0.2)*0.5,
                            ),
                          ),
                          Container(
                            height: (MediaQuery.of(context).size.height * 0.2)*0.5,
                            child: Center(
                              child: AutoSizeText(
                                "اضافة ملف".tr,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),maxLines: 1,
                              ),
                            ),
                          )
                        ],
                      ),
                    ):
                    InkWell(
                      onTap: () {
                        showbootomsheeatWithDocumentOnly(context,brandsCubit,"mainFile");
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
                              child: Text(brandsCubit.pdfFile.path.substring(49,brandsCubit.pdfFile.path.length),style: TextStyle(
                                  fontSize: 20,fontWeight: FontWeight.bold
                              ),),
                            )
                          ],
                        ),
                      ),
                    )
                ),
                gettextfeild((MediaQuery.of(context).size.width - 50),
                    "اسم البراند", 10, title),
                gettextfeild((MediaQuery.of(context).size.width - 50),
                    "كود البراند", 10, code),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              brandsCubit.addNewBrand(title, code);
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.blueAccent,
          ),
        );
      },
    );
  }
}