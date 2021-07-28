import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:steponedemo/ClientsCubit/ClientsCubit.dart';
import 'package:steponedemo/ClientsCubit/ClientsCubitStates.dart';
import 'package:steponedemo/Helpers/Shared.dart';
import 'package:steponedemo/Models/Client.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import 'package:toast/toast.dart'as ss;

class UpdateClientPage  extends StatefulWidget {
  Client client;
  //String username;
  UpdateClientPage([this.client]);

  @override
  _AddNewrepresentativeState createState() => _AddNewrepresentativeState();
}

class _AddNewrepresentativeState extends State<UpdateClientPage> {
  TextEditingController Clientname=new TextEditingController();


  TextEditingController typepneclintcontroller =new TextEditingController();

  TextEditingController Clientcode=new TextEditingController();

  TextEditingController Clientphone=new TextEditingController();

  TextEditingController ClientAddress=new TextEditingController();

  TextEditingController ClientArea=new TextEditingController();

  List<String>listoftypees=['غير محدد','قطاعي','جملة','عقد','اخر'];

  String typepneclint="غير محدد";
  bool isother=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Clientname.text=widget.client.clientname;
    Clientcode.text=widget.client.clientcode;
    Clientphone.text=widget.client.phone;
    ClientAddress.text=widget.client.address;
    ClientArea.text=widget.client.area;
    if(widget.client.clinttype!='جملة' && widget.client.clinttype!='غير محدد' &&widget.client.clinttype!='قطاعي'&&widget.client.clinttype!='عقد'&&widget.client.clinttype!='اخر' ){

      typepneclint='اخر';
      typepneclintcontroller.text=widget.client.clinttype;
      isother=true;
    }
    else{
      typepneclint=widget.client.clinttype;
    }
  }

  @override
  Widget build(BuildContext context) {

    return BlocConsumer<ClientsCubit,ClientsCubitState>(
      listener: (context, state) {
        if(state is validclientstate){
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
        else if(state is clientupdatedstate){

          Navigator.pop(context);
          ss.Toast.show("تم تعديل بيانات العميل بنجاج", context, duration: 2, gravity: ss.Toast.BOTTOM);
          //  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => newhomepage(state.representative.represtativename),));
        }
      },
      builder: (context, state) {
        ClientsCubit v =ClientsCubit.get(context);
        print(state);
        if(state is updatestatuesloading){
          return Scaffold(body: Container(child: Center(child: CircularProgressIndicator(),),));
        }
        else{
          return Scaffold(
            appBar: PreferredSize(
              child: CustomAppbar("تعديل بيانات العميل"),
              preferredSize: Size.fromHeight(70),
            ),
            body: Container(
              child: ListView(
                children: [
                  returnphotoConatiner("edit","اضافة صورة الكارت (1)",context,v,v.image,"first",path: widget.client.path),
                  returnphotoConatiner("edit","اضافة صورة الكارت (2)",context,v,v.image2,"second",path: widget.client.path2),
                  Row(
                    children: [
                      gettextfeild((MediaQuery.of(context).size.width-60)*0.55,"اسم العميل",10,Clientname),
                      gettextfeild((MediaQuery.of(context).size.width-20)*0.45,"كود العميل",10,Clientcode),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 10,left: 10,bottom: 20),

                    width:  MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Text("نوع التعامل مع العميل",style: TextStyle(
                              fontSize: 18
                          ),),
                          alignment: Alignment.centerRight,
                        ),
                        Container(
                          height: 30,
                          alignment: Alignment.centerRight,
                          width: (MediaQuery.of(context).size.width),
                          child: DropdownButton<String>(
                            hint: Text(
                              "نوع التعامل مع العميل".tr,
                              maxLines: 1,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            value: typepneclint,
                            items: listoftypees.map((String value) {
                              return new DropdownMenuItem<String>(
                                value: value,
                                child: Container(
                                  height: 30,
                                  alignment: Alignment.centerRight,

                                  width: ((MediaQuery.of(context).size.width-50) * 0.5),
                                  child: FittedBox(
                                    child: new Text(value, maxLines: 1),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                typepneclint=value;
                                // if(typepneclint=="اخري"){
                                //   setState(() {
                                //     isvisible=true;
                                //   });
                                // }
                                // else{
                                //   isvisible=false;
                                // }
                                //listoftypees[0]=
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  gettextfeild( ((MediaQuery.of(context).size.width-50)),"رقم التليفون",10,Clientphone),
                  gettextfeild( ((MediaQuery.of(context).size.width-50)),"العنوان",10,ClientAddress),
                  gettextfeild( ((MediaQuery.of(context).size.width-50)),"المنطقة",10,ClientArea),
                  Container(
                    height: MediaQuery.of(context).size.height*0.1,
                    margin: EdgeInsets.only(right: 10,left: 10,bottom: 20),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showDialog(context: context, builder: (context) {
                  return AlertDialog(
                    content: Container(
                      child: Text("هل تريد حفظ تعديل البيانات ؟"),
                    ),
                    actions: [
                      TextButton(onPressed: (){
                        Navigator.pop(context);
                        Client client =Client(Clientname.text,Clientcode.text,Clientphone.text,ClientAddress.text,ClientArea.text,typepneclint);
                        v.updateClient(client, widget.client);
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
}

