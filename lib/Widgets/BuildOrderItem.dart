import 'package:flutter/material.dart';
import 'package:steponedemo/MainScreens/EditOrder.dart';
import 'package:steponedemo/Models/Order.dart';
import 'package:steponedemo/OrdersCubit/ordersCubit.dart';
import 'package:steponedemo/Widgets/BuildItemContent.dart';
class BuildOrderItem extends StatefulWidget {
  ordersCubit orderscubit;
  Order currentorder;
  BoxConstraints constraints;

  BuildOrderItem(this.orderscubit, this.currentorder,this.constraints);

  @override
  _BuildPolicyItemState createState() => _BuildPolicyItemState();
}

class _BuildPolicyItemState extends State<BuildOrderItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.orderscubit.loadfile(widget.currentorder.path,widget.currentorder.extention,widget.currentorder.title);
        //Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateClientPage(policyCubit.clients[index],),));
      },
      child:BuildItemContent(widget.constraints,widget.currentorder,widget.orderscubit,EditOrder(widget.currentorder)),
    );
  }
}
