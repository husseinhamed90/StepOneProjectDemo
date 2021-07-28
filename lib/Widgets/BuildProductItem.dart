import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:steponedemo/BrandsCubit/BrandsCubit.dart';
import 'package:steponedemo/Helpers/Shared.dart';
import 'package:steponedemo/Helpers/Utilites.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
import 'package:steponedemo/Models/Client.dart';
import 'package:steponedemo/Models/TRProdct.dart';
import 'package:steponedemo/Models/brand.dart';
import '../MainScreens/shoppingCartPage.dart';

Widget BuildProductItem(TrProduct trProduct,
    BrandsCubit brandsCubit,
    int currentindex,
    brand Currentbrand,BuildContext context){
  return Container(
    height: 130,
    decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.all(Radius.circular(10))),
    margin: EdgeInsets.only(bottom: 10, top: 10),
    child: Row(
      children: [
        Container(
          //  alignment: Alignment.center,
          height: 160,
          width: (MediaQuery.of(context).size.width - 20) * 0.6,
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BuildText(constraints.maxHeight*0.2,trProduct.Item,(MediaQuery.of(context).size.width - 20) * 0.6),
                BuildText(constraints.maxHeight*0.2,  trProduct.Retail +
                    " جنيها",(MediaQuery.of(context).size.width - 20) * 0.6,color: Colors.red),
                BuildText(constraints.maxHeight*0.2, trProduct.Q + " قطعة",(MediaQuery.of(context).size.width - 20) * 0.6,color: Colors.blue),
                BuildText(constraints.maxHeight*0.2,trProduct.Description,(MediaQuery.of(context).size.width - 20) * 0.6),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            if(AppCubit.get(context).currentuser.usertype=="admin"){
              showbootomsheeatWithoutDocument(
                  context, brandsCubit, "product",
                  currentbrand: Currentbrand,
                  index: currentindex);
            }
          },
          child: Container(
              height: 130,
              padding: EdgeInsets.only(top: 5),
              alignment: Alignment.topCenter,
              width: (MediaQuery.of(context).size.width - 20) * 0.3,
              child: Image.network("${trProduct.path}",height: 115,)),
        ),
        Container(
          width: (MediaQuery.of(context).size.width - 20) * 0.1,
          height: 100,
          alignment: Alignment.topLeft,
          child:  Column(
            children: [
              (AppCubit.get(context).currentuser.usertype == "admin") ?
              IconButton(
                icon: Icon(Icons.delete,
                    color: Colors.red, size: 30),
                onPressed: () {
                  ShowDialogbox(context,(){
                    Navigator.pop(context);

                    brandsCubit.deleteProduct(trProduct,Currentbrand,currentindex,);
                  });
                },
                padding: EdgeInsets.zero,
              ):Container(),
              Container(
                child: (!isitembelongtoclint(trProduct,BrandsCubit.get(context)))?IconButton(
                  icon: Icon(Icons.shopping_cart,
                      color: Colors.black, size: 30),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ShoppingCartPage(trProduct,BrandsCubit.get(context).choosenclient),
                        ));
                    //brandsCubit.getCachedData();
                  },
                  padding: EdgeInsets.zero,
                ):IconButton(
                  icon: Icon(Icons.favorite,
                      color: Colors.green, size: 30),
                  onPressed: () {
                    ShowDialogbox(context,(){
                      Navigator.pop(context);
                      brandsCubit.DeleteItemFromOrderFromDatabase(trProduct);
                    });
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          )
          ,
        ),
      ],
    ),
  );
}

Widget BuildText(double height,String text,double width,{Color color=Colors.black}){
  return Container(
    alignment: Alignment.center,
    width: width,
    height: height,
    child: FittedBox(
      child: AutoSizeText(
          text,
          style: TextStyle(fontSize: 22,color: color),
          maxLines: 1),
    ),
  );
}
  bool isitembelongtoclint(TrProduct trProduct,BrandsCubit brandsCubit){


  if(brandsCubit.choosenclient!=null){
    for(int i=0;i<brandsCubit.choosenclient.orderitems.length;i++){
      if(brandsCubit.choosenclient.orderitems[i].trProduct.Item==trProduct.Item){
        return true;
      }
    }
  }
    return false;
  }