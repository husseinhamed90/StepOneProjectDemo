import 'package:flutter/material.dart';
import 'package:steponedemo/Helpers/Shared.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
import 'package:steponedemo/Models/User.dart';
import 'package:steponedemo/NewsCubit/NewsCubit.dart';
import '../MainScreens/updateuser.dart';
class BuildUserItem extends StatefulWidget {
  user currentuser;
  AppCubit appCubit;
  int CurrentIndex;
  BuildUserItem(this.currentuser,this.appCubit,this.CurrentIndex);
  @override
  _BuildUserItemState createState() => _BuildUserItemState();
}

class _BuildUserItemState extends State<BuildUserItem> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => (widget.currentuser.id!=AppCubit.get(context).currentUser.id)?InkWell(
        onTap: () {
         // Navigator.push(context, MaterialPageRoute(builder: (context) => TestStream(widget.currentuser.id,widget.currentuser.name),));
        },
        child: Container(
          height: 50,
          width: constraints.maxWidth,
          margin: EdgeInsets.only(bottom: 10,top: 10,left: 10,right: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: (constraints.maxWidth-20)*0.5,
                        child: Text(
                          widget.currentuser.name,style: TextStyle(
                            fontSize: 22
                        ),),
                      ),
                      Container(
                        width: (constraints.maxWidth-20)*0.2,
                        child: Text(
                          widget.currentuser.password,style: TextStyle(
                            fontSize: 22
                        ),),),
                    ],
                  ),
                  Container(
                    height: 50,
                    width: (constraints.maxWidth-20)*0.3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Spacer(),
                        Container(
                          width: ((constraints.maxWidth-20)*0.3)*0.3,
                          child: IconButton(icon: Icon(Icons.delete,color: Colors.red,size: ((constraints.maxWidth-20)*0.3)*0.3-((((constraints.maxWidth-20)*0.3)*0.3)*0.3),), onPressed: (){

                            (widget.currentuser.usertype!="admin")?
                            showDialog(context: context, builder: (context) {
                              return AlertDialog(
                                content: Container(
                                  child: Text("هل تريد مسح المستخدم ؟"),
                                ),
                                actions: [
                                  TextButton(onPressed: (){
                                    Navigator.pop(context);
                                    widget.appCubit.deleteUser(widget.currentuser);
                                  }, child: Text("نعم")),
                                  TextButton(onPressed: () => Navigator.pop(context), child: Text("لا")),
                                ],
                              );
                            },):
                            getsnackbar(context, "هذا المستخدم ادمن");
                          },padding: EdgeInsets.zero,),
                        ),
                        Container(
                          width:  ((constraints.maxWidth-20)*0.3)*0.3,
                          child: IconButton(icon: Icon(Icons.edit,size: ((constraints.maxWidth-20)*0.3)*0.3-((((constraints.maxWidth-20)*0.3)*0.3)*0.3),), onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => updateuser(widget.currentuser,widget.CurrentIndex),));
                          },padding: EdgeInsets.zero,),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ):Container(),
    );
  }
}
