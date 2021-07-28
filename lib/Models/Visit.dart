import 'package:steponedemo/Models/Client.dart';

class visit{

  Client visitOwner;
  String TypeofWork;
  String reasonforvisit;
  String clintID;
  String dateofnextvisit;
  String dayofnextvisit;
  String Visitid;
  String NextVisitID;
  String dateOfCurrentVisit;
  String dayOfCurrentVisit;
  String hourofvisit;
  String typeofclock;
  String reprsenatativrID;

  visit(
      this.reasonforvisit,
      this.dateofnextvisit,
      this.dayofnextvisit,
      this.dateOfCurrentVisit,
      this.dayOfCurrentVisit,
      this.TypeofWork,
      this.hourofvisit,
      this.typeofclock,
      this.reprsenatativrID);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['visitOwner'] = this.visitOwner.toJson();
    data['reasonforvisit'] = this.reasonforvisit;
    data['clintID']=this.clintID;
    data['dateofnextvisit']=this.dateofnextvisit;
    data['dayofnextvisit']=this.dayofnextvisit;
    data['dateOfCurrentVisit']=this.dateOfCurrentVisit;
    data['dayOfCurrentVisit']=this.dayOfCurrentVisit;
    data['TypeofWork']=this.TypeofWork;
    data['VisitID']=this.Visitid;
    data['NextVisitID']=this.NextVisitID;
    data["hourofvisit"]=this.hourofvisit;
    data["typeofclock"]=this.typeofclock;
    data['reprsenatativrID']=this.reprsenatativrID;
    return data;
  }

  visit.fromJson(Map<String, dynamic> json) {
    this.visitOwner=Client.fromJson(json['visitOwner']);
    this.reasonforvisit=json['reasonforvisit'];
    this.clintID= json['clintID'];
    this.Visitid=json['VisitID'];
    this.TypeofWork=json['TypeofWork'];
    this.NextVisitID=json['NextVisitID'];
    this.dateofnextvisit= json['dateofnextvisit'];
    this.dayofnextvisit=json["dayofnextvisit"];
    this.dateOfCurrentVisit= json['dateOfCurrentVisit'];
    this.dayOfCurrentVisit=json["dayOfCurrentVisit"];
    this.hourofvisit=json['hourofvisit'];
    this.typeofclock=json['typeofclock'];
    this.reprsenatativrID=json['reprsenatativrID'];
  }
}