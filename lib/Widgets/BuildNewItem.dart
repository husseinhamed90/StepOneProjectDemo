import 'package:flutter/material.dart';
import 'package:steponedemo/MainScreens/EditNew.dart';
import 'package:steponedemo/Models/News.dart';
import 'package:steponedemo/NewsCubit/NewsCubit.dart';
import 'package:steponedemo/Widgets/BuildItemContent.dart';
class BuildNewItem extends StatefulWidget {
  NewsCubit newsCubit;
  News news;
  BoxConstraints constraints;
  BuildNewItem(this.newsCubit,this.news,this.constraints);
  @override
  _BuildNewItemState createState() => _BuildNewItemState();
}

class _BuildNewItemState extends State<BuildNewItem> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => InkWell(
        onTap: () {
          widget.newsCubit.loadfile(widget.news.path,widget.news.extention,widget.news.title);
        },
        child:BuildItemContent(widget.constraints,widget.news,widget.newsCubit,EditNew(widget.news)),

      ),
    );
  }
}
