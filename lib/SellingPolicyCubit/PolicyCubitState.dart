abstract class PolicyCubitState {}
class initialState extends PolicyCubitState{}
class emptystringfoundinpolicydata extends PolicyCubitState{}

class Policyisuploading extends PolicyCubitState{}
class policesloaded extends PolicyCubitState{}

class datadeletedsuccsefully extends PolicyCubitState{}
class downloadinprogressstate extends PolicyCubitState{
  final int percentage;
  downloadinprogressstate(this.percentage);
}
class fileisuploadingprogress extends PolicyCubitState{
  final double percentage;
  fileisuploadingprogress(this.percentage);
}

class PolicyisEndinguploading extends PolicyCubitState{}

class loadfilefromfirebase extends PolicyCubitState{}

class fileisdownloaded extends PolicyCubitState{}

class imageiscome extends PolicyCubitState{}
class documentcome extends PolicyCubitState{}
class loaddatafromfirebase extends PolicyCubitState{}
class updatestatuesloadingPolicyScreenState extends PolicyCubitState{}


class Policyloaded extends PolicyCubitState{}

