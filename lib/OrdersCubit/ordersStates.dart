abstract class ordersStates{}

class initialState extends ordersStates{}
class emptystringfoundinpolicydata extends ordersStates{}
class Policyisuploading extends ordersStates{}
class downloadinprogressstate extends ordersStates{
  final int percentage;
  downloadinprogressstate(this.percentage);
}
class fileisuploadingprogress extends ordersStates{
  final double percentage;
  fileisuploadingprogress(this.percentage);
}
class PolicyisEndinguploading extends ordersStates{}
class loadfilefromfirebase extends ordersStates{}
class fileisdownloaded extends ordersStates{}
class imageiscome extends ordersStates{}
class documentcome extends ordersStates{}
class loaddatafromfirebase extends ordersStates{}
class Ordersloaded extends ordersStates{}
class OrderIsUpdated extends ordersStates{}