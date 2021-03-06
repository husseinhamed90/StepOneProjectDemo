import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:steponedemo/MainCubit/MainCubitStates.dart';
import '../AddsScreens/Addnewrepresentative.dart';
import 'package:steponedemo/ClientsCubit/ClientsCubit.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
import 'NewHome.dart';
import 'package:steponedemo/RepresentatersCubit/RepresentaterCubit.dart';
import '../Helpers/Shared.dart';

import '../AddsScreens/newrepresentativepage.dart';
class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with WidgetsBindingObserver{



  @override
    void initState() {
      // TODO: implement initState
      WidgetsBinding.instance.addObserver(this);
      super.initState();
      //username.text=widget.olduser.name;
      //password.text=widget.olduser.password;

    }
    static const channel = MethodChannel('service');
    OpenService() async {

      try {
        //await channel.invokeMethod('openservice',{"id":AppCubit.get(context).currentuser.location});
      } on PlatformException catch (ex) {
        print(ex.message);
      }
  }
  TextEditingController username = new TextEditingController();
  TextEditingController password = new TextEditingController();
  bool issecure=true;
  @override
  Widget build(BuildContext context) {
   // Scale.setup(context, Size(1280, 720));
       return Scaffold(
         appBar: PreferredSize(
           preferredSize: Size.fromHeight(70),
           child: Padding(
             padding: const EdgeInsets.only(top:10),
             child: AppBar(
               centerTitle: true,
               backgroundColor: Colors.white,
               elevation: 0,
               leading:  InkWell(onTap: () {
                 showdialogForExit(context);
               },child: Container(child: Image.asset("assets/exit.jpg",),margin: EdgeInsets.only(right: 10,top: 5),)
               ),
             ),
           ),
         ),
         body:  BlocConsumer<AppCubit,MainCubitState>(
           listener: (context, state) async {
             if(state is admindataiscame){
               OpenService();
               Navigator.push(context, MaterialPageRoute(builder: (context) => Newrepresentativepage(AppCubit.get(context).currentUser.id),));
             }
             else if(state is noadmindatafound){
               getsnackbar(context,"???? ???????? ???????????? ???????????? ?????? ????????");
             }
             else if(state is adminuser){
               Navigator.push(context, MaterialPageRoute(builder: (context) => AddNewrepresentative(AppCubit.get(context).currentUser.id),));

             }
             else if(state is userisnormaluserstatebutnotfirsttime){
               OpenService();
               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => newhomepage.constructorWithrepresentative(AppCubit.get(context).currentUser,AppCubit.get(context).currentrepresentative,AppCubit.get(context).currentUser.usertype),));
             }
             else if(state is invaliduser){
               getsnackbar(context,"???????? ???????????? ???? ?????? ???????????????? ?????? ????????");
             }
             else if(state is emptyfeildsstate){
               getsnackbar(context,"???????? ???????? ??????????");
             }
           },
           builder: (context, state) {
             AppCubit v =AppCubit.get(context);
             if(v.isLogging){
               return Container(
                 color: Colors.white,
                 child: Center(
                   child: CircularProgressIndicator(),
                 ),
               );
             }
             else{
               return Container(
                 color: Colors.white,
                 child: Center(
                   child: SingleChildScrollView(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: [
                         Container(
                           width: MediaQuery.of(context).size.width-50,
                           child: TextFormField(
                             controller: username,
                             decoration: InputDecoration(
                                 border: new OutlineInputBorder(
                                     borderSide: new BorderSide(color: Colors.teal)),
                                 labelText: "?????? ????????????????"

                             ),
                           ),
                         ),
                         SizedBox(height: 30,),
                         Container(
                           width: MediaQuery.of(context).size.width-50,
                           child: TextFormField(
                             obscureText: issecure,
                             controller: password,

                             decoration: InputDecoration(
                                 border: new OutlineInputBorder(
                                     borderSide: new BorderSide(color: Colors.teal)),
                                 labelText: "???????? ????????",
                                 suffixIcon: IconButton(
                                   onPressed: () {
                                     setState(() {
                                       issecure=!issecure;
                                     });
                                   },
                                   icon: (issecure)?Icon(Icons.visibility_off):Icon(Icons.visibility),
                                 )
                             ),
                           ),
                         ),
                         SizedBox(height: 30,),
                         TextButton(onPressed: (){
                           //v.getnumofnews(value);
                           v.loginwithusernameandpassword(username.text,password.text,RepresentaterCubit.get(context),ClientsCubit.get(context));
                         }, child: Text("?????????? ????????",style: TextStyle(
                             fontSize: 20
                         ),)),
                       ],
                     ),
                   ),
                 ),
               );
             }

           },
         )
       );
  }
}
