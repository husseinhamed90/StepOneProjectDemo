import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:steponedemo/Helpers/Utilites.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import '../MainScreens/NewHome.dart';
import 'package:steponedemo/RepresentatersCubit/RepresentaterCubit.dart';
import 'package:steponedemo/RepresentatersCubit/RepresentatersStates.dart';
import 'package:toast/toast.dart'as ss;
import 'package:steponedemo/Models/Representative.dart';

class Newrepresentativepage  extends StatelessWidget {
  String userid;
  String username;
  Newrepresentativepage(this.username,[this.userid]);
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
    if(AppCubit.get(context).currentadmindata!=null){
      companyname.text=AppCubit.get(context).currentadmindata.companyname;
      companyaddress.text=AppCubit.get(context).currentadmindata.companyaddress;
      companyphone.text=AppCubit.get(context).currentadmindata.CompanyPhone;
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
        else if(state is representativeaddedsuccefulltstate){
          ss.Toast.show("تم اضافة بيانات المندوب بنجاج", context, duration: 2, gravity: ss.Toast.BOTTOM);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => newhomepage(state.representative.represtativename),));
        }
      },
      builder: (context, state) {
        RepresentaterCubit v = RepresentaterCubit.get(context);
        if(state is loaddatafromfirebase || state is updatestatuesloading){
          return Scaffold(body: Container(child: Center(child: CircularProgressIndicator(),),));
        }
        else {


          return Scaffold(
              appBar: PreferredSize(
                child: CustomAppbar("اضافة بيانات المندوب"),
                preferredSize: Size.fromHeight(70),
              ),
              body: Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text("لوجو الشركة",style: TextStyle(
                          fontSize: 20,fontWeight: FontWeight.bold
                      ),),
                      Container(
                        margin: EdgeInsets.all(10),
                        color: Colors.grey,
                        width: MediaQuery.of(context).size.width-20,
                        height: MediaQuery.of(context).size.height*0.25,
                        child:(AppCubit.get(context).currentUser.usertype=="admin")?
                        v.image == null ? InkWell(
                          onTap: () {
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
                                          onTap: () {
                                            v.getImagefromSourse(
                                              ImageSource.gallery, v.image,);
                                          },
                                          child: Image.asset(
                                            "assets/gallery.png",
                                            height: 70,
                                          )),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      InkWell(
                                          onTap: () {
                                            v.getImagefromSourse(
                                              ImageSource.camera, v.image,);
                                          },
                                          child: Image.asset(
                                            "assets/camera.png",
                                            height: 80,
                                          )),
                                    ],
                                  ),
                                );
                              },
                            );
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
                                    "اضافة صورة",
                                    style: TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold),maxLines: 1,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ) : InkWell(
                            onTap: () {
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
                                            onTap: () {
                                              v.getImagefromSourse(
                                                ImageSource.gallery, v.image,);
                                            },
                                            child: Image.asset(
                                              "assets/gallery.png",
                                              height: 70,
                                            )),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              v.getImagefromSourse(
                                                ImageSource.camera, v.image,);
                                            },
                                            child: Image.asset(
                                              "assets/camera.png",
                                              height: 80,
                                            )),
                                      ],
                                    ),
                                  );
                                },
                              );
                              //showbootomsheeatWithoutDocument(context,v,"brand");
                            },
                            child: Image.file(v.image))
                            :Container(child: Image.network((AppCubit.get(context).currentadmindata==null)?"https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png":AppCubit.get(context).currentadmindata.logopath),)
                      ),
                      Row(
                        children: [
                          gettextfeild((MediaQuery.of(context).size.width-60)*0.55,"اسم المندوب",10,represtativename,context),
                          gettextfeild((MediaQuery.of(context).size.width-20)*0.45,"كود المندوب",10,represtativecode,context),
                        ],
                      ),
                      gettextfeild(MediaQuery.of(context).size.width-20,"اسم الشركة",10,companyname,context),
                      gettextfeild(MediaQuery.of(context).size.width-20,"عنوان الشركة",10,companyaddress,context),
                      gettextfeild(MediaQuery.of(context).size.width-20,"تليفون الشركة",10,companyphone,context),
                      gettextfeild( ((MediaQuery.of(context).size.width-50)),"رقم التليفون",10,represtativenphone,context),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 130,
                          padding: EdgeInsets.all(10),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            alignment: Alignment.topRight,
                            width: (MediaQuery.of(context).size.width-50)*0.25-25,
                            height: 100,
                            child: AutoSizeText("المناطق :",style: TextStyle(
                                fontSize: 20,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold
                            ),maxLines: 1,),
                          ),
                          Container(
                            width: (MediaQuery.of(context).size.width-50)*0.8,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    gettextfeild( ((MediaQuery.of(context).size.width-50)*0.73)*0.5,"المنطقة 1",0,represtativearea1,context),
                                    gettextfeild( ((MediaQuery.of(context).size.width-50)*0.73)*0.5,"المنطقة 2",10,represtativearea2,context),
                                  ],
                                ),
                                Row(
                                  children: [
                                    gettextfeild( ((MediaQuery.of(context).size.width-50)*0.73)*0.5,"المنطقة 3",0,represtativearea3,context),
                                    gettextfeild( ((MediaQuery.of(context).size.width-50)*0.73)*0.5,"المنطقة 4",10,represtativearea4,context),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        ],
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
                          );
                          v.addRepresentative(AppCubit.get(context),reprentative, represtativename, represtativecode, represtativenphone,
                              represtativetarget,represtativearea1,represtativearea2,represtativearea3,represtativearea4
                              ,represtativesupervisor,represtativemanager,v.image,AppCubit.get(context).currentUser.id,AppCubit.get(context).currentUser,AppCubit.get(context).currentadmindata);
                        }, child: Text("نعم")),
                        TextButton(onPressed: () => Navigator.pop(context), child: Text("لا")),
                      ],
                    );
                  },);
                },
                child: Icon(Icons.save),
                backgroundColor: Colors.blueAccent,
              )
          );
        }
      },
    );
  }
  Container gettextfeild(double width, String lable, double mergin,TextEditingController controller,BuildContext context) {
    return Container(
        width: width,
        margin: EdgeInsets.all(mergin),
        child: TextFormField(
          controller: controller,
          enabled: (AppCubit.get(context).currentUser.usertype=="user"&&(controller==companyname||controller==companyaddress||controller==companyphone)?false:true),
          decoration: InputDecoration(
              labelText: lable,
              hintText: lable,
              hintMaxLines: 1,
              labelStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
              hintStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
        )
    );
  }

}

