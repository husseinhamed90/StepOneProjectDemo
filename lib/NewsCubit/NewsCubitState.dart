abstract class NewsCubitState{}
class initialState extends NewsCubitState{}
class documentcome extends NewsCubitState{}
class emptystringfoundinNewdata extends NewsCubitState{}
class newisuploading extends NewsCubitState{}
class loadfilefromfirebase extends NewsCubitState{}
class Newsloaded extends NewsCubitState{}
class imageiscome extends NewsCubitState{}
class loaddatafromfirebase extends NewsCubitState{}
class fileisdownloaded extends NewsCubitState{}
class newDeletedSuccfully extends NewsCubitState{}
class newsloaded extends NewsCubitState{}
class numberofnewsUpdated extends NewsCubitState{}
class downloadinprogressstate extends NewsCubitState{
  final int percentage;
  downloadinprogressstate(this.percentage);
}
class fileisuploadingprogress extends NewsCubitState{
  final double percentage;
  fileisuploadingprogress(this.percentage);
}
class NewisEndinguploading extends NewsCubitState{}