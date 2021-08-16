import 'dart:collection';
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
  File orderedFile;
  final picker = ImagePicker();
  bool foucesstate = false;
  List<Client> suggestionresult = [];
  Client choosenclient =Client.noClient();
  File productimage;
  CollectionReference Brands = FirebaseFirestore.instance.collection('Brands');
  List<brand> brands = [];


  Future<File> getImagefromSourse(ImageSource source, File file, {String typeofitem, brand currentbrand, int index}) async {
    final pickedFile = await picker.getImage(
        source: source, preferredCameraDevice: CameraDevice.rear);
    if (pickedFile != null) {
      file = File(pickedFile.path);
      return file;
    }
  }
  void setImage(File file, {String typeofimage})async{
    if (typeofimage == "brand")
      image = file;
    else {
      productimage = file;
    }
    emit(imageiscome(image));
  }

  void updateimagestate(File newfile){
    image=null;
    pdfFile=newfile;
    emit(imageiscome(image));
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
      return txn.rawInsert('INSERT INTO products (Item,ClientID,Description,Q,Retail,path) VALUES ("${trProduct.Item}","${choosenclient.ClientID}", "${trProduct.Description}", ${trProduct.Q},${trProduct.Retail},"${trProduct.path}")')
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
    Brands.where("brandcode", isEqualTo: prevbrand.prandcode).get().then((value) {
      prevbrand.products.removeAt(index);
      Brands.doc(value.docs.first.id).update({"products": prevbrand.toJson()["products"]}).then((value) {
            getbrands();
      });
    });
  }

  Future<String> getUrlofImage(File file)async{
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("image1" + DateTime.now().toString());
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String path = await taskSnapshot.ref.getDownloadURL();

    return path;
  }

  Future<void> updateProduct(TrProduct trProduct, brand prevbrand, int index) async {
    emit(loadingbrangforupdate());

    trProduct.path =await getUrlofImage(productimage);
    Brands.where("brandcode", isEqualTo: prevbrand.prandcode).get().then((value) {
      prevbrand.products[index] = trProduct;
      Brands.doc(value.docs.first.id).update({"products": prevbrand.toJson()["products"]});

      if(trProduct.Item.contains("/")){
        trProduct.Item.replaceAll(new RegExp(r'[^\w\s]+'));
      }
      DocumentReference documentReference =FirebaseFirestore.instance.collection("ImagesWithCodes").doc(trProduct.Item);
      documentReference.set({"imageUrl":trProduct.path}).then((value) {
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
      }
      else {
        newbrand.path = currentbrand.path;
      }

      if(pdfFile==null&&orderedFile==null){
        newbrand.orderedFile=currentbrand.orderedFile;
        newbrand.orderedProducts=currentbrand.orderedProducts;
        newbrand.excelfilepath=currentbrand.excelfilepath;
        newbrand.products=currentbrand.products;
      }
      else if(pdfFile!=null&&orderedFile!=null){
        newbrand = await LoadDatafromExcelFile(orderedFile,currentbrand, "orderedFile",updatedBrand: newbrand);
        newbrand = await LoadDatafromExcelFile(pdfFile,currentbrand, "mainFile",updatedBrand: newbrand);
      }
      else{
        if(orderedFile!=null){
          newbrand.excelfilepath=currentbrand.excelfilepath;
          newbrand.products=currentbrand.products;
          newbrand = await LoadDatafromExcelFile(orderedFile,currentbrand, "orderedFile",updatedBrand: newbrand);
        }
        else if(pdfFile!=null){
          newbrand.orderedFile=currentbrand.orderedFile;
          newbrand.orderedProducts=currentbrand.orderedProducts;
          newbrand = await LoadDatafromExcelFile(pdfFile,currentbrand, "mainFile",updatedBrand: newbrand);
        }
      }
      setUpdatedBrand(currentbrand.id, newbrand);
    }
  }

  void setUpdatedBrand(String id, brand NewBrand) {
    Brands.doc(id).update(NewBrand.toJson()).then((value) {
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
  Future<List<TrProduct>> orderproducts(List<TrProduct>products,List<TrProduct>orderedProducts)async{

    Map<String,dynamic>orderedBrand={};
    for(int i=0;i<orderedProducts.length;i++){
      orderedBrand["${orderedProducts[i].Item}"]=i;
    }
    Map<String,dynamic>orderNumbers={};
    Map<String,TrProduct>foundItems={};
    List<TrProduct> newList =[];
    for(int i=0;i<products.length;i++){
      if(orderedBrand.containsKey(products[i].Item)){
        foundItems[products[i].Item]=products[i];
        orderNumbers[products[i].Item]=orderedBrand[products[i].Item];
      }
      else{
        products[i].Price="0";
        products[i].Retail="0";
        products[i].Q="0";
        foundItems[products[i].Item]=products[i];
        orderNumbers[products[i].Item]=orderedBrand.length+1;
      }
    }
    var sortedKeys = orderNumbers.keys.toList(growable:false)..sort((k1, k2) => orderNumbers[k1].compareTo(orderNumbers[k2]));
    LinkedHashMap sortedMap = new LinkedHashMap.fromIterable(sortedKeys, key: (k) => k, value: (k) => orderNumbers[k]);
    sortedMap.forEach((key, value) {
      newList.add(foundItems[key]);
    });
    products=newList;
    return products;
  }

  void emitnumberofloadedfilesfromexel(double numberofFiles){
    emit(numberoffilestillNow(numberofFiles));
  }
  Future<brand> LoadDatafromExcelFile(File file,brand currentbrand,String typeOfFile, {brand updatedBrand,File secondFile}) async{
    try {
      emit(loadingbrangforupdate());
      String path;
      String extention = p.extension(file.path).split('.')[1];
      String filename = p.basename(file.path);
      Reference ref = FirebaseStorage.instance.ref().child('${extention}s/$filename');
      UploadTask uploadedfileProgress = ref.putFile(file, SettableMetadata(contentType: 'application/$extention'));
      uploadedfileProgress.snapshotEvents.listen((snapshot) {
        double percentage = getRemainingPercentage(snapshot);
        emit(fileisuploadingprogress(percentage));
      }, onError: (Object e) {});
      await uploadedfileProgress.then((value) async {
        await value.ref.getDownloadURL().then((valuee) async {
          path=valuee;
          emit(readingexcelFileInProgess());
          List<TrProduct>products=await readExcelFile(file.path,this,typeOfFile);
          if(updatedBrand!=null){
            if(typeOfFile=="orderedFile"){
              updatedBrand.orderedFile =path;
              updatedBrand.orderedProducts=products;
              updatedBrand.products=await orderproducts(currentbrand.products,updatedBrand.orderedProducts);
            }
            else{
              emit(orderproductsInProgress());
              updatedBrand.excelfilepath=path;
              if(updatedBrand.orderedProducts==[]||updatedBrand.orderedProducts==null){
                updatedBrand.products=products;
              }
              else{
                products =await orderproducts( products,updatedBrand.orderedProducts);
                updatedBrand.products=products;
              }
            }
          }
          else{
            if(typeOfFile=="orderedFile"){
              currentbrand.orderedFile =path;
              currentbrand.orderedProducts=products;
            }
            else{
              emit(orderproductsInProgress());
              currentbrand.excelfilepath=path;
              if(currentbrand.orderedProducts==[]||currentbrand.orderedProducts==null){
                currentbrand.products=products;
              }
              else{
                products =await orderproducts(products,currentbrand.orderedProducts);
                currentbrand.products=products;
              }
            }
          }

        });

      });

      if(updatedBrand!=null){
        return updatedBrand;
      }
      else{
        return currentbrand;
      }
    } catch (e) {}
  }
  Future<String> getpathOfDownloadedFile(File file) async{
    String extention = p.extension(file.path).split('.')[1];
    String filename = p.basename(file.path);
    Reference ref =
    FirebaseStorage.instance.ref().child('${extention}s/$filename');
    UploadTask uploadedfileProgress = ref.putFile(
        file, SettableMetadata(contentType: 'application/$extention'));
    uploadedfileProgress.snapshotEvents.listen((snapshot) {
      double percentage = getRemainingPercentage(snapshot);
      emit(fileisuploadingprogress(percentage));
    }, onError: (Object e) {});
    await uploadedfileProgress.then((value) {
      value.ref.getDownloadURL().then((valuee) async {
       return valuee;
      });
    });
  }

  Future<void> addnewbrand(TextEditingController brandname, TextEditingController brandecode) async {
    if (brandname.text == "" || brandecode.text == "") {
      emit(emptystringfound());
    } else {
      brand newbrand = brand(brandname.text, brandecode.text);
      emit(loadingbrangforupdate());
      if (image == null) {
        newbrand.path =
        "https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";
      } else {
        String path= await getUrlofImage(image);
        newbrand.path = path;
      }

      if(orderedFile!=null){
        newbrand  = await LoadDatafromExcelFile(orderedFile,newbrand,"orderedFile");
      }
      else{
        newbrand.orderedFile = "https://icons.iconarchive.com/icons/custom-icon-design/mono-general-2/512/document-icon.png";
        newbrand.orderedProducts =  [];
      }
      if(pdfFile!=null){
        newbrand =  await LoadDatafromExcelFile(pdfFile,newbrand,"mainFile");
      }
      else{
        newbrand.excelfilepath = "https://icons.iconarchive.com/icons/custom-icon-design/mono-general-2/512/document-icon.png";
        newbrand.products =  [];
      }
     // getbrands();
      Brands.add(newbrand.toJson()).then((value){
        Brands.doc(value.id).update({"id": value.id});
        emit(brandadded());
        getbrands();
      });
    }
  }

  Future<void> getbrands() async {
    brands = [];
    orderedFile=null;
    image = null;
    pdfFile = null;
     FirebaseFirestore.instance.collection('Brands').get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        brands.add(brand.fromJson(doc.data()));
      });
      emit(getbrandsstate());
    }).catchError((error) {
    });
  }

  Future<File> uploadExcelFile(String typeOfFile) async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path);

      if(typeOfFile=="orderedFile"){
        orderedFile=file;
      }
      else
        pdfFile = file;
      emit(excelfileloaded());
      return file;
    }
  }
}
