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

Future<void> saveAndLaunchFile(
  List<int> bytes,
  String fileName,
) async {
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

Future DisplayOrdersInPdf() {}
Future savePdf(Representative currentrepresentative) async {
  ArabicNumbers arabicNumber = ArabicNumbers();
  String arabicphone = "";
  String represtativecode = "";
  String represtativetarget = "";

  arabicphone = convertEnglishNumberToArabic(
      currentrepresentative, arabicphone, arabicNumber);
  represtativecode = convertEnglishNumberToArabic(
      currentrepresentative, represtativecode, arabicNumber);
  represtativetarget = convertEnglishNumberToArabic(
      currentrepresentative, represtativetarget, arabicNumber);

  final Document pdf = Document();
  final fontData = await rootBundle.load("assetsfont/fonts/arial.ttf");
  final ttf = Font.ttf(fontData.buffer.asByteData());
  String area1 = "المنطقة  ${arabicNumber.convert(1)} :";
  String area2 = "المنطقة  ${arabicNumber.convert(2)} :";
  String area3 = "المنطقة  ${arabicNumber.convert(3)} :";
  String area4 = "المنطقة  ${arabicNumber.convert(4)} :";
  String clintpicature = "";
  print(arabicphone);
  await networkImageToBase64(currentrepresentative.path).then((value) {
    clintpicature = value;
  });
  await networkImageToBase64(
          "https://firebasestorage.googleapis.com/v0/b/stepone-a6e15.appspot.com/o/logo.jpg?alt=media&token=1268eff8-d87e-4f0a-a3ce-cc987f523eca")
      .then((value) {
    pdf.addPage(Page(
        theme: ThemeData.withFont(
          base: ttf,
        ),
        pageFormat: PdfPageFormat.a4,
        build: (Context context) {
          Uint8List bytes = base64Decode(clintpicature);
          return buildPdfPage(
              ttf,
              bytes,
              currentrepresentative,
              represtativecode,
              arabicphone,
              represtativetarget,
              area2,
              area1,
              area4,
              area3);
        }));
  });
  saveAndLaunchFile(await pdf.save(), 'بيانات المندوب.pdf');
}

Container buildPdfPage(
    Font ttf,
    Uint8List bytes,
    Representative currentrepresentative,
    String represtativecode,
    String arabicphone,
    String represtativetarget,
    String area2,
    String area1,
    String area4,
    String area3) {
  return Container(
      alignment: Alignment.topRight,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(
            alignment: Alignment.center,
            child: Column(children: [
              Text("بيانات المندوب",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      font: ttf,
                      fontSize: 20,
                      color: PdfColor.fromInt(1)),
                  textDirection: TextDirection.rtl),
              Container(
                height: 2,
                width: 200,
              ),
            ])),
        buildCompanyInfoSection(bytes, currentrepresentative, ttf),
        SizedBox(height: 20),
        Container(
            width: PdfPageFormat.a4.width, color: PdfColors.black, height: 1),
        SizedBox(height: 20),
        buildRowWithRepresentativeNumberAndRepresentativeName(
            currentrepresentative, ttf, represtativecode),
        SizedBox(height: 30),
        buildCustomText(
            currentrepresentative, ttf, "رقم التليفون   -:  $arabicphone"),
        SizedBox(height: 30),
        buildCustomText(currentrepresentative, ttf,
            "التارجت   -: $represtativetarget جنيها"),
        SizedBox(height: 30),
        Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          buildRowWithTwoAreas(
              "$area2 ${currentrepresentative.represtativearea2}",
              currentrepresentative,
              ttf,
              "$area1 ${currentrepresentative.represtativearea1}",
              "مناطق"),
          SizedBox(height: 30),
          buildRowWithTwoAreas(
              "$area4 ${currentrepresentative.represtativearea4}",
              currentrepresentative,
              ttf,
              "$area3 ${currentrepresentative.represtativearea3}",
              "       "),
        ]),
        SizedBox(height: 30),
        buildCustomText(currentrepresentative, ttf,
            "اسم المشرف   -: ${currentrepresentative.represtativesupervisor}"),
        SizedBox(height: 30),
        buildCustomText(currentrepresentative, ttf,
            "اسم مدير البيع   -: ${currentrepresentative.represtativemanager}"),
      ]));
}

Row buildCompanyInfoSection(Uint8List bytes, Representative currentrepresentative, Font ttf) {
  return Row(children: [
    Container(
        height: 120,
        width: 150,
        decoration: BoxDecoration(
            image:
                DecorationImage(image: MemoryImage(bytes), fit: BoxFit.fill))),
    Spacer(),
    Column(children: [
      SizedBox(height: 20),
      buildCustomText(currentrepresentative, ttf,
          "اسم الشركة   -:  ${currentrepresentative.companyname}"),
      SizedBox(height: 20),
      buildCustomText(currentrepresentative, ttf,
          "عنوان الشركة   -:  ${currentrepresentative.companyaddress}"),
      SizedBox(height: 20),
      buildCustomText(currentrepresentative, ttf,
          "تليفون الشركة   -:  ${currentrepresentative.companyphone}"),
    ]),
  ]);
}

Row buildRowWithRepresentativeNumberAndRepresentativeName(Representative currentrepresentative, Font ttf, String represtativecode) {
  return Row(children: [
    buildCustomText(
        currentrepresentative, ttf, "كود المندوب   -: $represtativecode"),
    Spacer(),
    buildCustomText(currentrepresentative, ttf,
        "اسم المندوب   -: ${currentrepresentative.represtativename}"),
  ]);
}

Row buildRowWithTwoAreas(String area2, Representative currentrepresentative, Font ttf, String area1, String firstWordInRow) {
  return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
    SizedBox(width: 30),
    buildCustomText(currentrepresentative, ttf, area2),
    SizedBox(width: 50),
    buildCustomText(currentrepresentative, ttf, area1),
    SizedBox(width: 30),
    Text(firstWordInRow,
        style: TextStyle(font: ttf, fontSize: 20),
        textDirection: TextDirection.rtl),
  ]);
}

Text buildCustomText(Representative currentrepresentative, Font ttf, String text) {
  return Text(text,
      style: TextStyle(font: ttf, fontSize: 20),
      textDirection: TextDirection.rtl);
}

String convertEnglishNumberToArabic(Representative currentrepresentative, String arabicphone, ArabicNumbers arabicNumber) {
  for (int i = 0; i < currentrepresentative.represtativenphone.length; i++) {
    arabicphone +=
        arabicNumber.convert(currentrepresentative.represtativenphone[i]);
  }
  return arabicphone;
}
