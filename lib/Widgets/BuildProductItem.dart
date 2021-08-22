import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:steponedemo/BrandsCubit/BrandsCubit.dart';
import 'package:steponedemo/Helpers/Shared.dart';
import 'package:steponedemo/Helpers/Utilites.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
import 'package:steponedemo/Models/Client.dart';
import 'package:steponedemo/Models/TRProdct.dart';
import 'package:steponedemo/Models/brand.dart';
import '../MainScreens/shoppingCartPage.dart';
import 'package:get/get.dart';

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
            if(AppCubit.get(context).currentUser.usertype=="admin"){
              showModalBottomSheet(context: context, builder: (context) {
                return Container(
                  height: MediaQuery.of(context).size.height*0.2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(onTap: () async{

                        File file =await getImagefromSourse(ImageSource.gallery);
                        brandsCubit.setImage(file,typeofimage: "product");
                        await brandsCubit.updateProduct(Currentbrand.products[currentindex], Currentbrand, currentindex);

                      },child: Image.asset("assets/gallery.png",height: 70)),
                      SizedBox(width: 20,),
                      InkWell( onTap: () async{
                        File file =await getImagefromSourse(ImageSource.camera);
                        brandsCubit.setImage(file,typeofimage: "product");
                        await brandsCubit.updateProduct(Currentbrand.products[currentindex], Currentbrand, currentindex);
                      }
                          ,child: Image.asset("assets/camera.png",height: 80)),              ],
                  ),
                );
              },);
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
              (AppCubit.get(context).currentUser.usertype == "admin") ?
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.delete,
                      color: Colors.red, size: 25),
                  onPressed: () {
                    ShowDialogbox(context,(){
                      Navigator.pop(context);

                      brandsCubit.deleteProduct(trProduct,Currentbrand,currentindex,);
                    });
                  },
                  padding: EdgeInsets.zero,
                ),
              ):Container(),
              Expanded(
                child: Container(
                  child: (!isitembelongtoclint(trProduct,BrandsCubit.get(context)))?IconButton(
                    icon: Icon(Icons.shopping_cart,
                        color: Colors.black, size: 25),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ShoppingCartPage(trProduct,BrandsCubit.get(context).chosenClient,shippedItem: null,),
                          ));
                      //brandsCubit.getCachedData();
                    },
                    padding: EdgeInsets.zero,
                  ):IconButton(
                    icon: Icon(Icons.favorite,
                        color: Colors.green, size: 25),
                    onPressed: () {
                      ShowDialogbox(context,(){
                        Navigator.pop(context);
                        brandsCubit.deleteItemFromOrderFromDatabase(trProduct);
                      });
                    },
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
              (isitembelongtoclint(trProduct,BrandsCubit.get(context))?Expanded(
                child: Container(
                  child: (IconButton(
                    icon: Icon(Icons.edit,
                        color: Colors.black, size: 25),
                    onPressed: () {
                      Get.to(ShoppingCartPage(trProduct, BrandsCubit.get(context).chosenClient,shippedItem: BrandsCubit.get(context).chosenClient.mapOfOrderedItems[trProduct.Item]));
                    },
                    padding: EdgeInsets.zero,
                  )),
                ),
              ):Container())
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


  if(brandsCubit.chosenClient!=null){
    for(int i=0;i<brandsCubit.chosenClient.orderitems.length;i++){
      if(brandsCubit.chosenClient.orderitems[i].trProduct.Item==trProduct.Item){
        return true;
      }
    }
  }
    return false;
  }