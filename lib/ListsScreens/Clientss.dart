import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import '../AddsScreens/AddClientPage.dart';
import 'package:steponedemo/ClientsCubit/ClientsCubit.dart';
import 'package:steponedemo/ClientsCubit/ClientsCubitStates.dart';
import '../MainScreens/UpdateClient.dart';
import 'package:toast/toast.dart'as ss;
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class Clintess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: PreferredSize(
        child: CustomAppbar("قائمة العملاء"),
        preferredSize: Size.fromHeight(70),
      ),
      body:  RefreshIndicator(
        onRefresh: () async=> await ClientsCubit.get(context).getClintess(),
        child: BlocConsumer<ClientsCubit,ClientsCubitState>(
            listener: (context, state) {
             if(state is Clinteletedsuccfully){
                ss.Toast.show("تم مسح العميل بنجاج", context, duration: 2, gravity: ss.Toast.BOTTOM);
              }
            },
            builder: (context, state) {
              ClientsCubit clientsCubit =ClientsCubit.get(context);
              return Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Color(0xffe6e6e6),
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return LayoutBuilder(
                            builder: (context, constraints) => InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateClientPage(clientsCubit.clients[index],),));
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
                                          clientsCubit.clients[index].clientname,style: TextStyle(
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
                                            child: Text(
                                              clientsCubit.clients[index].clientcode,style: TextStyle(
                                                fontSize: 22
                                            ),),),
                                          Spacer(),
                                          Container(
                                            child: IconButton(icon: Icon(Icons.delete,color: Colors.red,size: 30), onPressed: (){
                                              showDialog(context: context, builder: (context) {
                                                return AlertDialog(
                                                  content: Container(
                                                    child: Text("هل تريد مسح المستخدم ؟"),
                                                  ),
                                                  actions: [
                                                    TextButton(onPressed: (){
                                                      Navigator.pop(context);
                                                      clientsCubit.deleteclient(clientsCubit.clients[index]);
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
                              ),
                            ),
                          );
                        },
                        itemCount: clientsCubit.clients.length,
                      ),
                    ),
                  ),
                  Container(height: 70,),
                ],
              );
            }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          ClientsCubit.get(context).resetImagesToNull();
          Get.to(AddnewClientPage());
        },
      ),
    );
  }
}


