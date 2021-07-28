import 'package:steponedemo/Models/Client.dart';
import 'package:steponedemo/Models/Shippedtem.dart';

class UserOrder{
  List<ShippedItem>orderitems;
  String OrderOwnerID;
  Client OrderOwner;
  String dateodorder,location;
  UserOrder(this.orderitems, this.OrderOwnerID, this.dateodorder);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['OrderOwner'] = this.OrderOwnerID;
    data['date'] = this.dateodorder;
    data['location']=this.location;

    List< Map<String, dynamic>> gg=[];
    this.orderitems.forEach((element) {
      gg.add(element.toJson());
    });

    data['OrderItems']=gg;
    return data;
  }

  UserOrder.fromJson(Map<String, dynamic> json) {
    this.OrderOwnerID=json['OrderOwner'];
    this.dateodorder=json["date"];
    this.location=json['location'];
    List<ShippedItem>ggg=[];
    print("sfsdf");
    print( json['OrderItems'].runtimeType);
    json['OrderItems'].forEach((element) {
      ggg.add(ShippedItem.fromJson(element));
    });
    this.orderitems=ggg;

  }
}