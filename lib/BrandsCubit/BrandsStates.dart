import 'dart:io';
abstract class BrandsStates{}
class initialState extends BrandsStates{}
class fileisuploadingprogress extends BrandsStates{
  final double percentage;
  fileisuploadingprogress(this.percentage);
}
class getbrandsstate extends BrandsStates{}
class brandadded extends BrandsStates{}
class emptystringfound extends BrandsStates{}
class branddeleted extends BrandsStates{}
class branddeletedsuccfully extends BrandsStates{}
class brandupdated extends BrandsStates{}
class loadingbrangforupdate extends BrandsStates{}
class imageiscome extends BrandsStates{
  File image;
  imageiscome(this.image);
}
class tetxformfoucesState extends BrandsStates{}
class ItemAddedToCart extends BrandsStates{}
class removingitemfromcartinprogress extends BrandsStates{}
class OrderSavedState extends BrandsStates{}
class nochoosenclientforOrder extends BrandsStates{}
class noItemsInCart extends BrandsStates{}
class addingproducttocardinprogress extends BrandsStates{}
class itemremovedfromcart extends BrandsStates{}
class choosenclientState extends BrandsStates{}
class newSearchsugestionlist extends BrandsStates{}
class resetsearchbarState extends BrandsStates{}
class datagetfromcashe extends BrandsStates{}
class clientnotchoosen extends BrandsStates{}
class excelfileloaded extends BrandsStates{}
class ItemIsRemovedFromLocalDataBase extends BrandsStates{}

