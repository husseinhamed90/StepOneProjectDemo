import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:steponedemo/CatalogCubit/CatalogCubit.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
import 'package:steponedemo/MainScreens/EditCatalog.dart';
import 'package:steponedemo/Models/Catalog.dart';
class BuildCatalogItem extends StatefulWidget {
  CatalogCubit catalogCubit;
  BoxConstraints constraints;
  Catalog CurrentCatalog;
  BuildCatalogItem(this.catalogCubit,this.CurrentCatalog,this.constraints);

  @override
  _BuildCatalogItemState createState() => _BuildCatalogItemState();
}

class _BuildCatalogItemState extends State<BuildCatalogItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()async{
        widget.catalogCubit.loadfile(widget.CurrentCatalog.path,widget.CurrentCatalog.extention,widget.CurrentCatalog.title);
      },
      child: Container(
        height: 100,
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
              width: (widget.constraints.maxWidth),
              child: Row(
                children: [
                  //Spacer(),
                  //SizedBox(width: widget.constraints.maxWidth*0.03,),
                  Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: widget.constraints.maxWidth*0.55-14,
                                child: Text(
                                  widget.CurrentCatalog.date,style: TextStyle(
                                    fontSize: 14
                                ),),
                              ),
                              Container(width: widget.constraints.maxWidth*0.55-14,
                                child:  AutoSizeText(
                                widget.CurrentCatalog.title,style: TextStyle(
                                    fontSize: 16,color: Colors.red
                                ),maxLines: 1,),
                              ),
                            ],
                          ),
                          Container(
                            width: widget.constraints.maxWidth*0.3,
                            alignment: Alignment.topLeft,
                            child: Image.network(widget.CurrentCatalog.mainimagepath,height: 100,fit: BoxFit.fill,width: widget.constraints.maxWidth*0.3,),
                            height: 100,
                          ),
                          //SizedBox(width: widget.constraints.maxWidth*0.01,),
                          Container(
                            width: widget.constraints.maxWidth*0.15,
                            height: 100,
                            alignment: Alignment.topLeft,
                            child: ( (AppCubit.get(context).currentuser.usertype=="admin")?
                            Column(
                              children: [
                                IconButton(icon: Icon(Icons.delete,color: Colors.red,size: 30), onPressed: (){
                                  showDialog(context: context, builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        child: Text("هل تريد مسح المستخدم ؟"),
                                      ),
                                      actions: [
                                        TextButton(onPressed: (){
                                          Navigator.pop(context);
                                          widget.catalogCubit.deletecategory(widget.CurrentCatalog);
                                        }, child: Text("نعم")),
                                        TextButton(onPressed: () => Navigator.pop(context), child: Text("لا")),
                                      ],
                                    );
                                  },);
                                },padding: EdgeInsets.zero,),
                                Container(
                                  child: IconButton(icon: Icon(Icons.edit,color: Colors.red,size: 30), onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditCatalog(widget.CurrentCatalog),));
                                  },padding: EdgeInsets.zero,),
                                ),
                              ],
                            ):Container()),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        // child: Text("ddd"),
      ),
    );
  }
}
