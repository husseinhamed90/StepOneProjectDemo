import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:steponedemo/ClientsCubit/ClientsCubit.dart';
import 'package:steponedemo/ClientsCubit/ClientsCubitStates.dart';
import 'package:steponedemo/Helpers/Shared.dart';
import 'package:steponedemo/Models/Client.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import 'package:steponedemo/constants.dart';
import 'package:toast/toast.dart'as ss;
class AddnewClientPage  extends StatefulWidget {
  String userid;

  AddnewClientPage([this.userid]);

  @override
  _AddNewrepresentativeState createState() => _AddNewrepresentativeState();
}

class _AddNewrepresentativeState extends State<AddnewClientPage> {
  TextEditingController clientName=new TextEditingController();

  TextEditingController clientCode=new TextEditingController();

  TextEditingController clientPhone=new TextEditingController();

  TextEditingController clientAddress=new TextEditingController();

  TextEditingController clientArea=new TextEditingController();

  String typepneclint="غير محدد";
  //bool open=false;
  bool isvisible=false;
  FocusNode _focus = new FocusNode();

  void _onFocusChange(){
    debugPrint("Focus: "+_focus.hasFocus.toString());
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focus.addListener(_onFocusChange);
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
        else if(state is Clientaddedsuccefulltstate){
         Navigator.pop(context);
         ss.Toast.show("تم اضافة بيانات العميل بنجاج", context, duration: 2, gravity: ss.Toast.BOTTOM);
        //  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => newhomepage(state.representative.represtativename),));
        }
      },
      builder: (context, state) {
        ClientsCubit v =ClientsCubit.get(context);
        if(state is loaddatafromfirebase){
          return Scaffold(body: Container(child: Center(child: CircularProgressIndicator(),),));
        }
        else{
          return Scaffold(
            appBar: PreferredSize(
              child: CustomAppbar("اضافة عميل جديد"),
              preferredSize: Size.fromHeight(70),
            ),
            body: Container(
              child: ListView(
                children: [
                  returnphotoConatiner("insert","اضافة صورة الكارت (1)",context,v,v.image,imagetype: "first"),
                  returnphotoConatiner("insert","اضافة صورة الكارت (2)",context,v,v.image2,imagetype: "second"),
                  Row(
                    children: [
                      gettextfeild((MediaQuery.of(context).size.width-40)*0.6,"اسم العميل",10,clientName),
                      gettextfeild((MediaQuery.of(context).size.width-40)*0.4,"كود العميل ",10,clientCode),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    //color: Colors.red,
                    width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                              items: listOfTypes.map((String value) {
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
                                });
                              },
                            ),
                          ),
                        ],
                      )),
                  gettextfeild( ((MediaQuery.of(context).size.width-50)),"رقم التليفون",10,clientPhone),
                  gettextfeild( ((MediaQuery.of(context).size.width-50)),"العنوان",10,clientAddress),
                  gettextfeild( ((MediaQuery.of(context).size.width-50)),"المنطقة",10,clientArea),
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
                      child: Text("هل تريد حفظ بيانات العميل ؟"),
                    ),
                    actions: [
                      TextButton(onPressed: ()async{
                        Client client;
                        Navigator.pop(context);
                        client = Client(clientName.text,clientCode.text,clientPhone.text,clientAddress.text,clientArea.text,typepneclint);
                        await v.addClient(client, clientName, clientCode,
                            clientPhone,
                            clientAddress,clientArea,v.image,v.image2,ClientsCubit.get(context).userid);
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
  Container gettextfeild(double width, String lable, double mergin,TextEditingController controller) {
    return Container(
      width: width,

      margin: EdgeInsets.all(mergin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: width,
              height: 25,
              alignment: Alignment.centerRight,
              child: FittedBox(
                child: AutoSizeText(lable,
                  style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,),maxLines: 1,),
              )),
          TextFormField(

            controller: controller,
            maxLines: 1,

            decoration: InputDecoration(
                //contentPadding: EdgeInsets.fromLTRB(0,0,0,0),
                //labelText: lable,
                //hintText: lable,
                hintMaxLines: 1,
                labelStyle: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,),
                hintStyle: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,),
            ),
          ),
        ],
      ),
    );
  }
}

