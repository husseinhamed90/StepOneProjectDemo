import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:steponedemo/Models/Client.dart';
import 'package:steponedemo/Models/Shippedtem.dart';
import 'package:steponedemo/Models/TRProdct.dart';
import 'package:steponedemo/Models/brand.dart';
import 'package:path/path.dart' as p;
import 'package:steponedemo/BrandsCubit/BrandsStates.dart';
import '../Helpers/Utilites.dart';

class BrandsCubit extends Cubit<BrandsStates> {
  Database database;
  BrandsCubit(this.database) : super(initialState());

  static BrandsCubit get(BuildContext context) => BlocProvider.of(context);
  File image;
  File pdfFile;
  final picker = ImagePicker();
  bool foucesstate = false;
  List<Client> suggestionresult = [];
  Client choosenclient;
  File productimage;
  CollectionReference Brands = FirebaseFirestore.instance.collection('Brands');
  List<brand> brands = [];


  Future getMainImagefromSourse(ImageSource source, File file, String typeofitem, {brand currentbrand, int index}) async {
    final pickedFile = await picker.getImage(
        source: source, preferredCameraDevice: CameraDevice.rear);
    if (pickedFile != null) {
      file = File(pickedFile.path);
      if (typeofitem == "brand")
        image = file;
      else {
        productimage = file;
        await updateProduct(currentbrand.products[index], currentbrand, index);
      }
      emit(imageiscome(image));
    }
  }

  Future getCachedData() async {

    await database
        .rawQuery(
        'SELECT * FROM myorders WHERE ClientID = "${choosenclient.ClientID}"')
        .then((value) {
      value.forEach((elementt) {
        database
            .rawQuery(
            'SELECT * FROM products WHERE Item = "${elementt['itemID']}" AND ClientID = "${choosenclient.ClientID}"')
            .then((valuee) {
          valuee.forEach((element) {
            TrProduct trProduct = TrProduct.fromJson(element);
            trProduct.Retail = element['Retail'];
            ShippedItem shippedItem = ShippedItem(
                trProduct,
                elementt['quantity'],
                elementt['bounce'],
                elementt['Discountinsteadofbonus'],
                elementt['Discountinsteadofadding'],
                elementt['specialDiscount']);
            choosenclient.orderitems.add(shippedItem);
            emit(datagetfromcashe());
          });
        });
      });
    });
  }

  Future DeleteOrderFromDatabase() async {

    database.transaction((txn) {

      return txn
          .rawDelete('DELETE FROM myorders WHERE ClientID = "${choosenclient.ClientID}"')
          .then((value) {
        database.rawDelete('DELETE FROM products WHERE ClientID ="${choosenclient.ClientID}"').then((value) {
          choosenclient=null;
          suggestionresult=[];
          print("Order Removed Successfully");
          emit(ItemIsRemovedFromLocalDataBase());
        });
      });
    });
  }

  Future DeleteItemFromOrderFromDatabase(TrProduct trProduct) async {
    database.transaction((txn) {
      emit(removingitemfromcartinprogress());
      return txn
          .rawDelete(
          'DELETE FROM products WHERE (ClientID = "${choosenclient.ClientID}" AND Item = "${trProduct.Item}")')
          .then((value) {
        for (int i = 0; i < choosenclient.orderitems.length; i++) {
          if (choosenclient.orderitems[i].trProduct.Item == trProduct.Item) {
            choosenclient.orderitems.removeAt(i);
            emit(itemremovedfromcart());
            return true;
          }
        }
        print("Record Removed Successfully");
      });
    });
  }

  void InsertOrderIntoFireBase(String representaiveID) {
    if(choosenclient!=null){

      if(choosenclient.orderitems.length>0){
        emit(addingproducttocardinprogress());
        List<Map<String, dynamic>> gg = [];
        choosenclient.orderitems.forEach((element) {
          gg.add(element.toJson());
        });
        FirebaseFirestore.instance.collection('ClientOrders').add({
          "OrderOwner": choosenclient.ClientID,
          "OrderItems": gg,
          "date": getDateWithoutTime(),
          "representativeID":representaiveID
        }).then((value) {
          FirebaseFirestore.instance.collection('ClientOrders').doc(value.id).update({"location": value.id}).then((value) {
            DeleteOrderFromDatabase().then((value) {
              print("OrderSavedState");
              emit(OrderSavedState());
            });
          });

        });
      }
      else{
        emit(noItemsInCart());
      }
    }
    else{
      emit(nochoosenclientforOrder());
    }
  }

  void setChoosenClient(Client client) {
    choosenclient = client;
    emit(choosenclientState());
  }

  void resetsearchbar() {
    suggestionresult = [];
    foucesstate = false;
    emit(resetsearchbarState());
  }

  void changesuggestionresultList(String searchedstring, List<Client> clients) {
    suggestionresult = [];
    clients.forEach((e) {
      if (e.clientname.contains(searchedstring)||e.clientcode.contains(searchedstring)){

        Client newcopyofclint=Client.clone(e);
        newcopyofclint.id=e.id;
        newcopyofclint.ClientID=e.ClientID;
        newcopyofclint.path=e.path;
        newcopyofclint.path2=e.path2;
        suggestionresult.add(newcopyofclint);
      }
    });
    emit(newSearchsugestionlist());
  }

  void textfroemfoucesstate(bool b) {
    foucesstate = b;
    emit(tetxformfoucesState());
  }

  Future InsertOrderIntoDatabase(ShippedItem shippedItem) async {
    database.transaction((txn) {
      return txn
          .rawInsert(
          'INSERT INTO myorders (ClientID,itemID,quantity,bounce,Discountinsteadofbonus,Discountinsteadofadding,specialDiscount) VALUES ("${choosenclient.ClientID}", "${shippedItem.trProduct.Item}", ${shippedItem.quantity},${shippedItem.bounce},${shippedItem.Discount_instead_of_bonus},${shippedItem.Discount_instead_of_adding},${shippedItem.specialDiscount})')
          .then((value) {
        print("Record added Successfully");
      });
    });
  }

  Future InsertProductIntoDatabase(TrProduct trProduct) async {
    database.transaction((txn) {
      return txn
          .rawInsert(
          'INSERT INTO products (Item,ClientID,Description,Q,Retail,path) VALUES ("${trProduct.Item}","${choosenclient.ClientID}", "${trProduct.Description}", ${trProduct.Q},${trProduct.Retail},"${trProduct.path}")')
          .then((value) {
        print("Record added Successfully");
      });
    });
  }

  void AddProductToCart(
      ShippedItem shippedItem,
      Client client,
      TextEditingController quantity,
      TextEditingController bounce,
      TextEditingController discountReplacmentToBounce,
      TextEditingController Addeddiscount,
      TextEditingController SpecialDiscount) async {
    if (choosenclient == null) {
      emit(clientnotchoosen());
    } else {
      emit(addingproducttocardinprogress());
      InsertOrderIntoDatabase(shippedItem).then((value) {
        InsertProductIntoDatabase(shippedItem.trProduct);
        choosenclient.orderitems.add(shippedItem);
        quantity.text = "";
        bounce.text = "";
        discountReplacmentToBounce.text = "";
        Addeddiscount.text = "";
        SpecialDiscount.text = "";
        emit(ItemAddedToCart());
      });
    }
  }

  void deleteProduct(TrProduct trProduct,brand prevbrand,int index)async{
    emit(loadingbrangforupdate());
    Brands.where("brandcode", isEqualTo: prevbrand.prandcode)
        .get().then((value) {

      prevbrand.products.removeAt(index);
      Brands.doc(value.docs.first.id)
          .update({"products": prevbrand.toJson()["products"]}).then((value) {
            getbrands();
      });

    });
  }

  Future<void> updateProduct(TrProduct trProduct, brand prevbrand, int index) async {
    emit(loadingbrangforupdate());
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("image1" + DateTime.now().toString());
    UploadTask uploadTask = ref.putFile(productimage);
    TaskSnapshot taskSnapshot = await uploadTask;
    String path = await taskSnapshot.ref.getDownloadURL();
    trProduct.path = path;
    Brands.where("brandcode", isEqualTo: prevbrand.prandcode).get().then((value) {
      prevbrand.products[index] = trProduct;
      Brands.doc(value.docs.first.id).update({"products": prevbrand.toJson()["products"]});
      DocumentReference documentReference =FirebaseFirestore.instance.collection("ImagesWithCodes").doc(trProduct.Item);
      documentReference.set({"imageUrl":path}).then((value) {
        getbrands().then((value) {
          emit(brandupdated());
        });
      });
    });
  }

  void EditBrand(TextEditingController brandname, TextEditingController brandecode, brand currentbrand) async {
    if (brandname.text == "" || brandecode.text == "") {
      emit(emptystringfound());
    } else {
      brand newbrand = brand(brandname.text, brandecode.text);
      newbrand.id = currentbrand.id;
      FirebaseStorage storage = FirebaseStorage.instance;
      emit(loadingbrangforupdate());
      if (image != null) {
        Reference ref =
            storage.ref().child("image1" + DateTime.now().toString());
        UploadTask uploadTask = ref.putFile(image);
        TaskSnapshot taskSnapshot = await uploadTask;
        String path = await taskSnapshot.ref.getDownloadURL();
        newbrand.path = path;
      } else {
        newbrand.path = currentbrand.path;
      }
      if (pdfFile != null) {
        LoadDatafromExcelFile(currentbrand, "update", updatedbrand: newbrand);
      } else {
        newbrand.excelfilepath = currentbrand.excelfilepath;
        newbrand.products = currentbrand.products;
        setUpdatedBrand(currentbrand, newbrand);
      }
    }
  }

  void setUpdatedBrand(brand prevBrand, brand NewBrand) {
    Brands.doc(prevBrand.id).update(NewBrand.toJson()).then((value) {
      emit(brandupdated());
      getbrands();
    });
  }

  Future<void> delectebrand(brand brandss) {
    emit(branddeleted());
    Brands.where("brandcode", isEqualTo: brandss.prandcode).get().then((value) {
      Brands.doc(value.docs.first.id).delete();
      getbrands();
      emit(branddeletedsuccfully());
    });
  }

  void LoadDatafromExcelFile(brand currentbrand, String transactiontype, {brand updatedbrand}) async{
    try {
      emit(loadingbrangforupdate());
      String extention = p.extension(pdfFile.path).split('.')[1];
      String filename = p.basename(pdfFile.path);
      Reference ref =
      FirebaseStorage.instance.ref().child('${extention}s/$filename');
      UploadTask uploadedfileProgress = ref.putFile(
          pdfFile, SettableMetadata(contentType: 'application/$extention'));
      uploadedfileProgress.snapshotEvents.listen((snapshot) {
        double percentage = getRemainingPercentage(snapshot);
        emit(fileisuploadingprogress(percentage));
        //cubit.ReturnPercentageState(percentage);
      }, onError: (Object e) {});
      uploadedfileProgress.then((value) {
        value.ref.getDownloadURL().then((valuee) async {
          if (transactiontype == "Insert") {
            currentbrand.excelfilepath = valuee;
            currentbrand.products =  await readExcelFile(pdfFile.path);
            Brands.add(currentbrand.toJson()).then((value) {
              Brands.doc(value.id).update({"id": value.id});
              emit(brandadded());
              getbrands();
            });
          } else if (transactiontype == "update") {
            updatedbrand.excelfilepath = valuee;
            updatedbrand.products = await readExcelFile(pdfFile.path);
            setUpdatedBrand(currentbrand, updatedbrand);
          }
        });
      });
    } catch (e) {}
  }

  Future<void> getbrands() async {
    brands = [];
    image = null;
    pdfFile = null;
    await FirebaseFirestore.instance
        .collection('Brands')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        brands.add(brand.fromJson(doc.data()));
      });
      emit(getbrandsstate());
    }).catchError((error) {
    });
  }

  Future<void> addnewbrand(TextEditingController brandname, TextEditingController brandecode) async {
    if (brandname.text == "" || brandecode.text == "") {
      emit(emptystringfound());
    } else {
      brand newbrand = brand(brandname.text, brandecode.text);
      FirebaseStorage storage = FirebaseStorage.instance;
      emit(loadingbrangforupdate());
      if (image == null) {
        newbrand.path =
        "https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";
      } else {
        Reference ref =
        storage.ref().child("image1" + DateTime.now().toString());
        UploadTask uploadTask = ref.putFile(image);
        TaskSnapshot taskSnapshot = await uploadTask;
        String path = await taskSnapshot.ref.getDownloadURL();
        newbrand.path = path;
      }
      LoadDatafromExcelFile(newbrand, "Insert");
    }
  }

  Future<File> uploadExcelFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path);
      pdfFile = file;
      emit(excelfileloaded());
      return file;
    } else {
      //return pdfFile;
    }
  }
}
