import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:steponedemo/Helpers/Utilites.dart';
import 'package:steponedemo/Models/Client.dart';
import 'package:steponedemo/Models/Visit.dart';
import 'package:steponedemo/VisitsCubit/VisitsCubitStates.dart';
import 'package:steponedemo/VisitsCubit/VisitsServicesAPIs.dart';
class VisitsCubit extends Cubit<VisitsCubitStates>{
  List<Client> suggestionresultForVisit = [];
  List<visit> visits = [];
  Client choosenclientForVisit;
  bool foucesstateForVisitSearchBar=false;

  VisitsCubit() : super(initialState());
  static VisitsCubit get(BuildContext context) => BlocProvider.of(context);


  void setChoosenClientForVisit(Client client) {
    choosenclientForVisit = client;
    emit(choosenclientState());
  }
  void resetClintForVisit(){
    suggestionresultForVisit=[];
    foucesstateForVisitSearchBar=false;
    emit(resetsearchbarState());
  }

  void changesuggestionresultListOfVisit(String searchedstring, List<Client> clients) {
    suggestionresultForVisit = [];
    clients.forEach((e) {
      if (e.clientname.contains(searchedstring)||e.clientcode.contains(searchedstring)){
        suggestionresultForVisit.add(e);
      }
    });
    emit(newSearchsugestionlist());
  }
  void textfroemfoucesstateForVistSerachBar(bool b) {
    foucesstateForVisitSearchBar = b;
    emit(tetxformfoucesStateForVisit());
  }

  Future<void>Deletevisit(visit deletedvisit,String date)async{
    await VisitsServicesAPIs.DeleteVisitFromFireBase(deletedvisit.Visitid,date);
    print("done 2");
    GetVisitsOfUser(deletedvisit.reprsenatativrID,date);
  }

  visit setdataofNewVisit(visit newvisit){
    newvisit.clintID=choosenclientForVisit.ClientID;
    newvisit.visitOwner=choosenclientForVisit;
    return newvisit;
  }
  visit generateNextVisit(visit newvisit){
    visit nextvisit =visit(newvisit.reasonforvisit,"غير محددة", "غير محددة",
        newvisit.dateofnextvisit, newvisit.dayofnextvisit, "غير محدد", "غير محدد", "غير محدد", newvisit.reprsenatativrID);
    nextvisit.clintID=choosenclientForVisit.ClientID;
    nextvisit.visitOwner=choosenclientForVisit;
    return nextvisit;
  }

  void AddNewVisit(visit newvisit,String date)async{
    if(choosenclientForVisit!=null){
      emit(AddingVisitInProgress());
      newvisit = setdataofNewVisit(newvisit);
      visit nextvisit = generateNextVisit(newvisit);
      DocumentReference visitid =await VisitsServicesAPIs.AddNewVisitInFireBase(newvisit);
      print("adding done");
      print(visitid.id);
      await VisitsServicesAPIs.UpdateVisitId(visitid.id);
      DocumentReference nextvisitid =await VisitsServicesAPIs.AddNewVisitInFireBase(nextvisit);
      await VisitsServicesAPIs.UpdateVisitId(nextvisitid.id);
      await VisitsServicesAPIs.UpdateNextVisitOfCurrentVisit(visitid.id,nextvisitid);
      choosenclientForVisit=null;
      emit(VisitAddedSuccssufully());
      GetVisitsOfUser(newvisit.reprsenatativrID,date);
    }
    else{
      emit(nochoosenclientForVisit());
    }
  }

  visit SetVisitClientOwner(visit newvisit,visit oldvisit){
    if(choosenclientForVisit!=null){
      newvisit.clintID=choosenclientForVisit.ClientID;
      newvisit.visitOwner=choosenclientForVisit;
    }
    else{
      newvisit.clintID=oldvisit.visitOwner.ClientID;
      newvisit.visitOwner=oldvisit.visitOwner;
    }
    newvisit.Visitid=oldvisit.Visitid;
    return newvisit;
  }

  void UpdateVisit(visit newvisit,String date,visit oldvisit)async{
    emit(UpdatingVisitInProgress());
    newvisit =SetVisitClientOwner(newvisit,oldvisit);
    if(newvisit.dateofnextvisit!=oldvisit.dateofnextvisit){
      visit nextviswit =visit(newvisit.reasonforvisit,"غير محددة", "غير محددة", newvisit.dateofnextvisit, newvisit.dayofnextvisit, "غير محدد", "غير محدد", "غير محدد", newvisit.reprsenatativrID);
      nextviswit.clintID=newvisit.clintID;
      nextviswit.visitOwner=newvisit.visitOwner;
      await VisitsServicesAPIs.DeleteVisitFromFireBase(oldvisit.NextVisitID, date);
      DocumentReference documentReference =await VisitsServicesAPIs.AddNewVisitInFireBase(nextviswit);
      await VisitsServicesAPIs.UpdateVisitId(documentReference.id);
      await VisitsServicesAPIs.UpdateDateOfCurrentVisit(newvisit.Visitid, nextviswit);
      await VisitsServicesAPIs.UpdateNextVisitOfCurrentVisit(newvisit.Visitid, documentReference);
    }
    else{
      newvisit.dateofnextvisit=oldvisit.dateofnextvisit;
      newvisit.dayofnextvisit=oldvisit.dayofnextvisit;
      await VisitsServicesAPIs.UpdateVisitInFireBase(oldvisit.Visitid,newvisit);
    }
    choosenclientForVisit=null;
    emit(VisitAddedSuccssufully());
    GetVisitsOfUser(newvisit.reprsenatativrID,date);
  }

  Future<void> GetVisitsOfUser(String id,String date)async{
    visits=[];
    emit(RetrivingVisitsInProgress());
    QuerySnapshot value=await VisitsServicesAPIs.GetVisits(id);
    value.docs.forEach((element) {
      if(visit.fromJson(element.data()).dateOfCurrentVisit==date){
        visits.add(visit.fromJson(element.data()));
      }
    });
    visits= groupVisitsByTypeOfClock(visits);
    visits.sort((a, b) => a.hourofvisit.compareTo(b.hourofvisit));
    emit(LoadVisitsDone(visits));
    if(visits.isEmpty){
      emit(novisitsfoundState());
    }
    else{
      emit(LoadVisitsOfSelectedDateIsDone(visits));
    }
  }
  Future<void> updateworktypetovisits(String id,String date,String typeofwork)async{
    emit(RetrivingVisitsInProgress());
    QuerySnapshot value=await VisitsServicesAPIs.GetVisits(id);
    value.docs.forEach((element) async {
      if(visit.fromJson(element.data()).dateOfCurrentVisit==date){
        await VisitsServicesAPIs.UpdateWorkTypeInFireBase(typeofwork, element);
      }
    });
    await GetVisitsOfUser(id,date);
  }
}