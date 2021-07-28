abstract class CatalogStates{}
class initialState extends CatalogStates{}
class emptystringfound extends CatalogStates{}
class loaddatafromfirebase extends CatalogStates{}
class upladingisfinished extends CatalogStates{}
class fileisuploading extends CatalogStates{}
class Catalogdeletedsuccfully extends CatalogStates{}
class imageiscome extends CatalogStates{}
class documentcome extends CatalogStates{}
class loadfilefromfirebase extends CatalogStates{}
class dataiscome extends CatalogStates{}
class fileisdownloaded extends CatalogStates{}
class Catalogisuploading extends CatalogStates{}
class downloadinprogressstate extends CatalogStates{
  final int percentage;
  downloadinprogressstate(this.percentage);
}
class fileisuploadingprogress extends CatalogStates{
  final double percentage;
  fileisuploadingprogress(this.percentage);
}