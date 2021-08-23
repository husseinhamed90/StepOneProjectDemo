import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:steponedemo/BrandsCubit/BrandsCubit.dart';
import 'package:steponedemo/Helpers/Shared.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
import 'package:steponedemo/MainScreens/EditBrand.dart';
import 'package:steponedemo/Models/brand.dart';
import '../ListsScreens/products.dart';

class BuildBtandItem extends StatefulWidget {
  BrandsCubit brandsCubit;
  brand currentbrand;
  BoxConstraints constraints;
  BuildBtandItem(this.brandsCubit, this.currentbrand, this.constraints);
  @override
  _BuildBtandItemState createState() => _BuildBtandItemState();
}

class _BuildBtandItemState extends State<BuildBtandItem> {
  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () async {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) =>
                Products(widget.currentbrand),));
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.all(Radius.circular(10))),
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
                          Container(
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(right: 10),
                                  width: widget.constraints.maxWidth * 0.55 - 14,
                                  child: Text(
                                    widget.currentbrand.prandcode,
                                    style: TextStyle(fontSize: 14,color: Colors.blue),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(right: 10),
                                  width: widget.constraints.maxWidth * 0.55 - 14,
                                  child: AutoSizeText(
                                    widget.currentbrand.brandname,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.red),
                                    maxLines: 1,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(right: 10),
                                  width: widget.constraints.maxWidth * 0.55 - 14,
                                  child: AutoSizeText(widget.currentbrand.products.length.toString()+" " +"صنف",
                                    style: TextStyle(fontSize: 16),
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(

                            width: widget.constraints.maxWidth * 0.3,
                            alignment: Alignment.topLeft,
                            child: Image.network(
                              widget.currentbrand.path,
                              height: 100,
                              fit: BoxFit.fill,
                              width: widget.constraints.maxWidth * 0.3,
                            ),
                            height: 100,
                          ),
                          //SizedBox(width: widget.constraints.maxWidth*0.01,),
                          Container(
                            width: widget.constraints.maxWidth * 0.15,
                            height: 100,
                            alignment: Alignment.topLeft,
                            child: ((AppCubit.get(context)
                                .currentUser
                                .usertype ==
                                "admin")
                                ? Column(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Colors.red, size: 30),
                                  onPressed: () {
                                    ShowDialogbox(context,(){
                                      Navigator.pop(context);
                                      widget.brandsCubit
                                          .delectebrand(widget
                                          .currentbrand);
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                ),
                                Container(
                                  child: IconButton(
                                    icon: Icon(Icons.edit,
                                        color: Colors.red, size: 30),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditBrand(
                                                    widget.currentbrand),
                                          ));
                                    },
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            )
                                : Container()),
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
