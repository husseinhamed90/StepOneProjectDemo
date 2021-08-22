import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:steponedemo/OrdersCubit/ordersCubit.dart';
import 'package:steponedemo/OrdersCubit/ordersStates.dart';
import 'package:steponedemo/Widgets/BuildOrderItem.dart';
import 'package:steponedemo/Widgets/CircularProgressIndicatorForDownload.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import '../AddsScreens/AddNewOrder.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
class Orderspage  extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ordersCubit,ordersStates>(
      listener: (context, state) {
      },
      builder: (context, state) {
        ordersCubit orderCubit =ordersCubit.get(context);
        if(state is loaddatafromfirebase){
          return Scaffold(
            body: Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        else if(state is downloadinprogressstate){
          return CircularProgressBarIndicatorDorDownload(state.percentage);
        }
        return Scaffold(
            appBar: PreferredSize(child: CustomAppbar("جرد") ,preferredSize: Size.fromHeight(70),),
            body:  RefreshIndicator(
              onRefresh: () async=> await ordersCubit.get(context).getOrders(),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child:Container(
                        color: Color(0xffe6e6e6),
                        height: MediaQuery.of(context).size.height*0.9,
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return LayoutBuilder(
                                builder: (context, constraints) => BuildOrderItem(orderCubit, orderCubit.orders[index],constraints)
                            );
                          },
                          itemCount: orderCubit.orders.length,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Color(0xffe6e6e6),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(bottom: 10,left: 20),
                    child: (AppCubit.get(context).currentUser.usertype=="admin")? FloatingActionButton(
                      key: Key("orderskey"),
                      child: Icon(Icons.add),
                      onPressed: () async{
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AddnewOrder(),));
                      },
                    ):Container(),
                  ),
                ],
              ),
            ),
        );
      },
    );
  }
}

