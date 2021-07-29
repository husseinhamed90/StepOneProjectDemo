import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steponedemo/Models/News.dart';
import 'package:steponedemo/NewsCubit/NewsCubitState.dart';
import '../Helpers/Utilites.dart';

class NewsCubit extends Cubit<NewsCubitState> {
  NewsCubit() : super(initialState());
  File NewImage;
  int numofnewnews=0;
  CollectionReference collection = FirebaseFirestore.instance.collection('News');
  File pdfFile;
  final picker = ImagePicker();

  void updateimagestate(File newfile){
    NewImage=null;
    pdfFile=newfile;
    emit(documentcome());
  }
  Future<void>SetNewNumberOfNews()async{
    numofnewnews=0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("numofnews", news.length);
    emit(numberofnewsUpdated());
  }
  static NewsCubit get(BuildContext context) => BlocProvider.of(context);

  List<News> news = [];
  List<dynamic> SortingNewsByDate(List<dynamic> nonsordtednews) {
    nonsordtednews.forEach((element) {
      element.dataTime = DateTime(
          int.parse(element.date.split("/")[2]),
          int.parse(element.date.split("/")[1]),
          int.parse(element.date.split("/")[0]));
    });

    nonsordtednews.sort((a, b) => b.dataTime.compareTo(a.dataTime));
    return nonsordtednews;
  }
  void ReturnLoadingState(){
    emit(loaddatafromfirebase());
  }

  void ReturnUpdateProcessEnded(){
    emit(Newsloaded());
  }

  Future<void>editNew(News order,TextEditingController title)async{
    if(NewImage!=null){
      UploadImage("Update",NewImage, order, collection, this);
    }
    else if(pdfFile!=null){
      UploadImage("Update",pdfFile, order, collection, this);
    }
    else{
      emit(newisuploading());
      UpdateItem(order,collection,this);
    }
  }

  Future<void> getnews() async{
    NewImage = null;
    news = [];
    pdfFile=null;
    emit(loaddatafromfirebase());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    collection.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        news.add(News.fromJson(doc.data()));
      });
    }).then((value) async{
      news = SortingNewsByDate(news);
      numofnewnews=news.length - (prefs.getInt('numofnews') ?? 0);
      emit(newsloaded());
    });
  }

  void ReturnPercentageState(double percentage){
    emit(fileisuploadingprogress(percentage));
  }
  void ReturnEndingProcessState(){
    emit(NewisEndinguploading());
  }
  void ReturnfileisdownloadedState(){
    emit(fileisdownloaded());
  }
  void Returndownloadinprogressstate(int percentage){
    emit(downloadinprogressstate(percentage));
  }

  void loadfile(String url,String extention,String title)async{
    emit(loadfilefromfirebase());
    await launchURL(url,extention,title,this);
    emit(fileisdownloaded());
  }

  Future<void> addnews(News newNews, TextEditingController title,) {

    if (newNews.title == "") {
      emit(emptystringfoundinNewdata());
    }
    else {
      if (pdfFile == null&&NewImage==null) {
          emit(newisuploading());
          newNews.date = getDateWithoutTime();
          newNews.extention="png";
          newNews.defauktphoto="https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";
          newNews.path = "https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";
          collection.add(newNews.toJson()).then((value) {
            newNews.id = value.id;
            collection.doc(value.id).update({'id': value.id});
            title.text = "";
            getnews();
          }).catchError((error) => print("Failed to add new: $error"));
      }
      else {
        if(pdfFile!=null){
          UploadFileToServer("Insert",pdfFile,this,newNews,collection,news,typeoflist: "news",mainimage: null);
        }
        else{
          UploadFileToServer("Insert",NewImage,this,newNews,collection,news,typeoflist: "news",mainimage: null);
        }
      }
    }
  }
  Future<void> deletNews(News sellingpolicy) {
    emit(loaddatafromfirebase());
    collection.where("id", isEqualTo: sellingpolicy.id).get().then((value) {
      collection.doc(value.docs.first.id).delete();
      getnews();
      emit(newDeletedSuccfully());
    });
  }

  void setImage(File file, {String typeofimage})async{
    NewImage =file;
    emit(imageiscome());
  }

  Future getImagefromSourse(ImageSource source,File file) async {
    pdfFile=null;
    final pickedFile = await picker.getImage(
        source: source, preferredCameraDevice: CameraDevice.rear);
    if (pickedFile != null) {
      file = File(pickedFile.path);
      NewImage=file;
      emit(imageiscome());
    } else {}
  }
}