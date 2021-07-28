import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
import 'package:steponedemo/Models/AdminData.dart';
import 'package:steponedemo/Models/Representative.dart';
import 'package:steponedemo/Models/User.dart';
import 'package:steponedemo/RepresentatersCubit/RepresentatersStates.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RepresentaterCubit extends Cubit<RepresentatersState> {
  RepresentaterCubit() : super(initialState());

  static RepresentaterCubit get(BuildContext context) => BlocProvider.of(context);
  File image;
  File pdfFile;
  final picker = ImagePicker();

  Representative currentrepresentative;
  AdminData currentadmindata;


  CollectionReference userscollection = FirebaseFirestore.instance.collection('Users');
  CollectionReference representatives = FirebaseFirestore.instance.collection('Representatives');

  Future getImagefromSourse(ImageSource source,File file) async {
    final pickedFile = await picker.getImage(source: source, preferredCameraDevice: CameraDevice.rear);
    if (pickedFile != null) {
      file = File(pickedFile.path);
      image=file;
      emit(imageiscome());
    } else {

    }
  }

  void SetRepresentatvie(Representative representative){

    currentrepresentative=representative;
    emit(dataofrepresentativeState());
  }
  void getdataofadmin(){
    userscollection.where("usertype",isEqualTo: "admin").get().then((valuee) {
      representatives.where('id',isEqualTo: valuee.docs[0].data()['id']).get().then((value) {
        AdminData adminData = AdminData(
            Representative.fromJson(value.docs[0].data()).companyname,
            Representative.fromJson(value.docs[0].data()).companyaddress,
            Representative.fromJson(value.docs[0].data()).companyphone,
            Representative.fromJson(value.docs[0].data()).path
        );
        currentadmindata=adminData;
        emit(admindataiscame());
      });
    });
  }
  Future<void> addRepresentative(
      AppCubit appCubit,
      Representative representative,
      TextEditingController represtativename,
      TextEditingController represtativecode,
      TextEditingController represtativenphone,
      TextEditingController represtativetarget,
      TextEditingController represtativearea1,
      TextEditingController represtativearea2,
      TextEditingController represtativearea3,
      TextEditingController represtativearea4,
      TextEditingController represtativesupervisor,
      TextEditingController represtativemanager,
      File _image,
      String id,
      user currentuser,
      AdminData admin
      ) async {
    currentadmindata=admin;
    if (represtativename.text == "" || represtativecode.text == "") {
      emit(validrepresentativestate());
    }
    else {
      emit(loaddatafromfirebase());
      FirebaseStorage storage = FirebaseStorage.instance;
      if(currentuser.usertype=="user"){
        representative.path = currentadmindata.logopath;
      }
      else{
        if (image == null) {
          representative.path = "https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";
        }
        else {
          Reference ref = storage.ref().child("image1" + DateTime.now().toString());
          UploadTask uploadTask = ref.putFile(_image);
          await uploadTask.then((res) async {
            await res.ref.getDownloadURL().then((value) {
              representative.path = value;
            });
          });
        }
      }
      representative.id = id;
      representatives.add(representative.toJson()).then((value) {
        userscollection.where(
          "id",
          isEqualTo: representative.id,
        ).get().then((value) async {
          userscollection.doc(value.docs.first.id).update({"isfirsttime": "false"});
          appCubit.SetCurrentRepresentative(representative);
          currentrepresentative=representative;
          await setsharedprefrences(currentuser.location);
          emit(representativeaddedsuccefulltstate(representative));
        });
      }).catchError((error) => print("Failed to add representative: $error"));
    }
  }
  Future<void>setsharedprefrences(String id)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("id",id);
  }
  Future<void> updaterepresentaive(AppCubit appCubit,Representative newrepresentaive,user currentuser) async {
    emit(updatestatuesloading());
    FirebaseStorage storage = FirebaseStorage.instance;
    if (image == null) {
      newrepresentaive.path = currentrepresentative.path;
    }
    else {
      Reference ref = storage.ref().child("image1" + DateTime.now().toString());
      UploadTask uploadTask = ref.putFile(image);
      await uploadTask.then((res) {
        res.ref.getDownloadURL().then((value) {
          newrepresentaive.path = value;
        });
      });
    }
    currentrepresentative=newrepresentaive;
    appCubit.SetCurrentRepresentative(currentrepresentative);
    representatives
        .where("id", isEqualTo: currentrepresentative.id)
        .get()
        .then((value) {
      representatives
          .doc(value.docs.first.id)
          .update(newrepresentaive.toJson());
    });
    if(currentuser.usertype=="admin"){
      representatives.get().then((value) {
        value.docs.forEach((element) {
          representatives
              .doc(element.id)
              .update({"companyaddress":newrepresentaive.companyaddress,
            "companyname":newrepresentaive.companyname,
            "companyphone":newrepresentaive.companyphone,
            "path":newrepresentaive.path
          }).then((value) {
            emit(representativeupdatedstate());
          });
        });
      });
    }
    else{
      emit(representativeupdatedstate());
    }
  }

}