import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import '../MainScreens/NewHome.dart';
import 'package:toast/toast.dart'as ss;

import 'package:steponedemo/Models/Representative.dart';
import 'package:steponedemo/RepresentatersCubit/RepresentaterCubit.dart';
import 'package:steponedemo/RepresentatersCubit/RepresentatersStates.dart';


class AddNewrepresentative  extends StatelessWidget {
  String userid;
  String username;
  AddNewrepresentative(this.username,[this.userid]);
  TextEditingController represtativename=new TextEditingController();

  TextEditingController represtativecode=new TextEditingController();

  TextEditingController represtativenphone=new TextEditingController();

  TextEditingController represtativetarget=new TextEditingController();

  TextEditingController represtativearea1=new TextEditingController();

  TextEditingController represtativearea2=new TextEditingController();

  TextEditingController represtativearea3=new TextEditingController();

  TextEditingController represtativearea4=new TextEditingController();

  TextEditingController represtativesupervisor=new TextEditingController();


  TextEditingController represtativemanager=new TextEditingController();

  TextEditingController companyname = new TextEditingController();

  TextEditingController companyaddress=new TextEditingController();

  TextEditingController companyphone=new TextEditingController();

  @override
  Widget build(BuildContext context) {

    if(AppCubit.get(context).currentrepresentative!=null){
      companyname.text= AppCubit.get(context).currentrepresentative.companyname;
      companyaddress.text= AppCubit.get(context).currentrepresentative.companyaddress;
      companyphone.text= AppCubit.get(context).currentrepresentative.companyphone;
      represtativename.text= AppCubit.get(context).currentrepresentative.represtativename;
      represtativecode.text= AppCubit.get(context).currentrepresentative.represtativecode;
      represtativenphone.text= AppCubit.get(context).currentrepresentative.represtativenphone;
      represtativetarget.text= AppCubit.get(context).currentrepresentative.represtativetarget;
      represtativearea1.text= AppCubit.get(context).currentrepresentative.represtativearea1;
      represtativearea2.text= AppCubit.get(context).currentrepresentative.represtativearea2;
      represtativearea3.text= AppCubit.get(context).currentrepresentative.represtativearea3;
      represtativearea4.text= AppCubit.get(context).currentrepresentative.represtativearea4;
      represtativesupervisor.text= AppCubit.get(context).currentrepresentative.represtativesupervisor;
      represtativemanager.text= AppCubit.get(context).currentrepresentative.represtativemanager;
    }
    return BlocConsumer<RepresentaterCubit,RepresentatersState>(
      listener: (context, state) {
        if(state is exitapp){
          SystemNavigator.pop();
        }
        else if(state is validrepresentativestate){
          final snackBar = SnackBar(
            content: Text("توجد حقول فارغية"),
            action: SnackBarAction(
              label: 'تراجع',
              onPressed: () {
                // Some code to undo the change.
              },
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        else if(state is representativeupdatedstate){
          ss.Toast.show("تم تعديل بيانات المستخدم بنجاج", context, duration: 2, gravity: ss.Toast.BOTTOM);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => newhomepage(represtativename.text),));
        }
      },
      builder: (context, state) {
        RepresentaterCubit v =RepresentaterCubit.get(context);
        if(state is loaddatafromfirebase){
          return Scaffold(body: Container(child: Center(child: CircularProgressIndicator(),),));
        }
        else if(state is updatestatuesloading){
          return Scaffold(
            body: Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        else{
          return Scaffold(
            appBar: PreferredSize(
              child: CustomAppbar("بيانات المندوب"),
              preferredSize: Size.fromHeight(70),
            ),
            body: Container(

              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text("لوجو الشركة",style: TextStyle(
                        fontSize: 20,fontWeight: FontWeight.bold
                    ),),
                    Stack(
                      children: [

                        Container(
                          margin: EdgeInsets.all(10),
                          color: Colors.grey,
                          width: MediaQuery.of(context).size.width-20,
                          height: MediaQuery.of(context).size.height*0.25,
                          child:
                          (AppCubit.get(context).currentUser.usertype=="admin")?
                          v.image == null
                              ? GestureDetector(onTap: () {
                            v.getImagefromSourse(ImageSource.camera,v.image);
                          },child:
                          Container(child: InkWell(onTap: () {
                            showModalBottomSheet(context: context, builder: (context) {
                              return Container(
                                height: MediaQuery.of(context).size.height*0.2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(onTap: () => v.getImagefromSourse(ImageSource.gallery,v.image),child: Image.asset("assets/gallery.png",height: 70,)),
                                    SizedBox(width: 20,),
                                    InkWell( onTap: () => v.getImagefromSourse(ImageSource.camera,v.image),child: Image.asset("assets/camera.png",height: 80,)),
                                  ],
                                ),
                              );
                            },);
                          },child: Image.network(AppCubit.get(context).currentrepresentative.path)))):Image.file(v.image):
                          Image.network(AppCubit.get(context).currentrepresentative.path),

                        ),
                      ],
                    ),
                    gettextfeild(MediaQuery.of(context).size.width-20,"اسم الشركة",10,companyname,context),
                    gettextfeild(MediaQuery.of(context).size.width-20,"عنوان الشركة",10,companyaddress,context),
                    gettextfeild(MediaQuery.of(context).size.width-20,"تليفون الشركة",10,companyphone,context),

                    Row(
                      children: [
                        gettextfeild((MediaQuery.of(context).size.width-60)*0.55,"اسم المندوب",10,represtativename,context),
                        gettextfeild((MediaQuery.of(context).size.width-20)*0.45,"كود المندوب",10,represtativecode,context),
                      ],
                    ),
                    gettextfeild( ((MediaQuery.of(context).size.width-30)),"رقم التليفون",0,represtativenphone,context),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          width: 130,
                          child: TextFormField(
                            controller: represtativetarget,
                            decoration: InputDecoration(
                              suffixText:"جنيها",
                              labelText:"التارجت" ,
                              hintText: "التارجت",
                              labelStyle: TextStyle(

                                  fontSize: 18,fontWeight: FontWeight.bold
                              ),
                              hintStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(

                      width: (MediaQuery.of(context).size.width-20),
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(

                            alignment: Alignment.topRight,
                            width: (MediaQuery.of(context).size.width-20)*0.25,
                            height: 100,
                            child: AutoSizeText("المناطق :",style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold
                            ),maxLines: 1,),
                          ),
                          Container(
                            width: (MediaQuery.of(context).size.width-20)*0.75,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    gettextfeild( ((MediaQuery.of(context).size.width-20)*0.75)*0.5-10,"المنطقة 1",0,represtativearea1,context),
                                    gettextfeild( ((MediaQuery.of(context).size.width-20)*0.75)*0.5-10,"المنطقة 2",10,represtativearea2,context),
                                  ],
                                ),
                                Row(
                                  children: [
                                    gettextfeild( ((MediaQuery.of(context).size.width-20)*0.75)*0.5-10,"المنطقة 3",0,represtativearea3,context),
                                    gettextfeild( ((MediaQuery.of(context).size.width-20)*0.75)*0.5-10,"المنطقة 4",10,represtativearea4,context),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    gettextfeild(MediaQuery.of(context).size.width-20,"اسم المشرف",10,represtativesupervisor,context),
                    gettextfeild(MediaQuery.of(context).size.width-20,"اسم مدير البيع",10,represtativemanager,context),
                    Container(
                      height: MediaQuery.of(context).size.height*0.1,
                      margin: EdgeInsets.only(right: 10,left: 10,bottom: 20),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showDialog(context: context, builder: (context) {
                  return AlertDialog(
                    content: Container(
                      child: Text("هل تريد حفظ بيانات المندوب ؟"),
                    ),
                    actions: [
                      TextButton(onPressed: (){
                        Navigator.pop(context);
                        if(AppCubit.get(context).currentrepresentative!=null){
                          Representative reprentative  = Representative(
                            companyname.text,
                            companyaddress.text,
                            companyphone.text,
                            represtativename.text,
                            represtativecode.text,
                            represtativenphone.text,
                            represtativetarget.text,
                            represtativesupervisor.text,
                            represtativemanager.text,
                            represtativearea1.text,
                            represtativearea2.text,
                            represtativearea3.text,
                            represtativearea4.text,
                            AppCubit.get(context).currentrepresentative.id,
                          );
                          v.updaterepresentaive(AppCubit.get(context),reprentative,AppCubit.get(context).currentUser);
                        }
                      }, child: Text("نعم")),
                      TextButton(onPressed: () => Navigator.pop(context), child: Text("لا")),
                    ],
                  );
                },);
              },
              child: Icon(Icons.save),
              backgroundColor: Colors.blueAccent,
            ),
          );
        }
      },
    );
  }
  Container gettextfeild(double width, String lable, double mergin,TextEditingController controller,BuildContext context) {
    return Container(
      width: width,
      margin: EdgeInsets.all(mergin),
      child:  TextFormField(
        maxLines: 1,
        controller: controller,
        enabled: (AppCubit.get(context).currentUser.usertype=="user"&&(controller==companyname||controller==companyaddress||controller==companyphone)?false:true),
        decoration: InputDecoration(
            labelText: lable,

            hintText: lable,
            hintMaxLines: 2,
            labelStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,),
            hintStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
      ),
    );
  }
}

