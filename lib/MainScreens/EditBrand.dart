
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:steponedemo/BrandsCubit/BrandsCubit.dart';
import 'package:steponedemo/BrandsCubit/BrandsStates.dart';
import 'package:steponedemo/Models/brand.dart';
import 'package:steponedemo/Widgets/CircularProgressParForUpload.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import '../Helpers/Utilites.dart';

import 'package:toast/toast.dart';

class EditBrand extends StatelessWidget {
  TextEditingController title = new TextEditingController();
  TextEditingController code = new TextEditingController();
  brand currentbrand;
  EditBrand(this.currentbrand);

  @override
  Widget build(BuildContext context) {

    title.text=currentbrand.brandname;
    code.text=currentbrand.prandcode;
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
        else if(state is brandupdated){
          //showToast();
          Toast.show("تم التعديل بنجاح", context, duration: 2, gravity: Toast.BOTTOM);
          Navigator.pop(context);
        }
      },

      builder: (context, state) {
        print(state);
        BrandsCubit v =BrandsCubit.get(context);
        if(state is loadingbrangforupdate){
          return Scaffold(body: Container(child: Center(child: CircularProgressIndicator(),),));
        }
        else if(state is fileisuploadingprogress){
          return CircularProgressParForUpload(state.percentage);
        }
        return  Scaffold(
          appBar: PreferredSize(
            child: CustomAppbar("تعديل البراند"),
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
                  child: v.image == null ?
                  InkWell(
                    onTap: () {
                      //showbootomsheeatWithoutDocument(context,v,"brand");
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Image.network(
                            "${currentbrand.path}",
                            height: (MediaQuery.of(context).size.height * 0.2),
                          ),
                        ),
                      ],
                    ),
                  ) :
                  InkWell(
                      onTap: () {
                       // showbootomsheeatWithoutDocument(context,v,"brand");
                      },
                      child: Image.file(v.image)),
                ),
                Container(
                    margin: EdgeInsets.all(10),
                    color: Colors.grey,
                    width: MediaQuery.of(context).size.width - 20,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: v.pdfFile == null ?
                    InkWell(
                      onTap: () {
                        showbootomsheeat(context,v);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Image.network(
                              "https://icons.iconarchive.com/icons/custom-icon-design/mono-general-2/256/document-icon.png",
                              height: (MediaQuery.of(context).size.height * 0.2-30),
                            ),
                          ),
                        ],
                      ),
                    ):
                    InkWell(
                      onTap: () {
                        print(v.pdfFile.path);
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
                    )
                ),
                Row(
                  children: [
                    gettextfeild((MediaQuery.of(context).size.width - 50),
                        "اسم البراند", 10, title),
                  ],
                ),
                Row(
                  children: [
                    gettextfeild((MediaQuery.of(context).size.width - 50),
                        "كود البراند", 10, code),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              v.EditBrand(title, code,currentbrand);
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.blueAccent,
          ),
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
  void showbootomsheeat(BuildContext context,BrandsCubit v){
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          // color: Colors.red,
          height: MediaQuery.of(context).size.height * 0.15,
          child: Center(
            child: InkWell(
                onTap: () async{
                  await v.uploadExcelFile();
                },
                child: Image.asset(
                  "assets/document.png", height: MediaQuery.of(context).size.height * 0.1,

                )),
          ),
        );
      },
    );
  }

}