import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steponedemo/ClientsCubit/ClientsCubitStates.dart';
import 'package:steponedemo/Models/Client.dart';

class ClientsCubit extends Cubit<ClientsCubitState> {
  ClientsCubit() : super(initialState());
  static ClientsCubit get(BuildContext context) => BlocProvider.of(context);

  File image,image2;
  File pdfFile;
  String userid;
  final picker = ImagePicker();
  CollectionReference ClintsCollection =
      FirebaseFirestore.instance.collection('Clients');
  List<Client> clients = [];
  Future<void> deleteclient(Client client) {
    ClintsCollection.doc(client.ClientID).delete();
    getClintess();
    emit(Clinteletedsuccfully());
  }

  Future<File> getImagefromSourse(ImageSource source, File file,{String imagenumber}) async {
    final pickedFile = await picker.getImage(
        source: source, preferredCameraDevice: CameraDevice.rear);
    if (pickedFile != null) {
      return File(pickedFile.path);
      emit(imageiscome());
    } else {}
  }

  void setImage(File file, {String typeofimage})async{
    if(typeofimage=="first"){
      image = file;
    }
    else{
      image2 = file;
    }
    emit(imageiscome());
  }

  Future<String> getfromsharedprefrences(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(key) ?? "";
  }

  void setuserid(String id) {
    userid = id;
    emit(UserIDIsUpdated());
  }

  Future<void> getClintess() async {
    clients = [];

    emit(loaddatafromfirebase());
    if (userid != null) {
      await ClintsCollection.where("id", isEqualTo: userid).get().then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          clients.add(Client.fromJson(doc.data()));
        });
        image = null;
        image2=null;
        emit(getclientsstate());
      }).catchError((error) {
        print(error);
      });
    }
  }

  Future<void> addClient(
    Client client,
    TextEditingController Clientname,
    TextEditingController Clientcode,
    TextEditingController Clientphone,
    TextEditingController Clientaddress,
    TextEditingController Clientarea,
    File _image, File _image2,
    String id,
  ) async {
    if (Clientname.text == "") {
      emit(validclientstate());
    } else {
      emit(loaddatafromfirebase());
      FirebaseStorage storage = FirebaseStorage.instance;
      if (image==null) {
        client.path =
            "https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";
      }
      else{
        Reference ref =
        storage.ref().child("image1" + DateTime.now().toString());
        UploadTask uploadTask = ref.putFile(image);
        await uploadTask.then((res) async {
          await res.ref.getDownloadURL().then((value) {
            print("image is come");
            client.path = value;
          });
        });
      }
      if(image2==null){
        client.path2 =
        "https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";
      }
      else{
        Reference ref =
        storage.ref().child("image1" + DateTime.now().toString());
        UploadTask uploadTask = ref.putFile(image2);
        await uploadTask.then((res)async {
          await res.ref.getDownloadURL().then((value) {
            print("image 2 is come");
            client.path2 = value;
          });
        });
      }
      client.id = id;
      ClintsCollection.add(client.toJson()).then((value) {
        ClintsCollection.doc(value.id).update({"ClientID":value.id});
        Clientname.text = "";
        Clientcode.text = "";
        Clientphone.text = "";
        Clientaddress.text = "";
        Clientarea.text = "";

        getClintess();
        emit(Clientaddedsuccefulltstate());
      }).catchError((error) => print("Failed to add client: $error"));
    }
  }

  void GetCurrentUser(String id) {
    if (id == "") {
      userid = "";
    } else {
      userid = id;

    }
    emit(GetUserIDSate());
  }

  Future<void> updateClient(Client client, Client oldclient) async {
    emit(updatestatuesloading());
    FirebaseStorage storage = FirebaseStorage.instance;
    if (image == null) {
      client.path = oldclient.path;
    }
    else{
      Reference ref = storage.ref().child("image1" + DateTime.now().toString());
      UploadTask uploadTask = ref.putFile(image);
      await uploadTask.then((res) async {
        await res.ref.getDownloadURL().then((value) {
          client.path = value;
        });
      });
    }
    if (image2 == null) {
      client.path2 = oldclient.path2;
    }
    else{
      Reference ref = storage.ref().child("image1" + DateTime.now().toString());
      UploadTask uploadTask = ref.putFile(image2);
      await uploadTask.then((res) async{
        await res.ref.getDownloadURL().then((value) {
          client.path2 = value;
        });
      });
    }
    client.id = userid;
    client.ClientID=oldclient.ClientID;
    ClintsCollection.doc(oldclient.ClientID).update(client.toJson()).then((value) async {
      await getClintess();
      emit(clientupdatedstate());
    });
  }
}
