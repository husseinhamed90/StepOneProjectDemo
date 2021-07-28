import 'package:flutter/material.dart';
import 'package:steponedemo/MainCubit/MainCubitStates.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import '../Helpers/Shared.dart';
import 'package:toast/toast.dart'as ss;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
import 'package:steponedemo/Models/User.dart';
class updateuser extends StatefulWidget {
  user olduser;
  int index;
  updateuser(this.olduser,this.index);

  @override
  _updateuserState createState() => _updateuserState();
}

class _updateuserState extends State<updateuser> with WidgetsBindingObserver{

  @override
  void initState() {
    super.initState();
    username.text=widget.olduser.name;
    password.text=widget.olduser.password;
  }
  bool issecure=true;
  TextEditingController username = new TextEditingController();
  TextEditingController password = new TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: PreferredSize(
        child: CustomAppbar("تعديل بيانات المستخدم"),
        preferredSize: Size.fromHeight(70),
      ),
      body: BlocConsumer<AppCubit,MainCubitState>(
        listener: (context, state) {
          if(state is emptyfeildregistersstate){
            getsnackbar(context,"توجد حقول فارغة");
          }
          else if(state is accountalreadyexists){
            getsnackbar(context,"هذا الاسم موجود مسبقا");
          }
          else if(state is weakpassword){
            getsnackbar(context,"كلمة المرور ضعيفة");
          }
          else if(state is userupdatedsuccfully){
            ss.Toast.show("تم تعديل بيانات المستخدم بنجاج", context, duration: 2, gravity: ss.Toast.BOTTOM);
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          AppCubit v =AppCubit.get(context);
          if(state is userupdateload){
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          else{
            return Container(
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    child: Center(
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
                                  labelText: "اسم المستخدم"
                              ),
                            ),
                          ),
                          SizedBox(height: 30,),
                          Container(
                            width: MediaQuery.of(context).size.width-50,
                            child: TextFormField(
                              obscureText: issecure,
                              //initialValue: olduser.password,
                              controller: password,

                              decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                      borderSide: new BorderSide(color: Colors.teal)),
                                  labelText: "كلمة السر",
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
                          TextButton(onPressed: ()async{
                            if(username.text==""||password.text==""){
                              getsnackbar(context, "توجد حقول فارغة");
                            }
                            else{
                              showDialog(context: context, builder: (context) {
                                return AlertDialog(
                                  content: Container(
                                    child: Text("هل تريد حفظ البيانات الجديدة ؟"),
                                  ),
                                  actions: [
                                    TextButton(onPressed: (){
                                      //user newuser =user(username.text,password.text,widget.olduser.usertype,widget.olduser.id,widget.olduser.isfirsttime);
                                      Navigator.pop(context);
                                      v.updateeuser(widget.olduser,username,password,widget.index);
                                    }, child: Text("نعم")),
                                    TextButton(onPressed: () => Navigator.pop(context), child: Text("لا")),
                                  ],
                                );
                              },);
                            }
                          }, child: Text("تعديل بيانات المستخدم",style: TextStyle(
                              fontSize: 20
                          ),)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

