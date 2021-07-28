import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:steponedemo/BrandsCubit/BrandsCubit.dart';
import 'package:steponedemo/BrandsCubit/BrandsStates.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
import 'package:steponedemo/MainCubit/newproductstats.dart';
import 'package:steponedemo/Models/brand.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import '../Helpers/Utilites.dart';
import 'package:steponedemo/Widgets/BuildProductItem.dart';

class Products extends StatefulWidget {
  brand currentbrand;
  Products(this.currentbrand);
  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BrandsCubit,BrandsStates>(
      listener: (context, state) {

      },
      builder: (context, state) {
        BrandsCubit brandscubit = BrandsCubit.get(context);
        if(state is removingitemfromcartinprogress||state is loadingbrangforupdate){
          return Scaffold(
            body: Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        return Scaffold(
          appBar: PreferredSize(
            child: CustomAppbar("قائمة المنتجات"),
            preferredSize: Size.fromHeight(70),
          ),
          body: RefreshIndicator(
            onRefresh: () => brandscubit.getbrands(),
            child: Container(
              color: Color(0xffe6e6e6),
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return BuildProductItem( widget.currentbrand.products[index],brandscubit,index,widget.currentbrand,context);
                },
                itemCount: widget.currentbrand.products.length,
              ),
            ),
          )
        );
      },
    );
  }
}
