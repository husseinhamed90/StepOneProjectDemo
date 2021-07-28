import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:steponedemo/Helpers/Utilites.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
import '../Models/file.dart';

class BuildItemContent extends StatelessWidget {
  BoxConstraints constraints;
  file currentitem;
  Widget widgetpage;
  dynamic cubit;
  BuildItemContent(this.constraints,this.currentitem,this.cubit,this.widgetpage);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      //height: 60,
      margin: EdgeInsets.all(7),
      width: MediaQuery.of(context).size.width,
      child: Row(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            //color: Colors.red,
            padding: EdgeInsets.only(right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 85*0.6-14,
                  alignment: Alignment.bottomRight,
                  width: (constraints.maxWidth - 14) * 0.85-10,
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: AutoSizeText(
                      currentitem.title,
                      style: TextStyle(fontSize: 16, color: Colors.red),
                      maxLines: 1,
                    ),
                  ),
                ),
                Container(
                  height: 85*0.4-14,
                  width: (constraints.maxWidth - 14) * 0.85-10,
                  margin: EdgeInsets.only(top: 15),
                  // width: (constraints.maxWidth-20)*0.2,
                  child: Text(
                    currentitem.date,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            //color: Colors.red,
          ),
          Container(
            width: (constraints.maxWidth - 14) * 0.15,
            child: (AppCubit.get(context).currentuser.usertype == "admin")
                ? Container(
              // width: ((constraints.maxWidth-20)*0.3)*0.3,
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 85*0.5,
                    child: IconButton(
                      icon:
                      Icon(Icons.delete, color: Colors.red, size: 25),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Container(
                                child: Text("هل تريد مسح المستخدم ؟"),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      deletItem(currentitem,cubit.collection,cubit);
                                      //orderscubit.deletOrders(currentitem);
                                    },
                                    child: Text("نعم")),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    child: Text("لا")),
                              ],
                            );
                          },
                        );
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  Container(
                    height: 85*0.5,
                    child: IconButton(
                      icon: Icon(Icons.edit, color: Colors.red, size: 25),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => widgetpage,
                            ));
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            )
                : Container(),
          )
        ],
      ),
      // child: Text("ddd"),
    );
  }
}
