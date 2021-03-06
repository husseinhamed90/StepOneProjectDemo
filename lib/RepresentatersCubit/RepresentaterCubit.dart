import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steponedemo/Helpers/Shared.dart';
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

  Future<void>setsharedprefrences(String id)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("id",id);
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
      if(currentuser.usertype=="user"){
        representative.path = currentadmindata.logopath;
      }
      else{
        if (image == null) {
          representative.path = "https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";
        }
        else {
          representative.path=await getUrlofImage(image);
        }
      }
      representative.id = id;
      representatives.add(representative.toJson()).then((value) {
        userscollection.where(
          "id",
          isEqualTo: representative.id,
        ).get().then((value) {
          userscollection.doc(value.docs.first.id).update({"isfirsttime": "false"});
          appCubit.SetCurrentRepresentative(representative);
          currentrepresentative=representative;
          emit(representativeaddedsuccefulltstate(representative));
        });
      }).catchError((error) => print("Failed to add representative: $error"));
    }
  }
  Future<void> updaterepresentaive(AppCubit appCubit,Representative newrepresentaive,user currentuser) async {
    emit(updatestatuesloading());
    if (image == null) {
      newrepresentaive.path = currentrepresentative.path;
    }
    else {
      newrepresentaive.path=await getUrlofImage(image);
    }
    currentrepresentative=newrepresentaive;
    appCubit.SetCurrentRepresentative(currentrepresentative);
    updateCurrentRepresentstiveInFireBase(newrepresentaive);
    updateAdminDataIfCurrentRepresentativeIsAdminUser(currentuser, newrepresentaive);
  }

  void updateAdminDataIfCurrentRepresentativeIsAdminUser(user currentuser, Representative newrepresentaive) {
    if(currentuser.usertype=="admin"){
      updateOtherRepresentativeData(newrepresentaive);
    }
    else{
      emit(representativeupdatedstate());
    }
  }

  void updateOtherRepresentativeData(Representative newrepresentaive) {
    representatives.get().then((value) {
      value.docs.forEach((element) {
        updateEachRepresentativeData(element, newrepresentaive);
      });
    });
  }

  void updateEachRepresentativeData(QueryDocumentSnapshot element, Representative newrepresentaive) {
    representatives.doc(element.id).update(
        ExtractMapOfAdminData(newrepresentaive)).then((value) {
      emit(representativeupdatedstate());
    });
  }

  Map<String, dynamic> ExtractMapOfAdminData(Representative newrepresentaive) {
    return {"companyaddress":newrepresentaive.companyaddress,
    "companyname":newrepresentaive.companyname,
    "companyphone":newrepresentaive.companyphone,
    "path":newrepresentaive.path
    };
  }

  void updateCurrentRepresentstiveInFireBase(Representative newrepresentaive) {
    representatives.where("id", isEqualTo: currentrepresentative.id).get().then((value) {
      representatives.doc(value.docs.first.id).update(newrepresentaive.toJson());
    });
  }

}