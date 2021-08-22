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
      print(valuee);
      valuee.forEach((element) {
        setClientCachedItems(element);
        emit(datagetfromcashe());
      });
    });
  }

  void setClientCachedItems(Map<String, Object> element) {
    TrProduct trProduct = TrProduct.fromJson(element);
    trProduct.Retail = element['Retail'];
    ShippedItem shippedItem = ShippedItem(
        trProduct,
        element['quantity'],
        element['bounce'],
        element['Discountinsteadofbonus'],
        element['Discountinsteadofadding'],
        element['specialDiscount']);
    chosenClient.mapOfOrderedItems[trProduct.Item]=shippedItem;
    chosenClient.orderitems.add(shippedItem);
    print( chosenClient.orderitems);
    emit(datagetfromcashe());
  }

  Future deleteOrderFromDatabase() async {

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

  Future deleteItemFromOrderFromDatabase(TrProduct trProduct) async {
    emit(removingitemfromcartinprogress());
    return database.rawDelete('DELETE FROM products WHERE (ClientID = "${chosenClient.ClientID}" AND Item = "${trProduct.Item}")').then((value) {
      removeItemFromChosenClientOrder(trProduct);
    });
  }

  void removeItemFromChosenClientOrder(TrProduct trProduct) {
     for (int i = 0; i < chosenClient.orderitems.length; i++) {
      if (chosenClient.orderitems[i].trProduct.Item == trProduct.Item) {
        chosenClient.orderitems.removeAt(i);
        chosenClient.mapOfOrderedItems.remove(trProduct.Item);
        emit(itemremovedfromcart());
      }
    }
  }

  void insertOrderIntoFireBase(String representativeId) {
    if (chosenClient.orderitems.length > 0)
      insertOrder(representativeId);
    else
      emit(noItemsInCart());
  }

  void insertOrder(String representativeId) {
    emit(addingproducttocardinprogress());
    List<Map<String, dynamic>> mapOfOrderItems = putItemsInMap;
    insertNewOrderIntoFireBase(mapOfOrderItems, representativeId);
  }

  void insertNewOrderIntoFireBase(List<Map<String, dynamic>> mapOfOrderItems, String representativeId) {
    FirebaseFirestore.instance.collection('ClientOrders').add(getMapOfOrderInformation(mapOfOrderItems, representativeId)).then((value) {
      updateLocationOfNewDocument(value);
    });
  }

  void updateLocationOfNewDocument(DocumentReference value) {
    FirebaseFirestore.instance.collection('ClientOrders').doc(value.id).update({"location": value.id}).then((value) {
      deleteOrderFromDatabase().then((value) {
        emit(OrderSavedState());
      });
    });
  }

  Map<String, dynamic> getMapOfOrderInformation(List<Map<String, dynamic>> mapOfOrderItems, String representativeId) {
    return {
    "OrderOwner": chosenClient.ClientID,
    "OrderItems": mapOfOrderItems,
    "date": getDateWithoutTime(),
    "representativeID": representativeId
   };
  }

  List<Map<String, dynamic>> get putItemsInMap {
     List<Map<String, dynamic>> mapOfOrderItems = [];
    chosenClient.orderitems.forEach((element) {
      mapOfOrderItems.add(element.toJson());
    });
    return mapOfOrderItems;
  }

  void setChosenClient(Client client) {
    chosenClient = client;
    emit(choosenclientState());
  }

  void resetSearchBar() {
    suggestionResult = [];
    focusState = false;
    chosenClient=Client.noClient();
    emit(resetsearchbarState());
  }

  void changeSuggestionResultList(String searchedstring, List<Client> clients) {

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

  void textFormFocusState(bool b) {
    focusState = b;
    emit(tetxformfoucesState());
  }

  Future insertProductIntoDatabase(ShippedItem shippedItem) async {
    database.transaction((txn) {
      return txn.rawInsert('INSERT INTO products (Item,ClientID,Description,Q,Retail,path,quantity,bounce,Discountinsteadofbonus,Discountinsteadofadding,specialDiscount) VALUES ("${shippedItem.trProduct.Item}","${chosenClient.ClientID}", "${shippedItem.trProduct.Description}", ${shippedItem.trProduct.Q},${shippedItem.trProduct.Retail},"${shippedItem.trProduct.path}",${shippedItem.quantity},${shippedItem.bounce},${shippedItem.Discount_instead_of_bonus},${shippedItem.Discount_instead_of_adding},${shippedItem.specialDiscount})').then((value) {
        print("Record added Successfully");
      });
    });
  }

  void updateShippedItem(String itemKey,ShippedItem shippedItem){
    chosenClient.mapOfOrderedItems[itemKey]=shippedItem;
    for(int i=0;i<chosenClient.orderitems.length;i++){
      if(chosenClient.orderitems[i].trProduct.Item==itemKey){
        chosenClient.orderitems[i]=shippedItem;
        emit(shippedItemUpdated());
        return;
      }
    }
  }
  void addProductToCart(ShippedItem shippedItem, Client client) async {
    emit(addingproducttocardinprogress());
    insertProductIntoDatabase(shippedItem);
    chosenClient.orderitems.add(shippedItem);
    chosenClient.mapOfOrderedItems[shippedItem.trProduct.Item]=shippedItem;
    emit(ItemAddedToCart());
  }

  void resetTextFields(
      TextEditingController quantity,
      TextEditingController bounce,
      TextEditingController discountReplacementToBounce,
      TextEditingController addedDiscount,
      TextEditingController specialDiscount) {
      quantity.text = "";
    bounce.text = "";
      discountReplacementToBounce.text = "";
    addedDiscount.text = "";
    specialDiscount.text = "";
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
    trProduct.path = await getUrlOfImage(productImage);
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

  void editBrand(TextEditingController brandname, TextEditingController brandecode, brand currentbrand) async {
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
    newBrand = await updateBrandImage(newBrand,currentbrand.path);
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

  Future<brand> updateBrandImage(brand newbrand,String oldPath)async{
    if (image != null) {
      String path =await getUrlOfImage(image);
      newbrand.path = path;
    }
    else {
      newbrand.path = oldPath;
    }
    return newbrand;
  }

  void setUpdatedBrand(String id, brand newBrand) {
    brandsCollection.doc(id).update(newBrand.toJson()).then((value) {
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

  Future delectebrand(brand brand) {
    emit(branddeleted());
    brandsCollection.where("brandcode", isEqualTo: brand.prandcode).get().then((value) {
      brandsCollection.doc(value.docs.first.id).delete();
      getbrands();
      emit(branddeletedsuccfully());
    });
  }

  Future<List<TrProduct>> orderProducts(List<TrProduct> products, List<TrProduct> orderedProducts) async {
    Map<String, dynamic> orderedBrand = convertListToMap(orderedProducts);
    Map<String, dynamic> orderNumbers = {};
    Map<String, TrProduct> foundItems = {};
    for (int i = 0; i < products.length; i++) {
      if (orderedBrand.containsKey(products[i].Item)) {
        foundItems[products[i].Item] = products[i];
        orderNumbers[products[i].Item] = orderedBrand[products[i].Item];
      } else {
        products[i]= putDefaultDataToItem(products, i);
        foundItems[products[i].Item] = products[i];
        orderNumbers[products[i].Item] = orderedBrand.length + 1;
      }
    }
    products = sortProducts(orderNumbers, foundItems);
    return products;
  }

  TrProduct putDefaultDataToItem(List<TrProduct> products, int i) {
    products[i].Price = "0";
    products[i].Retail = "0";
    products[i].Q = "0";
    return products[i];
  }

  void emitNumberOfLoadedFilesFromExcel(double numberofFiles) {
    emit(numberoffilestillNow(numberofFiles));
  }

  Future<brand> updateOrderedFile(brand updatedBrand, String path, List<TrProduct> products, brand currentbrand) async {
    updatedBrand.orderedFile = path;
    updatedBrand.orderedProducts = products;
    updatedBrand.products = await orderProducts(currentbrand.products, updatedBrand.orderedProducts);
    return updatedBrand;
  }

  Future<brand> updateMainFile(brand updatedBrand, String path, List<TrProduct> products, brand currentbrand) async {
    emit(orderproductsInProgress());
    updatedBrand.excelfilepath = path;
    if (updatedBrand.orderedProducts == [] || updatedBrand.orderedProducts == null) {
      updatedBrand.products = products;
    }
    else {
      products = await orderProducts(products, updatedBrand.orderedProducts);
      updatedBrand.products = products;
    }
    return updatedBrand;
  }

  Future<brand> updateBrandWithNewExcelFile(String typeOfFile, String path, List<TrProduct> products, brand updatedBrand, brand currentbrand) async {
    if (typeOfFile == "orderedFile") {
      updatedBrand = await updateOrderedFile(updatedBrand, path, products, currentbrand);
    } else {
      updatedBrand = await updateMainFile(updatedBrand, path, products, currentbrand);
    }
    print("return updated");
    return updatedBrand;
  }

  Future<brand> orderNewProducts(brand updatedBrand, List<TrProduct> nonOrderedProducts) async {
    updatedBrand.products = await orderProducts(nonOrderedProducts, updatedBrand.orderedProducts);
    return updatedBrand;
  }

  brand addOrderedFileToNewBrand(brand currentbrand, String path, List<TrProduct> products) {
    currentbrand.orderedFile = path;
    currentbrand.orderedProducts = products;
    return currentbrand;
  }

  Future<brand> addMainFileToNewBrand(brand currentbrand, String path, List<TrProduct> products) async {
    emit(orderproductsInProgress());
    currentbrand.excelfilepath = path;
    if (currentbrand.orderedProducts == [] || currentbrand.orderedProducts == null) {
      currentbrand.products = products;
    }
    else {
      products = await orderProducts(products, currentbrand.orderedProducts);
      currentbrand.products = products;
    }
    return currentbrand;
  }

  Future<brand> addNewBrandWithExcelSheets(String typeOfFile, brand currentbrand, String path, List<TrProduct> products) async {
    if (typeOfFile == "orderedFile") {
      currentbrand = addOrderedFileToNewBrand(currentbrand, path, products);
    } else {
      currentbrand = await addMainFileToNewBrand(currentbrand, path, products);
    }
    return currentbrand;
  }

  Future<brand> generateBrandWithNewFiles(File file, brand currentBrand, String typeOfFile,{brand updatedBrand}) async {
    emit(loadingbrangforupdate());
    UploadTask uploadedFileProgress = saveFileIntoFireBaseStorage(file);
    await uploadedFileProgress.then((value) async {
      await value.ref.getDownloadURL().then((path) async {
        emit(readingexcelFileInProgess());
        List<TrProduct> products = await readExcelFile(file.path, this, typeOfFile);
        if (updatedBrand != null) {
          updatedBrand=  await updateBrandWithNewExcelFile(typeOfFile, path, products, updatedBrand, currentBrand);
        }
        else {
          currentBrand = await addNewBrandWithExcelSheets(typeOfFile, currentBrand, path, products);
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

  Future<void> addNewBrand(TextEditingController brandName, TextEditingController brandeCode) async {
    if (brandName.text == "" || brandeCode.text == "") {
      emit(emptystringfound());
    }
    else {
      brand newBrand = brand(brandName.text, brandeCode.text);
      emit(loadingbrangforupdate());
      newBrand = await handleBrandFiles(newBrand);
      await AddNewBrandToFireBase(newBrand);
    }
  }

  Future<brand> handleBrandFiles(brand newBrand) async {
    newBrand = await handleImageFile(newBrand);
    newBrand = await handleOrderedFile(newBrand);
    newBrand = await handleMainFile(newBrand);
    return newBrand;
  }

  Future<brand> handleMainFile(brand newBrand) async {
    if (pdfFile != null) {
      newBrand = await generateBrandWithNewFiles(pdfFile, newBrand, "mainFile");
    } else {
      newBrand = addDefaultMainFilePathAndProducts(newBrand);
    }
    return newBrand;
  }

  brand addDefaultMainFilePathAndProducts(brand newBrand) {
    newBrand.excelfilepath = "https://icons.iconarchive.com/icons/custom-icon-design/mono-general-2/512/document-icon.png";
    newBrand.products = [];
    return newBrand;
  }

  brand addDefaultOrderedFilePathAndOrderedProducts(brand newBrand) {
    newBrand.orderedFile = "https://icons.iconarchive.com/icons/custom-icon-design/mono-general-2/512/document-icon.png";
    newBrand.orderedProducts = [];
    return newBrand;
  }

  Future<brand> handleOrderedFile(brand newBrand) async {
    if (orderedFile != null) {
      newBrand = await generateBrandWithNewFiles(orderedFile, newBrand, "orderedFile");
    } else {
      newBrand = addDefaultOrderedFilePathAndOrderedProducts(newBrand);
    }
    return newBrand;
  }

  Future<brand> handleImageFile(brand newBrand) async {
    if (image == null) {
      newBrand.path = "https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";
    } else {
      String path = await getUrlOfImage(image);
      newBrand.path = path;
    }
    return newBrand;
  }

  Future AddNewBrandToFireBase(brand newBrand) {
    brandsCollection.add(newBrand.toJson()).then((value) {
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
