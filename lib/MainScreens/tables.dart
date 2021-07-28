import 'dart:convert';
import 'dart:io';
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:steponedemo/BrandsCubit/BrandsCubit.dart';
import 'package:steponedemo/ClientsCubit/ClientsCubit.dart';
import 'package:steponedemo/Models/Representative.dart';
import 'package:steponedemo/Models/UserOrder.dart';
import 'package:steponedemo/Models/Visit.dart';
Future<void> saveAndLaunchFile(List<int> bytes, String fileName,) async {
  final path = (await getExternalStorageDirectory()).path;
  final file = File('$path/$fileName');
  await file.writeAsBytes(bytes, flush: false);
  OpenFile.open('$path/$fileName');

}

Future<String> networkImageToBase64(String mediaUrlString) async {
  http.Response response = await http.get(Uri.parse(mediaUrlString));
  final bytes = response?.bodyBytes;
  return (bytes != null ? base64Encode(bytes) : null);
}
Future savetableotoPdf(ClientsCubit appprovider,Representative currentrepresentative) async {

  final Document pdf = Document();

  final fontData = await rootBundle.load("assetsfont/fonts/arial.ttf");
  final ttf = Font.ttf(fontData.buffer.asByteData());

  List<TableRow>rows=[];
  rows.add(TableRow(
      children: [
        Center(
          child:  Text("منطقة",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
        ),
        Center(
          child:  Text("تليفون",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
        ),
        Center(
          child:  Text("عنوان",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
        ),
        Center(
          child:  Text("نوع التعامل",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
        ),
        Center(
          child:  Text("كود العميل",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
        ),
        Center(
          child:  Text("اسم العميل",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
        ),
        Center(
          child:  Container(
              alignment: Alignment.center,
              child: Text("م",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
              width: 30
          ),
        ),
      ]
  ));
  ArabicNumbers arabicNumber = ArabicNumbers();


  for(int i=0;i<appprovider.clients.length;i++){
    rows.add(TableRow(
        children: [

          Center(
            child: Text((appprovider.clients[i].area!="")?appprovider.clients[i].area:"-",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
          ),
          Center(
            child:  Text((appprovider.clients[i].phone!="")?appprovider.clients[i].phone:"-",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
          ),
          Center(
            child:  Text((appprovider.clients[i].address!="")?appprovider.clients[i].address:"-",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
          ),
          Center(
            child:  Text((appprovider.clients[i].clinttype!="")?appprovider.clients[i].clinttype:"-",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
          ),
          Center(
            child:  Text((appprovider.clients[i].clientcode!="")?appprovider.clients[i].clientcode:"-",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
          ),
          Center(
            child:  Text((appprovider.clients[i].clientname!="")?appprovider.clients[i].clientname:"-",  style: TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
          ),
          Center(
            child:  Container(
              alignment: Alignment.center,
              child: Text("${arabicNumber.convert(i+1)}",  style: TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
            ),
          ),
        ]
    ));
  }
  String gg="";
  await networkImageToBase64(currentrepresentative.path).then((value) {
    gg=value;
    pdf.addPage(Page(
        theme: ThemeData.withFont(
          base: ttf,
        ),
        pageFormat: PdfPageFormat.a4,
        orientation: PageOrientation.landscape,
        build: (Context context) {
          Uint8List bytes = base64Decode(gg);
          return Container(
              alignment: Alignment.topRight,
              child:Column (
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Center(
                      child:  Text("بيانات العملاء للمندوب : ${currentrepresentative.represtativename}",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                    ),
                    SizedBox(height: 20),
                    Table(
                        border: TableBorder.all(),
                        children: rows
                    ),
                  ]
              ));
        }));
  });
  saveAndLaunchFile(await pdf.save(),'بيانات العملاء.pdf');
}

Future DisplayOrders(UserOrder userOrder,Representative representative) async {

  final Document pdf = Document();

  final fontData = await rootBundle.load("assetsfont/fonts/arial.ttf");
  final ttf = Font.ttf(fontData.buffer.asByteData());

  List<TableRow>rows=[];
  rows.add(TableRow(
      children: [

        Center(
          child:  Text("خصم خاص",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
        ),
        Center(
          child:  Text("خصم بدل اضافي",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
        ),
        Center(
          child:  Text("خصم بدل بونص",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
        ),
        Center(
          child:  Text("البونص",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
        ),
        Center(
          child:  Text("العدد",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
        ),
        Center(
          child:  Text("كود الصنف",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
        ),
        Center(
          child:  Container(
              alignment: Alignment.center,
              child: Text("م",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
              width: 30
          ),
        ),
      ]
  ));
  ArabicNumbers arabicNumber = ArabicNumbers();

  for(int i=0;i<userOrder.orderitems.length;i++){
    rows.add(TableRow(
        children: [


          Center(
            child:  Text(userOrder.orderitems[i].specialDiscount.toString(),style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
          ),
          Center(
            child: Text(userOrder.orderitems[i].Discount_instead_of_adding.toString(),style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
          ),
          Center(
            child:  Text(userOrder.orderitems[i].Discount_instead_of_bonus.toString(),style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
          ),
          Center(
            child: Text(userOrder.orderitems[i].bounce.toString(),style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
          ),
          Center(
            child:  Text(userOrder.orderitems[i].quantity.toString(),style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
          ),
          Center(
            child: Text((userOrder.orderitems[i].trProduct.Item!="")?userOrder.orderitems[i].trProduct.Item:"-",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
          ),
          Center(
            child:  Container(
              padding: EdgeInsets.only(right: 8),
              alignment: Alignment.center,
              child: Text("${arabicNumber.convert(i+1)}",  style: TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
            ),
          ),
        ]
    ));
  }
  pdf.addPage(Page(
      theme: ThemeData.withFont(
        base: ttf,
      ),
      pageFormat: PdfPageFormat.a4,
      orientation: PageOrientation.portrait,
      build: (Context context) {
       // Uint8List bytes = base64Decode(gg);
        return Container(
            alignment: Alignment.topLeft,
            child:Column (
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Text("${userOrder.OrderOwner.clientcode}",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                          Text("الكود : ",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                        ]
                      ),
                      Row(
                          children: [
                            Text("${userOrder.OrderOwner.clinttype}",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                            Text("نوع التعامل : ",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                          ]
                      ),
                      Row(
                          children: [
                            Text("${userOrder.OrderOwner.clientname}",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                            Text("اسم العميل : ",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                          ]
                      ),
                    ]
                  ),
                  SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [


                        Row(
                            children: [
                              Text("${representative.represtativename}",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                              Text("اسم المندوب : ",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                            ]
                        ),
                        Row(
                            children: [
                              Text("${userOrder.OrderOwner.area}",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                              Text("المنطقة : ",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                            ]
                        ),

                      ]
                  ),

                  SizedBox(height: 20),
                  Table(
                      border: TableBorder.all(),
                      children: rows
                  ),
                ]
            ));
      }));
  saveAndLaunchFile(await pdf.save(),'بيانات الاوردر.pdf');
}

Future DisplayVisits(Representative representative,String choosendate,String dayofdate,String typeofwork,List<visit>visits) async {

  final Document pdf = Document();

  final fontData = await rootBundle.load("assetsfont/fonts/arial.ttf");
  final ttf = Font.ttf(fontData.buffer.asByteData());

  List<TableRow>rows=[];
  rows.add(TableRow(
      children: [
        Center(
          child:  Text("سبب الزيارة",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
        ),
        Center(
          child:  Text("اسم العميل",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
        ),
        Center(
          child:  Container(
              alignment: Alignment.center,
              child: Text("م",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
              width: 30
          ),
        ),
      ]
  ));
  ArabicNumbers arabicNumber = ArabicNumbers();


  for(int i=0;i<visits.length;i++){
    rows.add(TableRow(
        children: [



          Center(
            child: Text(visits[i].reasonforvisit,style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
          ),
          Center(
            child:  Text(visits[i].visitOwner.clientname,style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
          ),
          Center(
            child:  Container(
              padding: EdgeInsets.only(right: 8),
              alignment: Alignment.center,
              child: Text("${arabicNumber.convert(i+1)}",  style: TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
            ),
          ),
        ]
    ));
  }
  pdf.addPage(Page(
      theme: ThemeData.withFont(
        base: ttf,
      ),
      pageFormat: PdfPageFormat.a4,
      orientation: PageOrientation.portrait,
      build: (Context context) {
        // Uint8List bytes = base64Decode(gg);
        return Container(
            alignment: Alignment.topLeft,
            child:Column (
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [


                        Row(
                            children: [
                              Text("${representative.represtativename}",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                              Text("اسم المندوب : ",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                            ]
                        ),
                        Row(
                            children: [
                              Text(typeofwork,style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                              Text("نوع العمل : ",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                            ]
                        ),

                      ]
                  ),
                  SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                            children: [
                              Text(dayofdate,style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                              Text("الموافق : ",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                            ]
                        ),
                        Row(
                            children: [
                              Text(choosendate,style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                              Text("اليوم : ",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                            ]
                        ),
                      ]
                  ),

                  SizedBox(height: 20),
                  Table(
                      border: TableBorder.all(),
                      children: rows
                  ),
                  SizedBox(height: 20),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color:PdfColors.black),
                          borderRadius: BorderRadius.all(Radius.circular(5)),

                        ),
                        alignment: Alignment.center,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("زيارات ",style:  TextStyle(font: ttf, fontSize: 20),textDirection: TextDirection.rtl),
                              Text(visits.length.toString(),style:  TextStyle(font: ttf, fontSize: 20),textDirection: TextDirection.rtl),
                              Text("عدد الزيارات  :  ",style:  TextStyle(font: ttf, fontSize: 20),textDirection: TextDirection.rtl),
                            ]
                        ),

                      )
                    ]
                  )
                ]
            ));
      }));
  saveAndLaunchFile(await pdf.save(),'زياراتي.pdf');
}
