import 'package:steponedemo/Models/TRProdct.dart';

class brand {
  String brandname;
  String prandcode,path;
  String id;
  String excelfilepath;
  List<TrProduct>products;
      //numberofproducts="0";

  brand(
     [ this.brandname="",
      this.prandcode="",
     this.path]
      );


  brand.fromJson(Map<String, dynamic> json) {
    brandname = json['brandname'];
    prandcode = json['brandcode'];
    path= json['path'];
    id=json['id'];
    excelfilepath=json['excelfilepath'];
    List<TrProduct> gg=[];
    List<dynamic>hh=json['products'];
    hh.forEach((element) {
      gg.add(TrProduct.fromJson(element));
    });

    products=gg;
   // numberofproducts=json['numberofproducts'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['brandname'] = this.brandname;
    data['brandcode'] = this.prandcode;
    data['path']=this.path;
    data['id']=this.id;
    data['excelfilepath']=this.excelfilepath;
    List< Map<String, dynamic>> gg=[];
    this.products.forEach((element) {
      gg.add(element.toJson());
    });
    data['products']=gg;
  //  data['numberofproducts']=this.numberofproducts;
    return data;
  }
}