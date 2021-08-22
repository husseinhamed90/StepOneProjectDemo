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
  bool focusState = false;
  List<Client> suggestionResult = [];
  Client chosenClient = Client.noClient();
  File productImage;
  CollectionReference brandsCollection = FirebaseFirestore.instance.collection('Brands');
  List<brand> brands = [];

  Future<File> getImagefromSourse(ImageSource source, File file, {String typeofitem, brand currentbrand, int index}) async {
    final pickedFile = await picker.getImage(
        source: source, preferredCameraDevice: CameraDevice.rear);
    if (pickedFile != null) {
      file = File(pickedFile.path);
      return file;
    }
  }

  void setImage(File file, {String typeofimage}) async {
    if (typeofimage == "brand")
      image = file;
    else {
      productImage = file;
    }
    emit(imageiscome(image));
  }

  void updateimagestate(File newfile) {
    image = null;
    pdfFile = newfile;
    emit(imageiscome(image));
  }

  Future getCachedData() async {
    await database.rawQuery('SELECT * FROM products WHERE ClientID = "${chosenClient.ClientID}"').then((valuee) {
      valuee.forEach((element) {
        setClientCachedItems(valuee, element);
        emit(datagetfromcashe());
      });
    });
  }

  void setClientCachedItems(List<Map<String, Object>> valuee, Map<String, Object> elementt) {
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
      chosenClient.orderitems.add(shippedItem);
      emit(datagetfromcashe());
    });
  }

  Future DeleteOrderFromDatabase() async {

    database.transaction((txn) {
      return txn.rawDelete('DELETE FROM products WHERE ClientID ="${chosenClient.ClientID}"').then((value) {
        chosenClient=Client.noClient();
        suggestionResult=[];
        print("Order Removed Successfully");
        emit(ItemIsRemovedFromLocalDataBase());
      });
    });
  }

  void resetSearchBarData() {
      chosenClient = Client.noClient();
       suggestionResult = [];
  }

  Future DeleteItemFromOrderFromDatabase(TrProduct trProduct) async {
    emit(removingitemfromcartinprogress());
    return database.rawDelete('DELETE FROM products WHERE (ClientID = "${chosenClient.ClientID}" AND Item = "${trProduct.Item}")').then((value) {
      removeItemFromChosenClientOrder(trProduct);
    });
  }

  void removeItemFromChosenClientOrder(TrProduct trProduct) {
     for (int i = 0; i < chosenClient.orderitems.length; i++) {
      if (chosenClient.orderitems[i].trProduct.Item == trProduct.Item) {
        chosenClient.orderitems.removeAt(i);
        emit(itemremovedfromcart());
      }
    }
  }

  void InsertOrderIntoFireBase(String representaiveID) {
    if (chosenClient.orderitems.length > 0)
      insertOrder(representaiveID);
    else
      emit(noItemsInCart());
  }
  void insertOrder(String representaiveID) {
    emit(addingproducttocardinprogress());
    List<Map<String, dynamic>> MapOfOrderItems = PutItemsInMap;
    insertNewOrderIntoFireBase(MapOfOrderItems, representaiveID);
  }

  void insertNewOrderIntoFireBase(List<Map<String, dynamic>> MapOfOrderItems, String representaiveID) {
    FirebaseFirestore.instance.collection('ClientOrders').add(getMapOfOrderInformation(MapOfOrderItems, representaiveID)).then((value) {
      updateLocationOfnewDocument(value);
    });
  }

  void updateLocationOfnewDocument(DocumentReference value) {
    FirebaseFirestore.instance.collection('ClientOrders').doc(value.id).update({"location": value.id}).then((value) {
      DeleteOrderFromDatabase().then((value) {
        emit(OrderSavedState());
      });
    });
  }

  Map<String, dynamic> getMapOfOrderInformation(List<Map<String, dynamic>> MapOfOrderItems, String representaiveID) {
    return {
    "OrderOwner": chosenClient.ClientID,
    "OrderItems": MapOfOrderItems,
    "date": getDateWithoutTime(),
    "representativeID": representaiveID
  };
  }

  List<Map<String, dynamic>> get PutItemsInMap {
     List<Map<String, dynamic>> MapOfOrderItems = [];
    chosenClient.orderitems.forEach((element) {
      MapOfOrderItems.add(element.toJson());
    });
    return MapOfOrderItems;
  }

  void setChoosenClient(Client client) {
    chosenClient = client;
    emit(choosenclientState());
  }

  void resetsearchbar() {
    suggestionResult = [];
    focusState = false;
    emit(resetsearchbarState());
  }

  void changesuggestionresultList(String searchedstring, List<Client> clients) {

    getClientsWithThisName(clients, searchedstring);
    emit(newSearchsugestionlist());
  }

  void getClientsWithThisName(List<Client> clients, String searchedstring) {
    suggestionResult = [];
    clients.forEach((currentClient) {
      if (currentClient.clientname.contains(searchedstring) || currentClient.clientcode.contains(searchedstring)) {
        suggestionResult.add(getCopyOfClient(currentClient));
      }
    });
  }

  Client getCopyOfClient(Client currentClient) {
     Client newcopyofclint = Client.clone(currentClient);
    newcopyofclint.id = currentClient.id;
    newcopyofclint.ClientID = currentClient.ClientID;
    newcopyofclint.path = currentClient.path;
    newcopyofclint.path2 = currentClient.path2;
    return newcopyofclint;
  }

  void textfroemfoucesstate(bool b) {
    focusState = b;
    emit(tetxformfoucesState());
  }
  Future InsertProductIntoDatabase(TrProduct trProduct) async {
    database.transaction((txn) {
      return txn.rawInsert('INSERT INTO products (Item,ClientID,Description,Q,Retail,path) VALUES ("${trProduct.Item}","${chosenClient.ClientID}", "${trProduct.Description}", ${trProduct.Q},${trProduct.Retail},"${trProduct.path}")')
          .then((value) {
        print("Record added Successfully");
      });
    });
  }

  void AddProductToCart(ShippedItem shippedItem, Client client) async {
    emit(addingproducttocardinprogress());
    InsertProductIntoDatabase(shippedItem.trProduct);
    chosenClient.orderitems.add(shippedItem);

    emit(ItemAddedToCart());
  }

  void resetTextFeilds(
      TextEditingController quantity,
      TextEditingController bounce,
      TextEditingController discountReplacmentToBounce,
      TextEditingController Addeddiscount,
      TextEditingController SpecialDiscount) {
      quantity.text = "";
    bounce.text = "";
    discountReplacmentToBounce.text = "";
    Addeddiscount.text = "";
    SpecialDiscount.text = "";
  }

  void deleteProduct(TrProduct trProduct,brand prevbrand,int index)async{
    emit(loadingbrangforupdate());
    brandsCollection.where("brandcode", isEqualTo: prevbrand.prandcode).get().then((value) {
      prevbrand.products.removeAt(index);
      brandsCollection.doc(value.docs.first.id).update({"products": prevbrand.toJson()["products"]}).then((value) {
        getbrands();
      });
    });
  }

  Future<void> updateProduct(TrProduct trProduct, brand prevbrand, int index) async {
    emit(loadingbrangforupdate());
    trProduct.path = await getUrlofImage(productImage);
    brandsCollection.where("brandcode", isEqualTo: prevbrand.prandcode).get().then((value) {
      updateBrandInFireBase(prevbrand, index, trProduct, value);
    });
  }

  void updateBrandInFireBase(brand prevbrand, int index, TrProduct trProduct, QuerySnapshot value) {
    prevbrand.products[index] = trProduct;
    brandsCollection.doc(value.docs.first.id).update({"products": prevbrand.toJson()["products"]});
    if (trProduct.Item.contains("/")) { trProduct.Item.replaceAll(new RegExp(r'[^\w\s]+')); }
    updateImageWithCodesCollection(trProduct);
  }

  void updateImageWithCodesCollection(TrProduct trProduct) {
    DocumentReference documentReference = FirebaseFirestore.instance.collection("ImagesWithCodes").doc(trProduct.Item);
    documentReference.set({"imageUrl": trProduct.path}).then((value) {
      getbrands().then((value) {
        emit(brandupdated());
      });
    });
  }

  void EditBrand(TextEditingController brandname, TextEditingController brandecode, brand currentbrand) async {
    if (brandname.text == "" || brandecode.text == "") {
      emit(emptystringfound());
    }
    else {
      brand newBrand = generateNewBrandWithNewChanges(brandname, brandecode, currentbrand);
      newBrand = await setFilesToNewBrand(newBrand, currentbrand);
      setUpdatedBrand(currentbrand.id, newBrand);
    }
  }

  Future<brand> setFilesToNewBrand(brand newBrand, brand currentbrand) async {
    newBrand = await UpdateBrandImage(newBrand,currentbrand.path);
    if (pdfFile == null && orderedFile == null) {
      newBrand =noFilesChanged(newBrand, currentbrand);
    }
    else if (pdfFile != null && orderedFile != null) {
      newBrand = await editBrandWithNewUpdatesInBothFiles(newBrand, currentbrand);
    }
    else {
      newBrand = await editBrandWithOnlyOneFileUpdated(newBrand, currentbrand);
    }
    return newBrand;
  }

  Future<brand> editBrandWithNewUpdatesInBothFiles(brand newbrand, brand currentbrand) async {
    newbrand = await generateBrandWithNewFiles(orderedFile, currentbrand, "orderedFile", updatedBrand: newbrand);
    newbrand = await generateBrandWithNewFiles(pdfFile, currentbrand, "mainFile", updatedBrand: newbrand);
    return newbrand;
  }

  brand generateNewBrandWithNewChanges(TextEditingController brandname, TextEditingController brandecode, brand currentbrand) {
     brand newbrand = brand(brandname.text, brandecode.text);
    newbrand.id = currentbrand.id;
    emit(loadingbrangforupdate());
    return newbrand;
  }

  Future<brand> editBrandWithOnlyOneFileUpdated(brand newbrand, brand currentbrand) async {
    if (orderedFile != null) {
      newbrand = await editOrderedFileOnly(newbrand, currentbrand);
    }
    else if (pdfFile != null) {
      newbrand = await editMainFileOnly(newbrand, currentbrand);
    }
    return newbrand;
  }

  Future<brand> editMainFileOnly(brand newbrand, brand currentbrand) async {
    newbrand.orderedFile = currentbrand.orderedFile;
    newbrand.orderedProducts = currentbrand.orderedProducts;
    newbrand = await generateBrandWithNewFiles(pdfFile, currentbrand, "mainFile", updatedBrand: newbrand);
    return newbrand;
  }

  Future<brand> editOrderedFileOnly(brand newbrand, brand currentbrand) async {
    newbrand.excelfilepath = currentbrand.excelfilepath;
    newbrand.products = currentbrand.products;
    newbrand = await generateBrandWithNewFiles(orderedFile, currentbrand, "orderedFile", updatedBrand: newbrand);
    return newbrand;
  }
  brand noFilesChanged(brand newbrand,brand currentbrand){
    newbrand.orderedFile = currentbrand.orderedFile;
    newbrand.orderedProducts = currentbrand.orderedProducts;
    newbrand.excelfilepath = currentbrand.excelfilepath;
    newbrand.products = currentbrand.products;
    return newbrand;
  }
  Future<brand> UpdateBrandImage(brand newbrand,String oldPath)async{
    if (image != null) {
      String path =await getUrlofImage(image);
      newbrand.path = path;
    }
    else {
      newbrand.path = oldPath;
    }
    return newbrand;
  }
  void setUpdatedBrand(String id, brand NewBrand) {
    brandsCollection.doc(id).update(NewBrand.toJson()).then((value) {
      emit(brandupdated());
      getbrands();
    });
  }

  Map<String, dynamic> convertListToMap(List<TrProduct> orderedProducts) {
    Map<String, dynamic> orderedBrand = {};
    for (int i = 0; i < orderedProducts.length; i++) {
      orderedBrand["${orderedProducts[i].Item}"] = i;
    }
    return orderedBrand;
  }

  Future<void> delectebrand(brand brandss) {
    emit(branddeleted());
    brandsCollection.where("brandcode", isEqualTo: brandss.prandcode).get().then((value) {
      brandsCollection.doc(value.docs.first.id).delete();
      getbrands();
      emit(branddeletedsuccfully());
    });
  }

  Future<List<TrProduct>> orderproducts(List<TrProduct> products, List<TrProduct> orderedProducts) async {
    Map<String, dynamic> orderedBrand = convertListToMap(orderedProducts);
    Map<String, dynamic> orderNumbers = {};
    Map<String, TrProduct> foundItems = {};
    for (int i = 0; i < products.length; i++) {
      if (orderedBrand.containsKey(products[i].Item)) {
        foundItems[products[i].Item] = products[i];
        orderNumbers[products[i].Item] = orderedBrand[products[i].Item];
      } else {
        products[i]= PutDefaultDataToItem(products, i);
        foundItems[products[i].Item] = products[i];
        orderNumbers[products[i].Item] = orderedBrand.length + 1;
      }
    }
    products = sortProducts(orderNumbers, foundItems);
    return products;
  }

  TrProduct PutDefaultDataToItem(List<TrProduct> products, int i) {
    products[i].Price = "0";
    products[i].Retail = "0";
    products[i].Q = "0";
    return products[i];
  }

  String getFileNameWithExtention(File file) {
    String extention = p.extension(file.path).split('.')[1];
    String filename = p.basename(file.path);
    return '${extention}s/$filename';
  }

  void emitnumberofloadedfilesfromexel(double numberofFiles) {
    emit(numberoffilestillNow(numberofFiles));
  }

  Future<brand> UpdateOrderedFile(brand updatedBrand, String path, List<TrProduct> products, brand currentbrand) async {
    updatedBrand.orderedFile = path;
    updatedBrand.orderedProducts = products;
    updatedBrand.products = await orderproducts(currentbrand.products, updatedBrand.orderedProducts);
    return updatedBrand;
  }

  Future<brand> UpdateMainFile(brand updatedBrand, String path, List<TrProduct> products, brand currentbrand) async {
    emit(orderproductsInProgress());
    updatedBrand.excelfilepath = path;
    if (updatedBrand.orderedProducts == [] || updatedBrand.orderedProducts == null) {
      updatedBrand.products = products;
    }
    else {
      products = await orderproducts(products, updatedBrand.orderedProducts);
      updatedBrand.products = products;
    }
    return updatedBrand;
  }

  Future<brand> UpdateBrandWithNewExcelFile(String typeOfFile, String path, List<TrProduct> products, brand updatedBrand, brand currentbrand) async {
    if (typeOfFile == "orderedFile") {
      updatedBrand = await UpdateOrderedFile(updatedBrand, path, products, currentbrand);
    } else {
      updatedBrand = await UpdateMainFile(updatedBrand, path, products, currentbrand);
    }
    print("return updated");
    return updatedBrand;
  }

  Future<brand> orderNewProducts(brand updatedBrand, List<TrProduct> NonOrderedProducts) async {
    updatedBrand.products = await orderproducts(NonOrderedProducts, updatedBrand.orderedProducts);
    return updatedBrand;
  }

  brand AddOrderedFileToNewBrand(brand currentbrand, String path, List<TrProduct> products) {
    currentbrand.orderedFile = path;
    currentbrand.orderedProducts = products;
    return currentbrand;
  }

  Future<brand> AddMainFileToNewBrand(brand currentbrand, String path, List<TrProduct> products) async {
    emit(orderproductsInProgress());
    currentbrand.excelfilepath = path;
    if (currentbrand.orderedProducts == [] || currentbrand.orderedProducts == null) {
      currentbrand.products = products;
    }
    else {
      products = await orderproducts(products, currentbrand.orderedProducts);
      currentbrand.products = products;
    }
    return currentbrand;
  }

  Future<brand> AddnewBrandWithExcelSheets(String typeOfFile, brand currentbrand, String path, List<TrProduct> products) async {
    if (typeOfFile == "orderedFile") {
      currentbrand = AddOrderedFileToNewBrand(currentbrand, path, products);
    } else {
      currentbrand = await AddMainFileToNewBrand(currentbrand, path, products);
    }
    return currentbrand;
  }

  Future<brand> generateBrandWithNewFiles(File file, brand currentBrand, String typeOfFile,{brand updatedBrand}) async {
    emit(loadingbrangforupdate());
    UploadTask uploadedFileProgress = SaveFileIntoFireBaseStorage(file);
    await uploadedFileProgress.then((value) async {
      await value.ref.getDownloadURL().then((path) async {
        emit(readingexcelFileInProgess());
        List<TrProduct> products = await readExcelFile(file.path, this, typeOfFile);
        if (updatedBrand != null) {
          updatedBrand=  await UpdateBrandWithNewExcelFile(typeOfFile, path, products, updatedBrand, currentBrand);
        }
        else {
          currentBrand = await AddnewBrandWithExcelSheets(typeOfFile, currentBrand, path, products);
        }
      });
    });
    if(updatedBrand!=null){
      return updatedBrand;
    }
    else{
      return currentBrand;
    }
  }

  Future<void> addnewbrand(TextEditingController brandname, TextEditingController brandecode) async {
    if (brandname.text == "" || brandecode.text == "") {
      emit(emptystringfound());
    }
    else {
      brand newbrand = brand(brandname.text, brandecode.text);
      emit(loadingbrangforupdate());
      newbrand = await handleBrandFiles(newbrand);
      await AddNewBrandToFireBase(newbrand);
    }
  }

  Future<brand> handleBrandFiles(brand newbrand) async {
    newbrand = await handleImageFile(newbrand);
    newbrand = await handleorderedFile(newbrand);
    newbrand = await handleMainFile(newbrand);
    return newbrand;
  }

  Future<brand> handleMainFile(brand newbrand) async {
    if (pdfFile != null) {
      newbrand = await generateBrandWithNewFiles(pdfFile, newbrand, "mainFile");
    } else {
      newbrand = addDefaultMainFilePathAndProducts(newbrand);
    }
    return newbrand;
  }

  brand addDefaultMainFilePathAndProducts(brand newbrand) {
    newbrand.excelfilepath = "https://icons.iconarchive.com/icons/custom-icon-design/mono-general-2/512/document-icon.png";
    newbrand.products = [];
    return newbrand;
  }

  brand addDefaultOrderedFilePathAndOrderedProducts(brand newbrand) {
    newbrand.orderedFile = "https://icons.iconarchive.com/icons/custom-icon-design/mono-general-2/512/document-icon.png";
    newbrand.orderedProducts = [];
    return newbrand;
  }

  Future<brand> handleorderedFile(brand newbrand) async {
    if (orderedFile != null) {
      newbrand = await generateBrandWithNewFiles(orderedFile, newbrand, "orderedFile");
    } else {
      newbrand = addDefaultOrderedFilePathAndOrderedProducts(newbrand);
    }
    return newbrand;
  }

  Future<brand> handleImageFile(brand newbrand) async {
    if (image == null) {
      newbrand.path = "https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";
    } else {
      String path = await getUrlofImage(image);
      newbrand.path = path;
    }
    return newbrand;
  }

  Future AddNewBrandToFireBase(brand newbrand) {
    brandsCollection.add(newbrand.toJson()).then((value) {
      brandsCollection.doc(value.id).update({"id": value.id});
      emit(brandadded());
      getbrands();
    });
  }

  Future<void> getbrands() async {
    resetCubitFilesAndLists();
    FirebaseFirestore.instance.collection('Brands').get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        brands.add(brand.fromJson(doc.data()));
      });
      emit(getbrandsstate());
    }).catchError((error) {});
  }

  void resetCubitFilesAndLists() {
    brands = [];
    orderedFile = null;
    image = null;
    pdfFile = null;
  }

  Future<File> uploadExcelFile(String typeOfFile) async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path);
      if (typeOfFile == "orderedFile")
        orderedFile = file;
      else
        pdfFile = file;
      emit(excelfileloaded());
      return file;
    }
  }
}
