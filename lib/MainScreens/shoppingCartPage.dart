import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:steponedemo/BrandsCubit/BrandsCubit.dart';
import 'package:steponedemo/BrandsCubit/BrandsStates.dart';
import 'package:steponedemo/Helpers/Shared.dart';
import 'package:steponedemo/Models/Client.dart';
import 'package:steponedemo/Models/Shippedtem.dart';
import 'package:steponedemo/Models/TRProdct.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
class ShoppingCartPage extends StatelessWidget {
  TrProduct trProduct;
  Client productOwner;
  ShoppingCartPage(this.trProduct,this.productOwner);
   TextEditingController quantity=TextEditingController();
   TextEditingController bounce=TextEditingController();
   TextEditingController discountReplacementToBounce=TextEditingController();
   TextEditingController addDiscount=TextEditingController();
   TextEditingController specialDiscount=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BrandsCubit,BrandsStates>(
      listener: (context, state) {
        if(state is ItemAddedToCart){
          Navigator.pop(context);
        }
        else if(state is clientnotchoosen){
          getsnackbar(context,"لم تقم ب اختيار صاحب الاوردر");
        }
      },
      builder: (context, state) {
        print(state);
        if(state is addingproducttocardinprogress){
          return Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Color(0xffe6e6e6),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Scaffold(
          appBar: PreferredSize(
            child: CustomAppbar("تفاصيل المنتج"),
            preferredSize: Size.fromHeight(70),
          ),
          body: Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Color(0xffe6e6e6),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width-50,
                    child: Row(
                      children: [
                        buildPercentageLable("عدد",((MediaQuery.of(context).size.width - 70))*0.4),
                        gettextfeild(((MediaQuery.of(context).size.width - 70))*0.35,
                            "", 10, quantity),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width-50,
                    child: Row(
                      children: [
                        buildPercentageLable("بونص",((MediaQuery.of(context).size.width - 70))*0.4),
                        gettextfeild(((MediaQuery.of(context).size.width - 70))*0.35,
                            "", 10, bounce),
                      ],
                    ),
                  ),
                  BuildRaw(context, "خصم بدل بونص",discountReplacementToBounce),
                  BuildRaw(context, "خصم اضافي",addDiscount),
                  BuildRaw(context,"خصم خاص",specialDiscount)
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.save),
            onPressed: () {
              ShippedItem shippedItem=ShippedItem(trProduct,
                  (quantity.text!="")?int.parse(quantity.text):0,
                  (bounce.text!="")?int.parse(bounce.text):0,
                  (discountReplacementToBounce.text!="")?double.parse(discountReplacementToBounce.text):0,
                  (addDiscount.text!="")?double.parse(addDiscount.text):0,
                  (specialDiscount.text!="")?double.parse(specialDiscount.text):0
              );
              BrandsCubit.get(context).AddProductToCart(shippedItem,productOwner);
              BrandsCubit.get(context).resetTextFeilds(quantity, bounce, discountReplacementToBounce, addDiscount, specialDiscount);
            },
          ),
        );
      },
    );
  }

}

