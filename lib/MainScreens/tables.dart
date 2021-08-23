import 'dart:convert';
import 'dart:io';
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:steponedemo/Helpers/Utilites.dart';
import 'package:steponedemo/ClientsCubit/ClientsCubit.dart';
import 'package:steponedemo/Models/Representative.dart';
import 'package:steponedemo/Models/UserOrder.dart';
import 'package:steponedemo/Models/Visit.dart';

Future saveTableToPdf(Representative currentrepresentative,String pdfName,{UserOrder userOrder,ClientsCubit clientsCubit,List<visit>visits,String typeofwork,String choosendate,String dayofdate}) async {
  final Document pdf = Document();
  Font ttf = await generateFontType();
  List<TableRow>rows = buildTableRows(pdfName,ttf,clientsCubit: clientsCubit, userOrder: userOrder,visits: visits);
  buildPdfPage(rows, pdfName, pdf, ttf, currentrepresentative, userOrder: userOrder,visits: visits,choosendate: choosendate,dayofdate: dayofdate,typeofwork: typeofwork);
  saveAndLaunchFile(await pdf.save(),pdfName);
}
////////////////////////////////////////////////////////////

void buildPdfPage(List<TableRow>rows,String pdfName, Document pdf, Font ttf, Representative currentRepresentative, {UserOrder userOrder,List<visit>visits,String typeofwork,String choosendate,String dayofdate}) {
  List<List<TableRow>> pages=chunk(rows, 18);
  for(int i=0;i<pages.length;i++){
    if(pdfName=='بيانات العملاء.pdf'){
      buildClientsPage(pdf, ttf, currentRepresentative, pages, i);
    }
    else if(pdfName=='بيانات الاوردر.pdf'){
      buildOrdersPage(pdf, ttf, i, userOrder, currentRepresentative,pages);
    }
    else if(pdfName =='زياراتي.pdf'){
      buildVisitPage(pdf, ttf, currentRepresentative, typeofwork, dayofdate, choosendate, rows, visits,pages,i);
    }
  }
}
List<TableRow> buildTableRows(String pdfName,Font ttf,{ClientsCubit clientsCubit, UserOrder userOrder,List<visit>visits}) {
  List<TableRow>rows=[];
  if(pdfName=='بيانات العملاء.pdf'){
    rows = buildRowsOfClients(clientsCubit, ttf);
  }
  else if(pdfName=='بيانات الاوردر.pdf'){
   rows=buildOrdersRows(ttf, userOrder);
  }
  else if(pdfName =='زياراتي.pdf'){
    rows=buildVisitsRows(ttf, visits);
  }
  return rows;
}

////////////////////////////////////////////////////////////

List<TableRow> buildRowsOfClients(ClientsCubit appprovider, Font ttf) {

  ArabicNumbers arabicNumber = ArabicNumbers();
  List<TableRow> rows=[];
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
    )
    );
  }
  return rows;
}
List<TableRow> buildVisitsRows(Font ttf, List<visit> visits) {
  ArabicNumbers arabicNumber = ArabicNumbers();
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

  return rows;
}
List<TableRow> buildOrdersRows(Font ttf, UserOrder userOrder) {
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
  return rows;
}

////////////////////////////////////////////////////////////

void buildClientsPage(Document pdf, Font ttf, Representative currentRepresentative, List<List<TableRow>> pages, int i) {
  pdf.addPage(Page(
      theme: ThemeData.withFont(
        base: ttf,
      ),
      pageFormat: PdfPageFormat.a4,
      orientation: PageOrientation.landscape,
      build: (Context context) {
        return Container(
            alignment: Alignment.topRight,
            child:Column (
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Center(
                    child:  Text("بيانات العملاء للمندوب : ${currentRepresentative.represtativename}",style:  TextStyle(font: ttf, fontSize: 15),textDirection: TextDirection.rtl),
                  ),
                  SizedBox(height: 20),
                  Table(
                      border: TableBorder.all(),
                      children: pages[i]
                  ),
                ]
            ));
      }));
}
void buildOrdersPage(Document pdf, Font ttf, int i, UserOrder userOrder, Representative representative, List<List<TableRow>> pages) {
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

                  (i==0)?Column(
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
                      ]
                  ):Container(),
                  SizedBox(height: 20),
                  Table(
                      border: TableBorder.all(),
                      children: pages[i]
                  ),
                ]
            ));
      }));
}
void buildVisitPage(Document pdf, Font ttf, Representative representative, String typeofwork, String dayofdate, String choosendate, List<TableRow> rows, List<visit> visits,List<List<TableRow>> pages,int i) {
  pdf.addPage(Page(
      theme: ThemeData.withFont(
        base: ttf,
      ),
      pageFormat: PdfPageFormat.a4,
      orientation: PageOrientation.portrait,
      build: (Context context) {
        return Container(
            alignment: Alignment.topLeft,
            child:Column (
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  buildRepresentativeInformation(representative, ttf, typeofwork),
                  SizedBox(height: 20),
                  buildVisitsOfCurrentDay(dayofdate, ttf, choosendate),
                  SizedBox(height: 20),
                  buildTableOfVisits(pages[i]),
                  SizedBox(height: 20),
                  (i==pages.length-1)?buildNumberOfVisitsInTheCurrentDay(ttf, visits):Container()
                ]
            ));
      }));
}


Row buildNumberOfVisitsInTheCurrentDay(Font ttf, List<visit> visits) {
  return Row(
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
                              Text(" زيارات ",style:  TextStyle(font: ttf, fontSize: 20),textDirection: TextDirection.rtl),
                              Text(visits.length.toString(),style:  TextStyle(font: ttf, fontSize: 20),textDirection: TextDirection.rtl),
                              Text("عدد الزيارات  :  ",style:  TextStyle(font: ttf, fontSize: 20),textDirection: TextDirection.rtl),
                            ]
                        ),

                      )
                    ]
                );
}
Table buildTableOfVisits(List<TableRow> rows) {
  return Table(
      border: TableBorder.all(),
      children: rows
  );
}
Row buildVisitsOfCurrentDay(String dayofdate, Font ttf, String choosendate) {
  return Row(
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
  );
}
Row buildRepresentativeInformation(Representative representative, Font ttf, String typeofwork) {
  return Row(
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
  );
}
