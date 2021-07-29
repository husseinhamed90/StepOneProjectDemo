import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:steponedemo/Models/Order.dart';
import 'package:steponedemo/Models/Sellingpolicy.dart';
import 'package:steponedemo/OrdersCubit/OrderServicesAPIs.dart';
import 'package:steponedemo/OrdersCubit/ordersStates.dart';
import '../Helpers/Utilites.dart';
//import 'PolicyCubitState.dart';

class ordersCubit extends Cubit<ordersStates> {
  ordersCubit() : super(initialState());

  File PolicyImage,mainimage;
  File PolicyDocumentFile;
  List<Sellingpolicy> polices = [];
  final picker = ImagePicker();
  CollectionReference collection = FirebaseFirestore.instance.collection('Orders');
  List<Order>orders=[];
  File OrderImage;
  File Ordermainimage;
  File OrderDocumentFile;

  void updateimagestate(File newfile){
    OrderImage=null;
    OrderDocumentFile=newfile;
    emit(documentcome());
  }
  Future getOrdersImagefromSource(ImageSource source,File file) async {
    OrderDocumentFile=null;
    final pickedFile = await picker.getImage(
        source: source, preferredCameraDevice: CameraDevice.rear);
    if (pickedFile != null) {
      file = File(pickedFile.path);
      OrderImage=file;
      emit(imageiscome());
    } else {}
  }
  void ReturnPercentageState(double percentage){
    emit(fileisuploadingprogress(percentage));
  }
  void ReturnEndingProcessState(){
    emit(PolicyisEndinguploading());
  }
  Future getMainImagefromSourse(ImageSource source,File file) async {
    final pickedFile = await picker.getImage(
        source: source, preferredCameraDevice: CameraDevice.rear);
    if (pickedFile != null) {
      file = File(pickedFile.path);
      mainimage=file;
      emit(imageiscome());
    } else {}
  }
  void ReturnfileisdownloadedState(){
    emit(fileisdownloaded());
  }
  void Returndownloadinprogressstate(int percentage){
    emit(downloadinprogressstate(percentage));
  }

  static ordersCubit get(BuildContext context) => BlocProvider.of(context);

  void loadfile(String url,String extention,String title){
    emit(loadfilefromfirebase());
    launchURL(url,extention,title,this).then((value) {
      emit(fileisdownloaded());
    });
  }

  void ReturnUpdateProcessEnded(){
    emit(OrderIsUpdated());
  }
  void ReturnLoadingState(){
    emit(loaddatafromfirebase());
  }

  Future<void>editOrder(Order order,TextEditingController title)async{
    if(OrderImage!=null){
      UploadImage("Update",OrderImage, order, collection, this);
    }
    else if(OrderDocumentFile!=null){
      UploadImage("Update",OrderDocumentFile, order, collection, this);
    }
    else{
      UpdateItem(order,collection,this);
    }
  }
  Future<void> deletOrders(Order order)async{
    emit(loaddatafromfirebase());
    await OrderServicesAPIs.DeleteOrderApi(order);
    await getOrders();
  }


  Future<void> addnewOrders(Order order, TextEditingController title,) async {
    if (order.title == "") {
      emit(emptystringfoundinpolicydata());
    }
    else {
      if(OrderImage==null&&OrderDocumentFile==null){
        emit(Policyisuploading());
        order.date = getDateWithoutTime();
        order.extention="png";
        order.mainimagepath="https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";
        order.defauktphoto="https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";
        order.path = "https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";
        await OrderServicesAPIs.AddOrderToFireBase(order);
        title.text = "";
        await getOrders();
      }
      else{
        if(OrderDocumentFile!=null){
          UploadFileToServer("Insert",OrderDocumentFile,this,order,collection,orders,typeoflist: "order",mainimage: null);
        }
        else if(OrderImage!=null){
          UploadFileToServer("Insert",OrderImage,this,order,collection,orders,typeoflist: "order",mainimage: null);
        }
      }
    }
  }

  Future<void>getOrders()async {
    emit(loaddatafromfirebase());
    orders = [];
    OrderDocumentFile = null;
    Ordermainimage=null;
    OrderImage=null;
    QuerySnapshot querySnapshot =await OrderServicesAPIs.GetOrdersFromBase();
    querySnapshot.docs.forEach((doc) {
      orders.add(Order.fromJson(doc.data()));
    });
    emit(Ordersloaded());
  }
}