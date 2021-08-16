import 'package:steponedemo/Models/TRProdct.dart';

class brand {
  String brandname;
  String prandcode,path;
  String id,orderedFile;
  String excelfilepath;
  List<TrProduct>products=[];
  List<TrProduct>orderedProducts=[];

  brand(
     [ this.brandname="",
       this.prandcode="",
       this.path]
      );


  brand.fromJson(Map<String, dynamic> json) {
    brandname = json['brandname'];
    prandcode = json['brandcode'];
    path= json['path'];
    orderedFile=json['orderedFile'];
    id=json['id'];
    excelfilepath=json['excelfilepath'];
    List<TrProduct> gg=[];
    List<dynamic>hh=json['products'];
    hh.forEach((element) {
      gg.add(TrProduct.fromJson(element));
    });
    products=gg;

    List<TrProduct> orderedProductse=[];
    List<dynamic>ordered=json['OrderedProducts'];
    ordered.forEach((element) {
      orderedProductse.add(TrProduct.fromJson(element));
    });
    orderedProducts=orderedProductse;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['brandname'] = this.brandname;
    data['brandcode'] = this.prandcode;
    data['path']=this.path;
    data['id']=this.id;
    data['orderedFile']=this.orderedFile;
    data['excelfilepath']=this.excelfilepath;
    List< Map<String, dynamic>> gg=[];
    this.products.forEach((element) {
      gg.add(element.toJson());
    });
    data['products']=gg;
    List< Map<String, dynamic>> ordered=[];
    this.orderedProducts.forEach((element) {
      ordered.add(element.toJson());
    });
    data['OrderedProducts']=ordered;
    return data;
  }
}