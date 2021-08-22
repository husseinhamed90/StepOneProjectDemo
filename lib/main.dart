// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:steponedemo/AddsScreens/newrepresentativepage.dart';
import 'package:steponedemo/Auth.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
import 'package:steponedemo/MainCubit/MainCubitStates.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steponedemo/CatalogCubit/CatalogCubit.dart';
import 'package:steponedemo/ClientsCubit/ClientsCubit.dart';
import 'package:steponedemo/OrdersCubit/ordersCubit.dart';
import 'package:steponedemo/UserOrdersCubit/UserOrdersCubit.dart';
import 'package:steponedemo/VisitsCubit/VisitsCubit.dart';
import 'MainScreens/Login.dart';
import 'package:steponedemo/Models/Representative.dart';
import 'package:steponedemo/Models/User.dart';
import 'MainScreens/NewHome.dart';
import 'package:sqflite/sqflite.dart';
import 'package:steponedemo/NewsCubit/NewsCubit.dart';
import 'package:steponedemo/SellingPolicyCubit/PolicyCubit.dart';
import 'RepresentatersCubit/RepresentaterCubit.dart';
import 'Translations.dart';
import 'package:steponedemo/BrandsCubit/BrandsCubit.dart';
import 'package:get/get.dart';
void main()async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userId = prefs.getString('id')??"";
  if(userId==""){
    runApp(MyApp(userId));
  }
  else{
    user currentUser = await Auth.GetUserInfo(userId);
    if(currentUser!=null){
      await Auth.changeStateOfUser(currentUser);
      Representative representative =await Auth.getReprestatvieInfo(currentUser);
      runApp( MyApp(userId,currentUser,representative));
    }
    else{
      runApp(MyApp(""));
    }
  }
}
class MyApp extends StatefulWidget {
  user currentUser;
  Representative representative;
  String id;
  MyApp([this.id,this.currentUser,this.representative]);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Database database;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: CreateDataBase(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return MultiProvider(
              providers: [
                BlocProvider(create: (_) => AppCubit()..SetCurrentRepresentative(widget.representative)..GetCurrentUser(widget.currentUser)..getUsers(),),
                BlocProvider(create: (_) => PolicyCubit()..getpolices()),
                BlocProvider(create: (_) => ordersCubit()),
                BlocProvider(create: (_) => UserOrdersCubit(),),
                BlocProvider(create: (_) => VisitsCubit(),),
                (widget.currentUser!=null)? BlocProvider(create: (_) => ClientsCubit()..GetCurrentUser(widget.currentUser.id)..getClintess()) :BlocProvider(create: (_) => ClientsCubit()),
                BlocProvider(create: (_) => CatalogCubit(),),
                BlocProvider(create: (_) => BrandsCubit(snapshot.data)..getbrands(),),
                (widget.representative!=null)? BlocProvider(create: (_) => RepresentaterCubit()..SetRepresentatvie(widget.representative)):BlocProvider(create: (_) => RepresentaterCubit()),
                BlocProvider(create: (_) => NewsCubit()..getnews(),)
              ],
              child: BlocConsumer<AppCubit,MainCubitState>(
                listener: (context, state) {},
                builder:(context, state) => ScreenUtilInit(
                  designSize: Size(1080,2280),
                  builder: () => GetMaterialApp(
                    home:(widget.id=="")?Login():(widget.representative!=null)?newhomepage.constructorWithrepresentative(widget.currentUser,widget.representative,widget.currentUser.usertype):Newrepresentativepage(widget.currentUser.name,widget.id),
                    translations: translation(),
                    debugShowCheckedModeBanner: false,
                    locale: Locale("ar"),
                  ),
                ),
              ),
            );
          }
          else{
            return MaterialApp(
              home: Scaffold(
                body: Container(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            );
          }
        }
    );
  }
}

Future<Database> CreateDataBase()async{
  return await openDatabase(
    "Order.db"
    ,version: 1,
    onCreate: (db, version) {
      db.execute('CREATE TABLE myorders (id INTEGER PRIMARY KEY,ClientID TEXT,itemID TEXT,quantity INTEGER,bounce INTEGER,Discountinsteadofbonus REAL,Discountinsteadofadding REAL,specialDiscount REAL)').then((value) {
        print("Table is Created");
      });
      db.execute('CREATE TABLE products (id INTEGER PRIMARY KEY,ClientID TEXT,Item TEXT,Description TEXT,Q INTEGER,Retail REAL,path TEXT)').then((value) {
        print("Table is Created 2");
      });
    },onOpen: (db) {
    print("Database is Opened");
  },).then((value) {
    print("DataBase Created");
    return value;
  });
}
