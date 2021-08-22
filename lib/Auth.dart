import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:steponedemo/Models/Representative.dart';
import 'package:steponedemo/Models/User.dart';

class Auth {
  static Future<user> GetUserInfo(String id) async {
    DocumentSnapshot documentReference = await FirebaseFirestore.instance.collection('Users').doc(id).get();
    user currentUser = user.fromJson(documentReference.data());
    return currentUser;
  }

  static Future<QuerySnapshot> getRepresentative() async {
    CollectionReference representatives = FirebaseFirestore.instance.collection('Representatives');
    return await representatives.get();
  }

  static Future<Representative> getReprestatvieInfo(user currentUser) async {
    Representative representative;
    QuerySnapshot snapshot = await getRepresentative();
    snapshot.docs.forEach((doc) {
      if (Representative.fromJson(doc.data()).id == currentUser.id) {
        representative = Representative.fromJson(doc.data());
      }
    });
    return representative;
  }

  static Future<void> changeStateOfUser(user currentUser) async {
    return await FirebaseFirestore.instance.collection('Users').doc(currentUser.location).update({'isonline': "true"});
  }
}
