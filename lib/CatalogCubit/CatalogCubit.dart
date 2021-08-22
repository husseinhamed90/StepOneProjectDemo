import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:steponedemo/Models/Catalog.dart';
import '../Helpers/Utilites.dart';
import 'package:steponedemo/CatalogCubit/CatalogStates.dart';

class CatalogCubit extends Cubit<CatalogStates>{
  CatalogCubit() : super(initialState());
  static CatalogCubit get(BuildContext context) => BlocProvider.of(context);

  File CatalogImage,mainimage;
  File pdfFile;
  final picker = ImagePicker();

  CollectionReference catalogcollection =
  FirebaseFirestore.instance.collection('Catalog');
  List<Catalog> Catalogs = [];

  Future getImagefromSourse(ImageSource source,File file) async {
    final pickedFile = await picker.getImage(
        source: source, preferredCameraDevice: CameraDevice.rear);
    if (pickedFile != null) {
      file = File(pickedFile.path);
      CatalogImage=file;
      emit(imageiscome());
    } else {}
  }
  void updateimagestate(File newfile){
    pdfFile=newfile;
    emit(documentcome());
  }

  void ReturnfileisdownloadedState(){
    emit(fileisdownloaded());
  }
  void Returndownloadinprogressstate(int percentage){
    emit(downloadinprogressstate(percentage));
  }
  Future<void> loadfile(String url,String extention,String title)async{
    await launchURL(url,extention,title,this);
  }


  Future<void>getCatlogs({TextEditingController title})async{
    resetCatalogFiles();
    emit(loaddatafromfirebase());
    catalogcollection.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Catalogs.add(Catalog.fromJson(doc.data()));
      });
    }).then((value) async{
     emit(dataiscome());
    });
  }

  void resetCatalogFiles() {
    Catalogs = [];
    CatalogImage = null;
    mainimage=null;
    pdfFile = null;
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

  void setImage(File file, {String typeofimage})async{
    if (typeofimage == "mainimage")
      mainimage = file;
    else if(typeofimage =="catalogimage"){
      CatalogImage = file;
    }
    else{
      pdfFile=file;
    }
    emit(imageiscome());
  }

  Future<void> addCatalog(Catalog catalog, TextEditingController title,) async {
    if (catalog.title == "") {
      emit(emptystringfound());
    }
    else{
      validCatalog(catalog, title);
    }

  }

  void validCatalog(Catalog catalog, TextEditingController title) {
    if(pdfFile==null&&mainimage==null&&CatalogImage==null){
      insertCatalogWithDefaultValues(catalog, title);
    }
    else{
      insertCatalogWithFiles(catalog);
    }
  }

  void insertCatalogWithFiles(Catalog catalog) {
    if(CatalogImage!=null){
      print("gfgfd");
      UploadFileToServer("Insert",CatalogImage, this, catalog, catalogcollection, Catalogs,typeoflist: "catalog",mainimage: mainimage,isthereMainImageInItem: true);

    }
    else
      UploadFileToServer("Insert",pdfFile, this, catalog, catalogcollection, Catalogs,typeoflist: "catalog",mainimage: mainimage,isthereMainImageInItem: true);
  }

  void insertCatalogWithDefaultValues(Catalog catalog, TextEditingController title) {
    catalog.defauktphoto="https://img.icons8.com/pastel-glyph/2x/no-document.png";
    catalog.path = "https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";
    catalog.mainimagepath="https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";
    catalog.date = getDateWithoutTime();
    addCatalogInFireBase(catalog, title);
  }

  void addCatalogInFireBase(Catalog catalog, TextEditingController title) {
    catalogcollection.add(catalog.toJson()).then((value) {
      catalogcollection.doc(value.id).update({'id': value.id});
      title.text="";
      getCatlogs();
      emit(upladingisfinished());
    });
  }
  Future<void>editCatalog(Catalog catalog,TextEditingController title)async{
    emit(Catalogisuploading());
    if(mainimage!=null){
      UploadTask uploadedFileProgress = SaveFileIntoFireBaseStorage(mainimage);
      uploadedFileProgress.then((TaskSnapshot value){
        value.ref.getDownloadURL().then((valuee) {
          catalog.mainimagepath=valuee;
          UpdateImages(catalog);
        });
      });
    }
    else{
      UpdateImages(catalog);
    }

  }
  Future<void> UpdateImages(Catalog catalog){
    if(CatalogImage!=null){
      UploadFile("Update",CatalogImage, catalog, catalogcollection, this);
    }
    else if(pdfFile!=null){
      UploadFile("Update",pdfFile, catalog, catalogcollection, this);
    }
    else{
      UpdateItem(catalog,catalogcollection,this);
    }
  }

  void ReturnPercentageState(double percentage){
    emit(fileisuploadingprogress(percentage));
  }
  void ReturnEndingProcessState(){
    emit(upladingisfinished());
  }

  Future<void>deletecategory(Catalog object){
    catalogcollection.where("id", isEqualTo: object.id).get().then((value) {
      catalogcollection.doc(value.docs.first.id).delete();
      getCatlogs();
      emit(Catalogdeletedsuccfully());
    });
  }
}