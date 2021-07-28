import 'package:steponedemo/Models/TRProdct.dart';

class ShippedItem{
   TrProduct trProduct;
   int quantity=0;
   int bounce=0;
   double Discount_instead_of_bonus=0;
   double Discount_instead_of_adding=0;
   double specialDiscount=0;

   ShippedItem(
      this.trProduct,
      this.quantity,
      this.bounce,
      this.Discount_instead_of_bonus,
      this.Discount_instead_of_adding,
       this.specialDiscount);

   Map<String, dynamic> toJson() {
     final Map<String, dynamic> data = new Map<String, dynamic>();
     data['Product'] = this.trProduct.toJson();
     data['quantity'] = this.quantity;
     data['bounce']=this.bounce;
     data['Discount_instead_of_bonus']=this.Discount_instead_of_bonus;
     data['Discount_instead_of_adding']=this.Discount_instead_of_adding;
     data["specialDiscount"]=this.specialDiscount;
     return data;
   }

   ShippedItem.fromJson(Map<String, dynamic> json) {
     this.trProduct=TrProduct.fromJson(json['Product']);
     this.quantity=json['quantity'];
     this.bounce= json['bounce'];
     this.Discount_instead_of_bonus= json['Discount_instead_of_bonus'];
     this.Discount_instead_of_adding=json["Discount_instead_of_adding"];
     this.specialDiscount=json['specialDiscount'];
   }
}