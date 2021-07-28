import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steponedemo/ClientsCubit/ClientsCubit.dart';
import 'package:steponedemo/MainCubit/MainCubitStates.dart';
import 'package:steponedemo/Models/AdminData.dart';
import 'package:steponedemo/Models/Representative.dart';
import 'package:steponedemo/Models/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:steponedemo/RepresentatersCubit/RepresentaterCubit.dart';

class AppCubit extends Cubit<MainCubitState> {

  AppCubit() : super(initialState());

  static AppCubit get(BuildContext context) => BlocProvider.of(context);

  CollectionReference userscollection = FirebaseFirestore.instance.collection('Users');
  UserCredential userCredential;

  CollectionReference representatives = FirebaseFirestore.instance.collection('Representatives');

  List<user> users = [];

  bool isloging=false;
  user currentuser;
  Representative currentrepresentative;
  AdminData currentadmindata;

  void GetCurrentUser(user user){
    currentuser=user;
    emit(GetUserIDSate());
  }
  void SetCurrentRepresentative(Representative representative){
    if(representative==null){
      emit(Userisnotarepresentatcie());
    }
    else{
      currentrepresentative=representative;
      emit(GetRepresentativeDate());
    }

  }
  Future<QuerySnapshot>retriveuserfromFireBase(String id)async{
    QuerySnapshot value = await userscollection.where("id", isEqualTo: id).get();
    return value;
  }

  Future<void>UpdateStatus(String newstatus,String id)async{
    QuerySnapshot value = await retriveuserfromFireBase(id);
    await ChangeStatusofUser(value,newstatus);
  }

  Future<void>ChangeStatusofUser(QuerySnapshot useeSnapshot,String newstatus)async{
    userscollection
        .doc(useeSnapshot.docs.first.id)
        .update({'isonline': newstatus}).then((value) {
      emit(exitapp());
    }).catchError((error) {
      print("Error When Change Status");
    });
  }

  bool checkvalidatyofinputs(String username,String password){
    if(username == "" || password == ""){
      return false;
    }
    else{
      return true;
    }
  }

  Future<UserCredential>GetUserCredentialFromFireBase(String username,String password) async{
    try{
     // emit(loginsistart());
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: '${username.replaceAll(' ', '')}@stepone.com',
          password: password + "steponeapp"
      ).catchError((error) {
        print("fdsf");
        emit(invaliduser());
      });
      //userCredential=userCredentiall;
     // return userCredentiall;
    }catch (e) {
      emit(invaliduser());
    }
  }

  Future<void>isValidUser(UserCredential userCredential)async{
    await FirebaseFirestore.instance.collection('Users').get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (user.fromJson(doc.data()).id == userCredential.user.uid) {
          GetCurrentUser(user.fromJson(doc.data()));
          //emit(currentuserdata());
        }
      });
    });
  }
  Future<void>setsharedprefrences(String id)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("id",id);
  }

  Future<void>GetDataofUserFromRepresentatorsCollection(UserCredential userCredential,RepresentaterCubit representaterCubit)async{

    await UpdateStatus("true",currentuser.id);
    await getusers();

    bool validrepresentative = false;
    representatives.get().then((querySnapshot)  {
      querySnapshot.docs.forEach((doc) {
        if (Representative.fromJson(doc.data()).id == userCredential.user.uid) {
          validrepresentative = true;
          representaterCubit.SetRepresentatvie(Representative.fromJson(doc.data()));
           UpdateRepresentativeData(doc);
        }
      });
      if (!validrepresentative) {
        getdataofadmin().then((value) {
          emit(admindataiscame());
        });
      }
    });
  }

  Future<AdminData> getdataofadmin()async{
    await userscollection.where("usertype",isEqualTo: "admin").get().then((valuee) async {

      await representatives.where('id',isEqualTo: valuee.docs[0].data()['id']).get().then((value) {
        AdminData adminData = AdminData(
            Representative.fromJson(value.docs[0].data()).companyname,
            Representative.fromJson(value.docs[0].data()).companyaddress,
            Representative.fromJson(value.docs[0].data()).companyphone,
            Representative.fromJson(value.docs[0].data()).path
        );
        currentadmindata=adminData;
        emit(admindataiscame());
        return adminData;
      }).onError((error, stackTrace) {
        print("no admin data found");
        return null;
      });
    }).onError((error, stackTrace) {
      print("no admin found");
      emit(noadmindatafound());
      return null;
    });
  }

   void UpdateRepresentativeData(QueryDocumentSnapshot documentSnapshot){
   // appprovider.updaterepresentative();
    currentrepresentative=Representative.fromJson(documentSnapshot.data());
    //isloging=false;
    emit(userisnormaluserstatebutnotfirsttime());
  }

  Future<void> loginwithusernameandpassword(String username, String password,RepresentaterCubit representaterCubit,ClientsCubit clientsCubit) async {
    emit(loginsistart());
    isloging=true;
    if (!checkvalidatyofinputs(username,password)) {
      emit(emptyfeildsstate());
    }
    else {
        //emit(validateiuser());
        UserCredential userCredential =await GetUserCredentialFromFireBase(username,password);
        if(userCredential!=null){
          await isValidUser(userCredential);
          clientsCubit.setuserid(currentuser.id);
          await clientsCubit.getClintess();
          await GetDataofUserFromRepresentatorsCollection(userCredential,representaterCubit);
          isloging=false;
        }
        else{
          isloging=false;
        }

    }
  }

  Future<user>CreateAccountInFireBaeAuthentication(TextEditingController username, TextEditingController password)async{

    UserCredential userCredential= await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: '${username.text.replaceAll(' ', '')}@stepone.com',
        password: password.text + "steponeapp");
    return user(username.text, password.text, 'user', userCredential.user.uid);
  }

  Future<void>CreateNewUser(user newuser){
    userscollection.add(newuser.toJson()).then((value) {
      userscollection.doc(value.path.split('/').last).update({"location": value.path.split('/').last});
      emit(userregistered());
    });
  }

  Future<void>RegisterNewUser(TextEditingController username, TextEditingController password)async{
    try {
      user newuser =await CreateAccountInFireBaeAuthentication(username,password);
      await CreateNewUser(newuser);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(weakpassword());
      } else if (e.code == 'email-already-in-use') {
        emit(accountalreadyexists());
      }
    } catch (e) {
      print(e);
    }
  }

  void register(TextEditingController username, TextEditingController password) async {
    if (!checkvalidatyofinputs(username.text, password.text)) {
      emit(emptyfeildregistersstate());
    }
    else {
      await RegisterNewUser(username,password);
    }
  }

  Future deleteUserfromauth(String email, String password) async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      User user = _auth.currentUser;
      AuthCredential credentials =
      EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(credentials).then((value) {
        value.user.delete();
      });
    } catch (e) {}
  }

  Future UpdateUserfromauth(String password, TextEditingController newusername,TextEditingController newpassword) async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      User user =  _auth.currentUser;

      AuthCredential credentials = EmailAuthProvider.credential(email: user.email, password: password + "steponeapp");
        await user.reauthenticateWithCredential(credentials).then((value) async {
          print("ffffffffffffffffff");
          print(value.user.email);
         await value.user.updateEmail('${newusername.text.replaceAll(' ', '')}@stepone.com').then((valueeee) {
          value.user.updatePassword("${newpassword.text}steponeapp").then((value) {
            getusers().then((value) {
              emit(userupdatedsuccfully());
            });
          }).onError((error, stackTrace) {
          });
        });
      });
    } catch (e) {}
  }

  void deleteuser(user newuser) async {
    emit(userdeletedload());

    userscollection.where("id", isEqualTo: newuser.id).get().then((value) {
      userscollection.doc(value.docs.first.id).delete().then((value) {
        deleteUserfromauth('${newuser.name.replaceAll(' ', '')}@stepone.com',
            '${newuser.password}steponeapp')
            .then((value) {
          getusers().then((value) {
            emit(userdeletedsuccfully());
          });
        });
      });
    });
  }

  void updateeuser(user newuser,TextEditingController username,TextEditingController password,int index) async {
    emit(userupdateload());
    userscollection.where("id", isEqualTo: newuser.id).get().then((value) {
      userscollection.doc(value.docs.first.id).update({"name":username.text,"password":password.text})
          .then((value) {
        UpdateUserfromauth(newuser.password,username,password)
            .then((value) {
              users[index]=newuser;
           //emit(goback());
        });
      });
    });
  }

  Future<void> getusers() async {
    users = [];
    //emit(loaddatafromfirebase());
    await userscollection.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        users.add(user.fromJson(doc.data()));
      });
      emit(getusersstate());
    }).catchError((error) {
      print(error);
    });
  }
}