import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
import 'package:steponedemo/MainScreens/tables.dart';
import 'package:steponedemo/RepresentatersCubit/RepresentaterCubit.dart';
import 'package:steponedemo/UserOrdersCubit/UserOrdersCubit.dart';
import 'package:steponedemo/UserOrdersCubit/UserOrdersCubitStates.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';


class ClientOrdersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserOrdersCubit.get(context).getOrdersOfCurrentUser(RepresentaterCubit.get(context).currentrepresentative.id);
    return Scaffold(

      appBar: PreferredSize(
        child: CustomAppbar("اوردراتي"),
        preferredSize: Size.fromHeight(70),
      ),
      body:  RefreshIndicator(
        onRefresh: () async=> await UserOrdersCubit.get(context).getOrdersOfCurrentUser(RepresentaterCubit.get(context).currentrepresentative.id),
        child: BlocConsumer<UserOrdersCubit,UserOrdersCubitStates>(
            listener: (context, state) {

            },
            builder: (context, state) {
              UserOrdersCubit v =UserOrdersCubit.get(context);
              if(state is deleteingorderState||state is LoadOrdersInProgress){
                return Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return Container(

                color: Color(0xffe6e6e6),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return LayoutBuilder(
                      builder: (context, constraints) => InkWell(
                        onTap: () async{
                         // print(v.myorders[index].OrderOwner.toJson());
                          await DisplayOrders(v.myorders[index],AppCubit.get(context).currentrepresentative);
                          //Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateClientPage(v.clients[index],),));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          //height: 100,
                          margin: EdgeInsets.all(7),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.bottomRight,
                                height: 50,
                                margin: EdgeInsets.only(right: 15),
                                width: constraints.maxWidth,
                                child: FittedBox(
                                  child: AutoSizeText(
                                    v.myorders[index].OrderOwner.clientname,style: TextStyle(
                                      fontSize: 22
                                  ),maxLines: 1,
                                  ),
                                ),
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(right: 15),
                                      // width: (constraints.maxWidth-20)*0.2,
                                      child: Text(
                                        v.myorders[index].dateodorder,style: TextStyle(
                                          fontSize: 22
                                      ),),),
                                    Spacer(),
                                    Container(
                                      // width: ((constraints.maxWidth-20)*0.3)*0.3,
                                      child: IconButton(icon: Icon(Icons.delete,color: Colors.red,size: 30), onPressed: (){
                                        showDialog(context: context, builder: (context) {
                                          return AlertDialog(
                                            content: Container(
                                              child: Text("هل تريد مسح المستخدم ؟"),
                                            ),
                                            actions: [
                                              TextButton(onPressed: (){
                                                Navigator.pop(context);
                                                v.deleteorderFromFireBase(v.myorders[index],RepresentaterCubit.get(context).currentrepresentative.id);
                                                //v.deleteclient(v.clients[index]);
                                              }, child: Text("نعم")),
                                              TextButton(onPressed: () => Navigator.pop(context), child: Text("لا")),
                                            ],
                                          );
                                        },);
                                      },padding: EdgeInsets.zero,),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // child: Text("ddd"),
                        ),
                      ),
                    );
                  },
                  itemCount: v.myorders.length,
                ),
              );
            }
        ),
      ),
    );
  }
}


