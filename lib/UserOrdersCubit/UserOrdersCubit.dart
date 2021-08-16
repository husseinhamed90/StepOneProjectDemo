import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:steponedemo/Models/Client.dart';
import 'package:steponedemo/Models/UserOrder.dart';
import 'package:steponedemo/UserOrdersCubit/UserOrdersCubitStates.dart';

class UserOrdersCubit extends Cubit<UserOrdersCubitStates>{

  List<UserOrder>myorders=[];

  UserOrdersCubit() : super(initialState());
  static UserOrdersCubit get(BuildContext context) => BlocProvider.of(context);

  Future getOrdersOfCurrentUser(String userid)async{
    myorders=[];
    emit(LoadOrdersInProgress());
    await FirebaseFirestore.instance.collection('ClientOrders').where("representativeID",isEqualTo: userid).get().then((value) {
      if(value.docs.isEmpty){
        emit(UserOrdersState());
      }
      else{

        value.docs.forEach((element) {
          if(element['OrderOwner']==""){
            UserOrder userOrder =UserOrder.fromJson(element.data());
            userOrder.OrderOwner=Client.noClient();
            myorders.add(userOrder);
          }
          else{
            FirebaseFirestore.instance.collection("Clients").doc(element['OrderOwner']).get().then((value) {

              UserOrder userOrder =UserOrder.fromJson(element.data());
              userOrder.OrderOwner=Client.fromJson(value.data());
              myorders.add(userOrder);
            }).then((value) {
              emit(UserOrdersState());
            }).catchError((error){
              emit(UserOrdersState());
            });
          }

        });
      }
    }).catchError((error){
    });

  }
  void deleteorderFromFireBase(UserOrder userOrder,String userid)async{
    emit(deleteingorderState());
    FirebaseFirestore.instance.collection("ClientOrders").doc(userOrder.location).delete().then((value) {
      getOrdersOfCurrentUser(userid);
    });
  }
}