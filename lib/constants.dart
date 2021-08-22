import 'package:flutter/services.dart';

String worktype = 'غير محدد';
var typesofwork =  ['غير محدد','عمل من الشركة','عمل من الخارج','سفر','اجازة رسمية','اجازة من الرصيد','اجازة مرضية','اجازة مخصومة من الراتب'];
var reasons = [
  'عمل اوردر','تحصيل','تحصيل و عمل اوردر','تحصيل شيك مرتد','زيارة دورية','العميل غير متواجد',
  'تم تأجيل عمل الوردر','تم تأجيل التحصيل','عرض المنتجات للعميل','الاتصال تليفونيا لتحديد ميعاد',
  'مقابلة ادارة المشتريات','الاتفاق علي عقد مع العميل','تقفيل فواتير مع العميل','اخذ ميعاد للتحصيل',
  'اخذ مرتجعات','غير محدد'
];
List<String>listOfTypes=['غير محدد','قطاعي','جملة','عقد',];
List<String> hours =['غير محدد','1','1:30','2','2:30','3','3:30','4','4:30','5','5:30','6','6:30','7','7:30','8','8:30','9','9:30','10','10:30','11','11:30','12','12:30'];
var clocktypes=['غير محدد','م','ص'];
const channel = MethodChannel('service');

List<String> images = [
'assets/representativedata.jpeg',
'assets/customersdata.jpeg',
'assets/agenda.jpeg',
'assets/calculator.jpeg',
'assets/catalog.jpeg',
'assets/makeOrder.jpeg',
'assets/policysell.jpeg',
'assets/orders.jpeg',
'assets/contactusv.jpeg',
'assets/reportsmainscreen.jpeg',
'assets/News.jpeg',
'assets/newuser.jpeg'
];

List<String> names = [
'بيانات المندوب',
'بيانات العملاء',
'مواعيد الزيارات',
'الة حاسبة',
'كتالوج',
'عمل اورد',
'السياسة البيعية',
'احدث جرد',
'اتصل بنا',
'التقارير',
'اخر الاخبار',
'اضافة مستخدم'
];