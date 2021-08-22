import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:steponedemo/Models/Order.dart';
import 'package:steponedemo/Models/Sellingpolicy.dart';
import '../Helpers/Utilites.dart';
import 'PolicyCubitState.dart';

class PolicyCubit extends Cubit<PolicyCubitState> {
  PolicyCubit() : super(initialState());

  File PolicyImage,mainimage;
  File PolicyDocumentFile;
  List<Sellingpolicy> polices = [];
  final picker = ImagePicker();
  static PolicyCubit get(BuildContext context) => BlocProvider.of(context);

  CollectionReference collection =
  FirebaseFirestore.instance.collection('Sellingpolicy');

  void updateimagestate(File newfile){
    PolicyImage=null;
    PolicyDocumentFile=newfile;
    emit(documentcome());
  }

  void setImage(File file, {String typeofimage})async{
    PolicyDocumentFile=null;
    PolicyImage =file;
    emit(imageiscome());
  }

  Future getImagefromSourse(ImageSource source,File file) async {
    PolicyDocumentFile=null;
    final pickedFile = await picker.getImage(source: source, preferredCameraDevice: CameraDevice.rear);
    if (pickedFile != null) {
      file = File(pickedFile.path);
      PolicyImage=file;
      emit(imageiscome());
    }
  }
  void ReturnUpdateProcessEnded(){
    emit(Policyloaded());
  }


  Future<void>editOrder(Sellingpolicy order,TextEditingController title)async{
    if(PolicyImage!=null){
      UploadFile("Update",PolicyImage, order, collection, this);
    }
    else if(PolicyDocumentFile!=null){
      UploadFile("Update",PolicyDocumentFile, order, collection, this);
    }
    else{
      emit(Policyisuploading());
      UpdateItem(order,collection,this);
    }
  }
  void ReturnfileisdownloadedState(){
    emit(fileisdownloaded());
  }
  void Returndownloadinprogressstate(int percentage){
     emit(downloadinprogressstate(percentage));
  }

  void loadfile(String url,String extention,String title){
    emit(loadfilefromfirebase());
    launchURL(url,extention,title,this).then((value) {
      emit(fileisdownloaded());
    });
  }

  void ReturnLoadingState(){
    emit(loaddatafromfirebase());
  }

  Future<void>getpolices()async {
    resetPolicyFiles();
    emit(loaddatafromfirebase());
    collection.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        polices.add(Sellingpolicy.fromJson(doc.data()));
      });
      emit(policesloaded());
    });
  }

  void resetPolicyFiles() {
    polices = [];
    PolicyDocumentFile = null;
    mainimage=null;
    PolicyImage=null;
  }

  Future<void> addnewsellingpolicy(Sellingpolicy newsellingpolicy, TextEditingController title,) async {

    if (newsellingpolicy.title == "") {
      emit(emptystringfoundinpolicydata());
    }
    else {
      insertNewSellingPolicy(newsellingpolicy, title);
    }
  }

  void insertNewSellingPolicy(Sellingpolicy newsellingpolicy, TextEditingController title) {
     emit(Policyisuploading());
    if(PolicyImage==null&&PolicyDocumentFile==null){
      SellingPolicyWithoutFiles(newsellingpolicy, title);
    }
    else if(PolicyDocumentFile!=null){
      UploadFileToServer("Insert",PolicyDocumentFile,this,newsellingpolicy,collection,polices,typeoflist: "policy",mainimage: null);
    }
    else if(PolicyImage!=null){
      UploadFileToServer("Insert",PolicyImage,this,newsellingpolicy,collection,polices,typeoflist: "policy",mainimage: null);
    }
  }

  void SellingPolicyWithoutFiles(Sellingpolicy newsellingpolicy, TextEditingController title) {
    newsellingpolicy.date = getDateWithoutTime();
    newsellingpolicy.extention="png";
    newsellingpolicy.defauktphoto="https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";
    newsellingpolicy.path = "https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";
    collection.add(newsellingpolicy.toJson()).then((value) {
      newsellingpolicy.id = value.id;
      collection.doc(value.id).update({'id': value.id});
      title.text = "";
      getpolices();
    }).catchError((error) => print("Failed to add new: $error"));
  }

  void ReturnPercentageState(double percentage){
    emit(fileisuploadingprogress(percentage));
  }
  void ReturnEndingProcessState(){
    emit(PolicyisEndinguploading());
  }
}