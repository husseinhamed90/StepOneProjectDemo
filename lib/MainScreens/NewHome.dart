import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:steponedemo/ListsScreens/NewsList.dart';
import 'package:steponedemo/AddsScreens/Addnewrepresentative.dart';
import 'package:steponedemo/ListsScreens/BrandsList.dart';
import 'package:steponedemo/CatalogCubit/CatalogCubit.dart';
import 'package:steponedemo/ListsScreens/CatalogsList.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
import 'package:steponedemo/OrdersCubit/ordersCubit.dart';
import 'package:steponedemo/constants.dart';
import '../ListsScreens/Clientss.dart';
import 'package:steponedemo/Widgets/CustomDialog.dart';
import 'InfoCard.dart';
import 'package:steponedemo/Models/User.dart';
import 'package:steponedemo/NewsCubit/NewsCubit.dart';
import 'package:steponedemo/NewsCubit/NewsCubitState.dart';
import 'Reports.dart';
import 'package:steponedemo/RepresentatersCubit/RepresentaterCubit.dart';
import 'package:steponedemo/RepresentatersCubit/RepresentatersStates.dart';
import 'package:steponedemo/SellingPolicyCubit/PolicyCubit.dart';
import 'package:steponedemo/ListsScreens/SellingpolicyList.dart';
import '../Helpers/Shared.dart';
import 'package:steponedemo/ListsScreens/orders.dart';
import 'schadual.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'Register.dart';
import 'package:steponedemo/Models/Representative.dart';

class newhomepage extends StatelessWidget {
  String title;
  String usertype;
  user currentuser;
  Representative representative;
  newhomepage(this.title, [this.usertype]);
  newhomepage.constructorWithrepresentative(this.currentuser, this.representative, [this.usertype]);

  openCalcualtor() async {
    try {
      await channel.invokeMethod('opencalc');
    } on PlatformException catch (ex) {
    }
  }
  @override
  Widget build(BuildContext context) {
    List<Function> functions = [
      () {Get.to(AddNewrepresentative(title));},
      () {Get.to(Clintess());},
      () {Get.to(Schadule());},
      () {openCalcualtor();},
      () async {
        await CatalogCubit.get(context).getCatlogs();
        Get.to(CatalogsList());
      },
      () {Get.to(BrandsList());},
      () {Get.to(Sellingpolicypage());},
      () async {
        await ordersCubit.get(context).getOrders();
        Get.to(Orderspage());
      },
      () {Get.to(InfoCart());},
      () {Get.to(Reports());},
      () async {
        NewsCubit.get(context).SetNewNumberOfNews();
        await NewsCubit.get(context).getnews();
        Get.to(NewsListpage());
      },
      () {
        if (AppCubit.get(context).currentuser.usertype == "admin") { Get.to(Register());}
        else {CustomDialog(context);}
      }
    ];
    return BlocConsumer<NewsCubit, NewsCubitState>(
      listener: (context, state) {
        if (state is exitapp) {
          SystemNavigator.pop();
        }
      },
      builder: (context, state) {
        if (state is updatestatuesloading) {
          return Scaffold(
            body: Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          return Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(70),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: AppBar(
                    centerTitle: true,
                    title: Container(
                      width: 0.5.sw,
                      height: 32,
                      child: FittedBox(
                        child: AutoSizeText(
                          "${(RepresentaterCubit.get(context).currentrepresentative.represtativename == null) ? "" : RepresentaterCubit.get(context).currentrepresentative.represtativename}",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                        ),
                      ),
                    ),
                    backgroundColor: Colors.white,
                    elevation: 0,
                    actions: [
                      Container(
                        alignment: Alignment.center,
                        width: 80,
                        child: GestureDetector(
                            onTap: () {
                              NewsCubit.get(context).SetNewNumberOfNews();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NewsListpage(),
                                  ));
                            },
                            child: Stack(
                              alignment: Alignment.bottomLeft,
                              children: [
                                Positioned(
                                    left: 20,
                                    top: 5,
                                    child: Image.asset(
                                      "assets/bell.png",
                                      width: 40,
                                    )),
                                Positioned(
                                    width: 75,
                                    child: AutoSizeText(
                                      "${NewsCubit.get(context).numofnewnews}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                          fontSize: 25),maxLines: 1,
                                    )),
                              ],
                            )),
                      ),
                    ],
                    leading: InkWell(
                        onTap: () {
                          showdialogForExit(context);
                        },
                        child: Container(
                          child: Image.asset(
                            "assets/exit.jpg",
                          ),
                          margin: EdgeInsets.only(right: 10, top: 5),
                        )),
                  ),
                ),
              ),
              body: Container(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 0),
                  color: Colors.white,
                  child: GridView.count(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: List.generate(images.length, (index) {
                      return InkWell(
                        onTap: functions[index],
                        child: LayoutBuilder(
                          builder: (context, constraints) => Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                              color: Colors.grey,
                              width: 2,
                            )),
                            child: Column(
                              children: [
                                Container(
                                  height: constraints.maxHeight * 0.11,
                                ),
                                Container(
                                  height: constraints.maxHeight * 0.43,
                                  //  padding: const EdgeInsets.only(top: 10),
                                  child: Image.asset(
                                    images[index],
                                    height: 70,
                                  ),
                                ),
                                Container(
                                  height: constraints.maxHeight * 0.05,
                                ),
                                Container(
                                  width: constraints.maxWidth * 0.85,
                                  height: constraints.maxHeight * 0.34,
                                  child: FittedBox(
                                    child: AutoSizeText(
                                      names[index],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  child: Container(),
                                  // color: Colors.red,
                                  height: constraints.maxHeight * 0.07 - 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  )));
        }
      },
    );
  }
}
