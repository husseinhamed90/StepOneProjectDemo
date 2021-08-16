// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:steponedemo/AddsScreens/newrepresentativepage.dart';
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
    user currentuser = await GetUserInfo(userId);
    if(currentuser!=null){
      await changeStateOfUser(currentuser);
      Representative representative =await getReprestatvieInfo(currentuser);
      runApp( MyApp(userId,currentuser,representative));
    }
    else{
      runApp(MyApp(""));
    }
  }
}
class MyApp extends StatefulWidget {
  user userr;
  Representative representative;
  String id;
  MyApp([this.id,this.userr,this.representative]);
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
                BlocProvider(create: (_) => AppCubit()..SetCurrentRepresentative(widget.representative)..GetCurrentUser(widget.userr)..getusers(),),
                BlocProvider(create: (_) => PolicyCubit()..getpolices()),
                BlocProvider(create: (_) => ordersCubit()),
                BlocProvider(create: (_) => UserOrdersCubit(),),
                BlocProvider(create: (_) => VisitsCubit(),),
                (widget.userr!=null)? BlocProvider(create: (_) => ClientsCubit()..GetCurrentUser(widget.userr.id)..getClintess()) :BlocProvider(create: (_) => ClientsCubit()),
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
                    home:(widget.id=="")?Login():(widget.representative!=null)?newhomepage.constructorWithrepresentative(widget.userr,widget.representative,widget.userr.usertype):Newrepresentativepage(widget.userr.name,widget.id),
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
Future<user>GetUserInfo(String id)async{
  DocumentSnapshot documentReference = await FirebaseFirestore.instance.collection('Users').doc(id).get();
  user currentuser =user.fromJson(documentReference.data());
  return currentuser;
}

Future<QuerySnapshot>getRepresentative()async{
  CollectionReference representatives = FirebaseFirestore.instance.collection('Representatives');
  return await representatives.get();
}

Future<Representative>getReprestatvieInfo(user currentuser)async{
  Representative representative;
  QuerySnapshot snapshot =await getRepresentative();
  snapshot.docs.forEach((doc)  {
    if (Representative.fromJson(doc.data()).id == currentuser.id) {
      representative= Representative.fromJson(doc.data());
    }
  });
  return representative;
}

Future<void>changeStateOfUser(user currentuser)async{
  return await FirebaseFirestore.instance.collection('Users').doc(currentuser.location).update({'isonline': "true"});
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
