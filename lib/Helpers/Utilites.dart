import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:excel/excel.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:ext_storage/ext_storage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:steponedemo/BrandsCubit/BrandsCubit.dart';
import 'package:steponedemo/CatalogCubit/CatalogCubit.dart';
import 'package:steponedemo/Models/TRProdct.dart';
import 'package:steponedemo/Models/Visit.dart';
import 'package:steponedemo/NewsCubit/NewsCubit.dart';
import 'package:steponedemo/OrdersCubit/ordersCubit.dart';
import 'package:steponedemo/SellingPolicyCubit/PolicyCubit.dart';
import '../Models/file.dart';
List<visit> groupVisitsByTypeOfClock(List<visit> visits) {
  final groups = groupBy(visits, (visit e) {
    return e.typeofclock;
  });
  List<visit>orderedvisits=[];
  if( groups['ص']!=null){
    groups['ص'].sort((a, b) => a.hourofvisit.compareTo(b.hourofvisit));
    groups['ص'].forEach((element) {
      orderedvisits.add(element);
    });
  }
  if(groups['م']!=null){
    groups['م'].sort((a, b) => a.hourofvisit.compareTo(b.hourofvisit));
    groups['م'].forEach((element) {
      orderedvisits.add(element);
    });
  }
  if(groups['غير محدد']!=null){
    groups['غير محدد'].sort((a, b) => a.hourofvisit.compareTo(b.hourofvisit));
    groups['غير محدد'].forEach((element) {
      orderedvisits.add(element);
    });
  }
  return orderedvisits;
}

String getnameofdayinarabic(String name){
  switch(name){
    case "Sat," :  return "السبت";break;
    case "Sun," :  return "الاحد";break;
    case "Mon," :  return "الاثنين";break;
    case "Tue," :  return "الثلاثاء";break;
    case "Wed," :  return "الاربعاء";break;
    case "Thu," :  return "الخميس";break;
    case "Fri," :  return "الجمعة";break;
  }
}

String getDate(List<String>ss){
  String last = ss[1].split('/')[1] +
      "/" +
      ss[1].split('/')[0] +
      "/" +
      ss[1].split('/')[2] +
      " - " +
      ss[2];
  List<String> ff = last.split('-');
  return ff[0];
}

Future<List<TrProduct>> readExcelFile(String fileName,BrandsCubit brandsCubit,String typeofFile)async {



  File file = File(fileName);
  var bytes = file.readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);

  List<TrProduct> products = [];
  List<String>columns=[];
  for (int k = 0; k < excel.tables["List"].rows[0].length; k++) {
    if(excel.tables["List"].rows[0][k].contains("Retail")){
      columns.add("Retail المستهلك");
    }
    else{
      columns.add(excel.tables["List"].rows[0][k]);
    }
  }
  int count =0;
  for (int i = (typeofFile=="orderedFile")?1:2; i < excel.tables["List"].rows.length; i++) {
    List<dynamic> item = [];
    Map<String,dynamic>map={};
    for (int k = 0; k < excel.tables["List"].rows[i].length; k++) {
      if (excel.tables["List"].rows[i][k].runtimeType == Formula) {
        Formula d = excel.tables["List"].rows[i][k];
        item.add(d.value);
      } else {
        item.add(excel.tables["List"].rows[i][k]);
      }
    }
    for (int k = 0; k < excel.tables["List"].rows[0].length; k++) {
      map[columns[k]]=item[k];
    }

    if( map['Item']!="End"){

      if(map['Item'].contains("/")){
        map['Item'].replaceAll(new RegExp(r'[^\w\s]+'));
      }
      await FirebaseFirestore.instance.collection("ImagesWithCodes").doc(map['Item']).get().then((value){
        map["path"]=value.data()['imageUrl'];
        products.add(TrProduct.fromJson(map));
      }).catchError((error, stackTrace) {
        map["path"]="https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";
        products.add(TrProduct.fromJson(map));
      });
    }
    count++;
    brandsCubit.emitnumberofloadedfilesfromexel(count/(excel.tables["List"].rows.length));
  }
  return products;
}

String getTime() {
  List<String> ss = [];

  ss = DateFormat.yMEd().add_jms().format(DateTime.now()).split(' ');

  String last = ss[1].split('/')[1] +
      "/" +
      ss[1].split('/')[0] +
      "/" +
      ss[1].split('/')[2] +
      " - " +
      ss[2];
  List<String> ff = last.split('-');

  return ff[1] + " - " + ff[0];
}

Future<void> deletItem(file sellingpolicy,CollectionReference collectionReference,dynamic cubit){
  cubit.ReturnLoadingState();
  collectionReference
      .where("id", isEqualTo: sellingpolicy.id)
      .get()
      .then((value) {
    collectionReference.doc(value.docs.first.id).delete();
    UpdateList(cubit);
  });
}

String getDateWithoutTime() {
  List<String> dateInYMDFormat = [];

  dateInYMDFormat =
      DateFormat.yMEd().add_jms().format(DateTime.now()).split(' ');

  String last = dateInYMDFormat[1].split('/')[1] +
      "/" +
      dateInYMDFormat[1].split('/')[0] +
      "/" +
      dateInYMDFormat[1].split('/')[2];
  List<String> dateInYMDFormatAfterSplitting = last.split('-');
  return dateInYMDFormatAfterSplitting[0];
}

Future<UploadTask> UploadFileToServer (String typeofTransaction,File pdfFile,dynamic cubit,file newsellingpolicy,CollectionReference collection,List<file>dynamiclist,{String typeoflist,File mainimage,bool isthereMainImageInItem=false}) async{

  FirebaseStorage storage = FirebaseStorage.instance;

    if(isthereMainImageInItem){

      if(mainimage==null){
        newsellingpolicy.mainimagepath = "https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";
        newsellingpolicy.defauktphoto = "https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";
      }
      if(mainimage!=null){
        Reference ref = storage.ref().child("image1" + DateTime.now().toString());
        UploadTask uploadedfileProgress =ref.putFile(mainimage);
        uploadedfileProgress.snapshotEvents.listen((snapshot){
          double percentage =getRemainingPercentage(snapshot);
          cubit.ReturnPercentageState(percentage);
        }, onError: (Object e) {},
        );
        uploadedfileProgress.then((TaskSnapshot value){
          value.ref.getDownloadURL().then((valuee) {
            newsellingpolicy.mainimagepath=valuee;
            UploadDocument(typeofTransaction,pdfFile, cubit, newsellingpolicy, collection, typeoflist);
          });
        });
      }
      else{
        UploadDocument(typeofTransaction,pdfFile, cubit, newsellingpolicy, collection, typeoflist);
      }
    }
    else{
      UploadDocument(typeofTransaction,pdfFile, cubit, newsellingpolicy, collection, typeoflist);
    }
}

Future<void>UploadImage(String typeOfTransaction,File pdfFile,file newsellingpolicy,CollectionReference collection,dynamic cubit)async{
  String  extention =p.extension(pdfFile.path).split('.')[1];
  String filename =p.basename(pdfFile.path);
  newsellingpolicy.date = getDateWithoutTime();
  newsellingpolicy.extention=extention;
  Reference ref = FirebaseStorage.instance.ref().child('${extention}s/$filename');
  UploadTask uploadedfileProgress =ref.putFile(pdfFile, SettableMetadata(contentType: 'application/$extention'));
  uploadedfileProgress.snapshotEvents.listen((snapshot) {
    double percentage = getRemainingPercentage(snapshot);
    cubit.ReturnPercentageState(percentage);
  }, onError: (Object e) {});
  uploadedfileProgress.then((TaskSnapshot value) {
    value.ref.getDownloadURL().then((valuee) {
      newsellingpolicy.path = valuee;

      PutCorrectPathsOfImages(lookupMimeType("$filename"+".$extention").split("/")[0],newsellingpolicy,valuee);
      if(typeOfTransaction=="Update"){
        UpdateItem(newsellingpolicy, collection, cubit);
      }
      else{
        InsertItemToFireStore(collection, newsellingpolicy, cubit);
      }
    });
  });
}

Future<void>UpdateItem(dynamic order,CollectionReference collection,dynamic cubit)async{
  await collection
      .doc(order.id)
      .update(order.toJson())
      .then((value) {
      UpdateList(cubit);
   cubit.ReturnUpdateProcessEnded();
  }).catchError((error) => print("Failed to update order: $error"));
}

Future UploadDocument(String typeofTransaction,File pdfFile,dynamic cubit,file newsellingpolicy,CollectionReference collection,String typeoflist){
    if(pdfFile!=null){
      UploadImage(typeofTransaction,pdfFile, newsellingpolicy, collection, cubit);
    }
    else{
      newsellingpolicy.date = getDateWithoutTime();
      newsellingpolicy.defauktphoto="https://img.icons8.com/pastel-glyph/2x/no-document.png";
      InsertItemToFireStore(collection, newsellingpolicy, cubit);
    }
}

double getRemainingPercentage(TaskSnapshot snapshot) {
  double percentage = snapshot.bytesTransferred / snapshot.totalBytes;
  int decimals = 2;
  int fac = pow(10, decimals);
  percentage = (percentage * fac).round() / fac;
  return percentage;
}

Future<void> InsertItemToFireStore(CollectionReference collection,file newsellingpolicy,dynamic cubit,)async {
  collection.add(newsellingpolicy.toJson()).then((value) {
    newsellingpolicy.id = value.id;
    collection.doc(value.id).update({'id': value.id});
    cubit.ReturnEndingProcessState();
    UpdateList(cubit);
  }).catchError((error) => print("Failed to add item: $error"));
}

void PutCorrectPathsOfImages(String type, file newsellingpolicy,String path) {
  if(type=="image"){
    if(newsellingpolicy.mainimagepath==null){
      newsellingpolicy.mainimagepath=path;
    }
    newsellingpolicy.defauktphoto=path;
  }
  else if(type=="video"){
    if(newsellingpolicy.mainimagepath==null){
      newsellingpolicy.mainimagepath = "https://www.clipartmax.com/png/full/225-2253433_music-video-play-function-comments-video-gallery-icon-png.png";
    }
    newsellingpolicy.defauktphoto = "https://www.clipartmax.com/png/full/225-2253433_music-video-play-function-comments-video-gallery-icon-png.png";
  }
  else{

    if(newsellingpolicy.mainimagepath==null){
      newsellingpolicy.mainimagepath = "https://icons.iconarchive.com/icons/custom-icon-design/mono-general-2/256/document-icon.png";
    }
    newsellingpolicy.defauktphoto = "https://icons.iconarchive.com/icons/custom-icon-design/mono-general-2/256/document-icon.png";
  }
}

void UpdateList(dynamic cubit){
  if(cubit.runtimeType==CatalogCubit){
    cubit.getCatlogs();
  }
  else if(cubit.runtimeType==PolicyCubit){
    cubit.getpolices();
  }
  else if(cubit.runtimeType==ordersCubit){
    cubit.getOrders();
  }
  else if(cubit.runtimeType==NewsCubit){
    cubit.getnews();
  }
}

Future<void> launchURL(String url, String extention, String title,dynamic cubit) async {
  Dio dio = new Dio();

  try {
    await Permission.storage.request();
    OpenFile.open("/storage/emulated/0/Download/$title.$extention").then((value) async {
      if (value.type.index == 1) {
        String path = await ExtStorage.getExternalStoragePublicDirectory(
            ExtStorage.DIRECTORY_DOWNLOADS);
        String fullPath = "$path/$title.$extention";
        await downloadFileOnLocalStorage(dio, url, fullPath, title, extention,cubit);
      }
    });
  } catch (x) {}
}

Future downloadFileOnLocalStorage(Dio dio, String url, String savePath, String title, String extention,dynamic cubit) async {
  try {
    Response response = await dio.get(
      url,
      onReceiveProgress:(received, total) {
        int percentage;
        if (total != -1) {

          percentage =int.parse((received / total * 100).toStringAsFixed(0));
          if(percentage==100){
            cubit.ReturnfileisdownloadedState();
          }
          else{
            cubit.Returndownloadinprogressstate(percentage);
          }
        }
      },
      options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status < 500;
          }),
    );
    File file = File(savePath);
    var raf = file.openSync(mode: FileMode.write);
    raf.writeFromSync(response.data);
    OpenFile.open("/storage/emulated/0/Download/$title.$extention")
        .then((valuee) {});
    await raf.close();
  } catch (e) {
    print(e);
  }
}
