import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:steponedemo/AddsScreens/AddClientPage.dart';
import 'package:steponedemo/ClientsCubit/ClientsCubit.dart';
import 'package:steponedemo/Helpers/Shared.dart';
import 'package:steponedemo/RepresentatersCubit/RepresentaterCubit.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import 'package:toast/toast.dart';
import '../AddsScreens/Addnewbrand.dart';
import 'package:http/http.dart' as http;

import 'package:steponedemo/MainCubit/AppCubit.dart';
import 'package:steponedemo/Widgets/BuildBrandItem.dart';

import 'products.dart';

import 'package:steponedemo/BrandsCubit/BrandsCubit.dart';

import 'package:steponedemo/BrandsCubit/BrandsStates.dart';

class BrandsList extends StatefulWidget {
  @override
  _BrandsListState createState() => _BrandsListState();
}

class _BrandsListState extends State<BrandsList> {

  TextEditingController searchBar=TextEditingController();
  FocusNode myFocusNode=FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(BrandsCubit.get(context).chosenClient!=null){
      searchBar.text=BrandsCubit.get(context).chosenClient.clientname;
    }
  }
  @override
  void dispose() {
    searchBar.clear();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BrandsCubit, BrandsStates>(
      listener: (context, state) {
        if(state is OrderSavedState){
          Toast.show("تم حفظ الاوردر بنجاح", context, duration: 2, gravity: Toast.BOTTOM);
        }
        else if (state is nochoosenclientforOrder){
          getsnackbar(context, "قم ب اختيار صاحب الاوردر");
        }
        else if(state is noItemsInCart){
          getsnackbar(context, "لا توجد اصناف ف الاوردر");
        }
      },
      builder: (context, state) {
        BrandsCubit brandsCubit=BrandsCubit.get(context);
        print(state);
        if (state is loadingbrangforupdate || state is branddeleted||state is addingproducttocardinprogress) {
          return Scaffold(
            body: Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        return  Scaffold(
            appBar: PreferredSize(
              child: CustomAppbar("عمل اورد"),
              preferredSize: Size.fromHeight(70),
            ),
            body: RefreshIndicator(
              onRefresh: () => BrandsCubit.get(context).getbrands(),
              child: Container(
                color: Color(0xffe6e6e6),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 55,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          width: (MediaQuery.of(context).size.width-20)*0.8,
                          child: FocusScope(
                            child: Focus(
                              focusNode: myFocusNode,
                              onFocusChange: (value) {
                                brandsCubit.textFormFocusState(value);
                              },
                              child: TextFormField(
                                controller: searchBar,
                                onChanged: (value) async {
                                  brandsCubit.changeSuggestionResultList(searchBar.text, ClientsCubit.get(context).clients);
                                },

                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () async {
                                      brandsCubit.resetSearchBar();
                                      searchBar.clear();
                                      await brandsCubit.getCachedData();

                                    },
                                  ),
                                    border: InputBorder.none,
                                    contentPadding:
                                    EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                                    hintText: "ادخل اسم العميل"),
                              ),
                            ),
                          ),
                        ),
                        Container(
                            alignment: Alignment.centerLeft,
                            height: 50,
                            width: (MediaQuery.of(context).size.width-20)*0.2,
                            child: FittedBox(
                              child: FloatingActionButton(
                                child: Icon(Icons.add),
                                backgroundColor: Colors.blue,
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddnewClientPage(),));
                                },
                              ),
                            )
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Expanded(
                      child: (!brandsCubit.focusState)?
                      ListView.builder(
                        itemBuilder: (context, index) {
                          return LayoutBuilder(
                              builder: (context, constraints) =>
                                  BuildBtandItem(
                                      brandsCubit,
                                      brandsCubit.brands[index],
                                      constraints));
                        },
                        itemCount: brandsCubit.brands.length,
                      ):
                      ListView.builder(
                        itemBuilder: (context, index) {
                          return LayoutBuilder(
                              builder: (context, constraints) => InkWell(
                                onTap: () async{
                                  brandsCubit.setChosenClient(brandsCubit.suggestionResult[index]);
                                  await brandsCubit.getCachedData();
                                  searchBar.text=brandsCubit.suggestionResult[index].clientname;
                                  brandsCubit.resetSearchBar();
                                },
                                child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Text(brandsCubit.suggestionResult[index].clientname)
                                ),
                              ));
                        },
                        itemCount: brandsCubit.suggestionResult.length,
                      ),
                    ),
                    Container(height: 80,)
                  ],
                ),
              )
            ),
            bottomSheet: Container(
              height: 80,
              width: double.infinity,
              color: Colors.green,
              child: Row(
                children: [
                  Expanded(flex: 1,child: Container(
                    height: 55,
                  )),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 55,
                      width: MediaQuery.of(context).size.width*0.5,
                      child: ElevatedButton(onPressed:() {
                        brandsCubit.insertOrderIntoFireBase(RepresentaterCubit.get(context).currentrepresentative.id);
                      } , child: Text("حفظ الاوردر")),
                    ),
                  ),
                  Expanded(flex: 1,child: (AppCubit.get(context).currentUser.usertype == "admin")
                      ? Container(
                    height: 55,
                        child: FloatingActionButton(
                    key: Key("key1hhhhhhhhhh"),
                    child: Icon(Icons.add),
                    onPressed: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddnewBrand(),
                            ));
                    },
                  ),
                      ): Container(height: 55,))

                ],
              ),
            ),
        );

      },
    );
  }
}
