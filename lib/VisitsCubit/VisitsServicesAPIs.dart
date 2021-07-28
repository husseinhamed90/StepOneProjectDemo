import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:steponedemo/Models/Visit.dart';

class VisitsServicesAPIs{

  static Future<DocumentReference>AddNewVisitInFireBase(visit newvisit)async{
    return await FirebaseFirestore.instance.collection("Visits").add(newvisit.toJson());
  }
  static Future<void>UpdateVisitId(String visitid)async{
    return await  FirebaseFirestore.instance.collection("Visits").doc(visitid).update({
      "VisitID":visitid
    });
  }
  static Future<void>UpdateNextVisitOfCurrentVisit(String visitid,DocumentReference nextvisitid)async{
    return await  FirebaseFirestore.instance.collection("Visits").doc(visitid).update({
      "NextVisitID":nextvisitid.id
    });
  }
  static Future<void>UpdateDateOfCurrentVisit(String visitid,visit newvisit)async{
    return await FirebaseFirestore.instance.collection("Visits").doc(visitid).update({
      "dateofnextvisit":newvisit.dateOfCurrentVisit,'dayofnextvisit':newvisit.dayOfCurrentVisit
    });
  }
  static Future<void> UpdateVisitInFireBase(String visitId ,visit newvisit)async{
    return await FirebaseFirestore.instance.collection("Visits").doc(visitId).update(newvisit.toJson());
  }
  static Future<void> DeleteVisitFromFireBase(String  id,String date)async{
    return await FirebaseFirestore.instance.collection("Visits").doc(id).delete();
  }
  static Future<void>UpdateWorkTypeInFireBase(String typeofwork,QueryDocumentSnapshot element)async{
    return await FirebaseFirestore.instance.collection('Visits').doc(visit.fromJson(element.data()).Visitid).update({
      "TypeofWork":typeofwork
    });
  }
  static Future<QuerySnapshot> GetVisits(String id)async{
    return await FirebaseFirestore.instance.collection("Visits").where("reprsenatativrID",isEqualTo: id).get();
  }
}