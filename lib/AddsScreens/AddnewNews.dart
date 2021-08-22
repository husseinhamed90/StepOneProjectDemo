import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:steponedemo/Helpers/Shared.dart';
import 'package:steponedemo/Models/News.dart';
import 'package:steponedemo/NewsCubit/NewsCubit.dart';
import 'package:steponedemo/NewsCubit/NewsCubitState.dart';
import 'package:steponedemo/Widgets/CircularProgressParForUpload.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import 'package:path/path.dart' as p;
import 'package:toast/toast.dart';

class AddnewNews extends StatelessWidget {
  TextEditingController title = new TextEditingController();
  @override
  Widget build(BuildContext context) {
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
              child: CustomAppbar("اضافة خبر جديد"),
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
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Column(
                          children: [
                            SizedBox(height:  (MediaQuery.of(context).size.height * 0.2)*0.1,),
                            (lookupMimeType("${p.basename(v.pdfFile.path)}"+".${p.extension(v.pdfFile.path).split('.')[1]}").split("/")[0])=="application"?Image.asset('assets/document.png',height: (MediaQuery.of(context).size.height * 0.2),):
                            Image.network('https://www.clipartmax.com/png/full/225-2253433_music-video-play-function-comments-video-gallery-icon-png.png',height: (MediaQuery.of(context).size.height * 0.2),),
                             //Image.asset('assets/document.png',height: MediaQuery.of(context).size.height * 0.25,),
                            Spacer(),
                            AutoSizeText(v.pdfFile.path.substring(49,v.pdfFile.path.length),style: TextStyle(
                                fontSize: 20,fontWeight: FontWeight.bold
                            ),maxLines: 1,)
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
                        child: Image.file(v.NewImage)),
                  ),
                  gettextfeild((MediaQuery.of(context).size.width - 50),
                      "العنوان", 10, title),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                News newpolicy=new News(title.text);
                v.addnews(newpolicy,title);
              },
              child: Icon(Icons.save),
              backgroundColor: Colors.blueAccent,
            )
        );
      },
    );
  }
}