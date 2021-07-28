import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:steponedemo/Models/Order.dart';

class OrderServicesAPIs{

  static Future<void>DeleteOrderApi(Order order)async{
    CollectionReference collection = FirebaseFirestore.instance.collection('Orders');

    return await collection.where("id", isEqualTo: order.id).get().then((value) {
      collection.doc(value.docs.first.id).delete();
    });
  }

  static Future<QuerySnapshot>GetOrdersFromBase()async{
    CollectionReference collection = FirebaseFirestore.instance.collection('Orders');

    return await collection.get();
  }

  static Future<void>AddOrderToFireBase(Order order)async{
    CollectionReference collection = FirebaseFirestore.instance.collection('Orders');
    return await collection.add(order.toJson()).then((value) {
      order.id = value.id;
      collection.doc(value.id).update({'id': value.id});
    }).catchError((error) => print("Failed to add new: $error"));
  }
}