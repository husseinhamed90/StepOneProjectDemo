import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';
import 'package:steponedemo/Helpers/Shared.dart';
import 'package:steponedemo/Models/News.dart';
import 'package:steponedemo/NewsCubit/NewsCubit.dart';
import 'package:steponedemo/NewsCubit/NewsCubitState.dart';
import 'package:steponedemo/Widgets/CircularProgressParForUpload.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import 'package:path/path.dart' as p;
import 'package:toast/toast.dart';

class EditNew extends StatelessWidget {
  News currentNew;
  EditNew(this.currentNew);
  TextEditingController title = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    title.text=currentNew.title;
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
        NewsCubit newsCubit =NewsCubit.get(context);
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
                    child: newsCubit.NewImage == null ?
                    (newsCubit.pdfFile!=null)?
                    InkWell(
                      onTap: () {
                        showbootomsheeat(context,newsCubit);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width - 20,
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: Column(
                          children: [
                            SizedBox(height:  (MediaQuery.of(context).size.height * 0.2)*0.1,),
                            (lookupMimeType("${p.basename(newsCubit.pdfFile.path)}"+".${p.extension(newsCubit.pdfFile.path).split('.')[1]}").split("/")[0])=="application"?Image.asset('assets/document.png',height: (MediaQuery.of(context).size.height * 0.2)*0.5,):
                            Image.network('https://www.clipartmax.com/png/full/225-2253433_music-video-play-function-comments-video-gallery-icon-png.png',height: (MediaQuery.of(context).size.height * 0.2)*0.5,),
                          ],
                        ),
                      ),
                    ):
                    InkWell(
                      onTap: () {
                        showbootomsheeat(context,newsCubit);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            currentNew.defauktphoto,
                            height: MediaQuery.of(context).size.height*0.2-30,
                          ),
                        ],
                      ),
                    ) : InkWell(
                        onTap: () {
                          showbootomsheeat(context,newsCubit);
                        },
                        child: Image.file(newsCubit.NewImage)),
                  ),
                  gettextfeild((MediaQuery.of(context).size.width - 50), "العنوان", 10, title),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                currentNew.title=title.text;
                newsCubit.editNew(currentNew,title);
              },
              child: Icon(Icons.save),
              backgroundColor: Colors.blueAccent,
            )
        );
      },
    );
  }
}