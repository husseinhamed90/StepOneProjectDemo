import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:steponedemo/Helpers/Shared.dart';
import 'package:steponedemo/MainScreens/EditVisit.dart';
import 'package:steponedemo/VisitsCubit/VisitsCubit.dart';
class BuildVisitItem extends StatefulWidget {
  VisitsCubit visitsCubit;
  int index;
  String date;
  BuildVisitItem(this.visitsCubit,this.index,this.date);
  @override
  _BuildVisitItemState createState() => _BuildVisitItemState();
}

class _BuildVisitItemState extends State<BuildVisitItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => EditVisit(widget.visitsCubit.visits[widget.index]),));
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        height: 190,
        margin: EdgeInsets.only(right: 20,left: 20,top: 10,bottom: 10),
        width: MediaQuery.of(context).size.width,
        child: Container(
          margin: EdgeInsets.only(right: 10,left: 10,top: 10,bottom: 10),
          child: LayoutBuilder(
            builder: (context, constraints) => Column(

              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  child: AutoSizeText(widget.visitsCubit.visits[widget.index].visitOwner.clientname,style: TextStyle(
                      fontSize: 18
                  ),maxLines: 1,),
                  height: constraints.maxHeight*0.25,
                  width: double.infinity,
                ),
                buildRow(constraints.maxWidth*0.3, constraints.maxHeight*0.2, widget.visitsCubit, widget.index,  (widget.visitsCubit.visits[widget.index].hourofvisit=="غير محدد"&&widget.visitsCubit.visits[widget.index].typeofclock=="غير محدد")?"غير محدد":widget.visitsCubit.visits[widget.index].hourofvisit + " "+widget.visitsCubit.visits[widget.index].typeofclock,"معاد الزيارة : ",context,widget.date),
                buildRow(constraints.maxWidth*0.3, constraints.maxHeight*0.2, widget.visitsCubit, widget.index, widget.visitsCubit.visits[widget.index].reasonforvisit,"سبب الزيارة : ",context,widget.date),
                buildRow(constraints.maxWidth*0.3, constraints.maxHeight*0.2, widget.visitsCubit, widget.index, widget.visitsCubit.visits[widget.index].dateofnextvisit,"الزيارة القادمة : ",context,widget.date)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
