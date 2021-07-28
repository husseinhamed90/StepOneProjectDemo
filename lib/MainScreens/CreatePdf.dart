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
import 'package:steponedemo/Models/Representative.dart';
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
Future DisplayOrdersInPdf(){

}
Future savePdf(Representative currentrepresentative) async {

  ArabicNumbers arabicNumber = ArabicNumbers();
  String arabicphone="";
  String represtativecode="";
  String represtativetarget="";

  for(int i=0;i<currentrepresentative.represtativenphone.length;i++){
    arabicphone+=arabicNumber.convert(currentrepresentative.represtativenphone[i]);
  }
  for(int i=0;i<currentrepresentative.represtativecode.length;i++){
    represtativecode+=arabicNumber.convert(currentrepresentative.represtativecode[i]);
  }
  for(int i=0;i<currentrepresentative.represtativetarget.length;i++){
    represtativetarget+=arabicNumber.convert(currentrepresentative.represtativetarget[i]);
  }

  final Document pdf = Document();

  final fontData = await rootBundle.load("assetsfont/fonts/arial.ttf");
  final ttf = Font.ttf(fontData.buffer.asByteData());
  String number1 = arabicNumber.convert(1);
  String number2 = arabicNumber.convert(2);
  String number3 = arabicNumber.convert(3);
  String number4 = arabicNumber.convert(4);

  String area1 ="المنطقة  $number1 :";
  String area2 ="المنطقة  $number2 :";
  String area3 ="المنطقة  $number3 :";
  String area4 ="المنطقة  $number4 :";
  String clintpicature="";

  print(arabicphone);
  await networkImageToBase64(currentrepresentative.path).then((value) {
    clintpicature=value;

  });
  await networkImageToBase64("https://firebasestorage.googleapis.com/v0/b/stepone-a6e15.appspot.com/o/logo.jpg?alt=media&token=1268eff8-d87e-4f0a-a3ce-cc987f523eca").then((value) {
    //logo=value;

  }).then((value) {
    pdf.addPage(Page(
        theme: ThemeData.withFont(
          base: ttf,
        ),
        pageFormat: PdfPageFormat.a4,
        build: (Context context) {
          Uint8List bytes = base64Decode(clintpicature);
          return Container(
              alignment: Alignment.topRight,
              child:Column (
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text("بيانات المندوب", style: TextStyle(fontWeight: FontWeight.bold,font: ttf, fontSize: 20,color: PdfColor.fromInt(1)),textDirection: TextDirection.rtl),
                          Container(
                              height: 2,
                              width: 200,
                          ),
                        ]
                      )
                    ),
                    Row(
                        children: [
                          Container(
                              height: 120,
                              width: 150,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: MemoryImage(bytes),
                                    fit: BoxFit.fill
                                  )
                              )),
                          Spacer(),
                          Column(
                              children: [
                                SizedBox(height: 20),
                                Text("اسم الشركة   -:  ${currentrepresentative.companyname}",
                                    style: TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                                SizedBox(height: 20),
                                Text("عنوان الشركة   -:  ${currentrepresentative.companyaddress}",
                                    style: TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                                SizedBox(height: 20),
                                Text("تليفون الشركة   -:  ${currentrepresentative.companyphone}",
                                    style: TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                              ]
                          ),
                        ]
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: PdfPageFormat.a4.width,
                      color: PdfColors.black,
                      height: 1
                    ),
                    SizedBox(height: 20),
                    Row(
                        children: [
                          Text("كود المندوب   -: $represtativecode",

                              style: TextStyle(font: ttf, fontSize: 20,color: PdfColor.fromInt(1)),textDirection: TextDirection.rtl),

                          Spacer(),
                          Text("اسم المندوب   -: ${currentrepresentative.represtativename}",

                              style: TextStyle(font: ttf, fontSize: 20),textDirection: TextDirection.rtl),
                        ]
                    ),
                    SizedBox(height: 30),
                    Text("رقم التليفون   -:  $arabicphone",
                        style: TextStyle(font: ttf, fontSize: 20),textDirection: TextDirection.rtl),
                    SizedBox(height: 30),
                    Text("التارجت   -: $represtativetarget جنيها",
                        style: TextStyle(font: ttf, fontSize: 20),textDirection: TextDirection.rtl),
                    SizedBox(height: 30),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(width: 30),
                                Text("$area2 ${currentrepresentative.represtativearea2}",

                                    style: TextStyle(font: ttf, fontSize: 20),textDirection: TextDirection.rtl),
                                SizedBox(width: 50),
                                Text("$area1 ${currentrepresentative.represtativearea1}",

                                    style: TextStyle(font: ttf, fontSize: 20),textDirection: TextDirection.rtl),
                                SizedBox(width: 30),
                                Text("المناطق",style: TextStyle(font: ttf, fontSize: 20),textDirection: TextDirection.rtl),
                              ]
                          ),
                          SizedBox(height: 30),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(width: 30),
                                Text("$area4 ${currentrepresentative.represtativearea4}",

                                    style: TextStyle(font: ttf, fontSize: 20),textDirection: TextDirection.rtl),
                                SizedBox(width: 100),
                                Text("$area3 ${currentrepresentative.represtativearea3}",

                                    style: TextStyle(font: ttf, fontSize: 20),textDirection: TextDirection.rtl),
                                SizedBox(width: 30),
                                Text("-------",style: TextStyle(color: PdfColors.white,font: ttf, fontSize: 20),textDirection: TextDirection.rtl),

                              ]
                          ),
                        ]
                    ),


                    SizedBox(height: 30),
                    Text("اسم المشرف   -: ${currentrepresentative.represtativesupervisor}",

                        style: TextStyle(font: ttf, fontSize: 20),textDirection: TextDirection.rtl),
                    SizedBox(height: 30),
                    Text("اسم مدير البيع   -: ${currentrepresentative.represtativemanager}",

                        style: TextStyle(font: ttf, fontSize: 20),textDirection: TextDirection.rtl),
                  ]
              ));
        }));
  });
  saveAndLaunchFile(await pdf.save(),'بيانات المندوب.pdf');

}
