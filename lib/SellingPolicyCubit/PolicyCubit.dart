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
    PolicyDocumentFile=newfile;
    emit(documentcome());
  }

  Future getMainImagefromSourse(ImageSource source,File file) async {
    final pickedFile = await picker.getImage(
        source: source, preferredCameraDevice: CameraDevice.rear);
    if (pickedFile != null) {
      file = File(pickedFile.path);
      PolicyImage=file;
      emit(imageiscome());
    } else {}
  }
  void ReturnUpdateProcessEnded(){
    emit(Policyloaded());
  }


  Future<void>editOrder(Sellingpolicy order,TextEditingController title)async{
    if(PolicyImage!=null){
      UploadImage("Update",PolicyImage, order, collection, this);
    }
    else if(PolicyDocumentFile!=null){
      UploadImage("Update",PolicyDocumentFile, order, collection, this);
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
    polices = [];
    PolicyDocumentFile = null;
    mainimage=null;
    PolicyImage=null;
    emit(loaddatafromfirebase());
    collection.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        polices.add(Sellingpolicy.fromJson(doc.data()));
      });
      emit(policesloaded());
    });
  }

  Future<void> addnewsellingpolicy(Sellingpolicy newsellingpolicy, TextEditingController title,) async {

    if (newsellingpolicy.title == "") {
      emit(emptystringfoundinpolicydata());
    }
    else {
      if(PolicyImage==null&&PolicyDocumentFile==null){
        emit(Policyisuploading());
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
      else{
        if(PolicyDocumentFile!=null){
          print("PolicyDocumentFile");
          UploadFileToServer("Insert",PolicyDocumentFile,this,newsellingpolicy,collection,polices,typeoflist: "policy",mainimage: null);
        }
        else if(PolicyImage!=null){
          print("PolicyImage");
          UploadFileToServer("Insert",PolicyImage,this,newsellingpolicy,collection,polices,typeoflist: "policy",mainimage: null);
        }
      }
    }
  }
  Future getImagefromSourse(ImageSource source,File file) async {
    final pickedFile = await picker.getImage(
        source: source, preferredCameraDevice: CameraDevice.rear);
    if (pickedFile != null) {
      file = File(pickedFile.path);
      PolicyImage=file;
      emit(imageiscome());
    } else {}
  }

  void ReturnPercentageState(double percentage){
    emit(fileisuploadingprogress(percentage));
  }
  void ReturnEndingProcessState(){
    emit(PolicyisEndinguploading());
  }
}