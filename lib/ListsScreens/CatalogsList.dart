import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
import 'package:steponedemo/Widgets/CircularProgressIndicatorForDownload.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import '../AddsScreens/AddnewCatalog.dart';
import 'package:steponedemo/CatalogCubit/CatalogCubit.dart';
import 'package:steponedemo/CatalogCubit/CatalogStates.dart';
import 'package:steponedemo/Widgets/BuildCatalogItem.dart';

class CatalogsList  extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CatalogCubit,CatalogStates>(
      listener: (context, state) {},
      builder: (context, state) {
        print(state);
        CatalogCubit catalogCubit =CatalogCubit.get(context);
        if(state is loadfilefromfirebase ||state is fileisuploading||state is loaddatafromfirebase){
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
            appBar: PreferredSize(child: CustomAppbar("كاتالوج") ,preferredSize: Size.fromHeight(70),),
            body:  RefreshIndicator(
              onRefresh: () async=> await CatalogCubit.get(context).getCatlogs(),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child:Container(
                  color: Color(0xffe6e6e6),
                  height: MediaQuery.of(context).size.height-200,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return LayoutBuilder(
                        builder: (context, constraints) =>BuildCatalogItem(catalogCubit, catalogCubit.Catalogs[index], constraints),
                      );
                    },
                    itemCount: catalogCubit.Catalogs.length,
                  ),
                ),
              ),
            ),
            floatingActionButton: (AppCubit.get(context).currentUser.usertype=="admin")? FloatingActionButton(
              heroTag: "btn1",
              child: Icon(Icons.add),
              onPressed: () async{
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddnewCatalog(),));
              },
            ):Container()
        );
      },
    );
  }

}
