class Representative{



  String represtativename,represtativecode,represtativenphone,represtativetarget,
      represtativearea1,represtativearea2,represtativearea3,represtativearea4,represtativesupervisor,
      represtativemanager,path,id,companyname,companyaddress,companyphone;

  Representative(
      this.companyname,
      this.companyaddress,
      this.companyphone,
      this.represtativename,
      this.represtativecode,
      this.represtativenphone,
      this.represtativetarget,
      this.represtativesupervisor,
      this.represtativemanager,
      [this.represtativearea1="",
      this.represtativearea2="",
      this.represtativearea3="",
      this.represtativearea4="",
      this.id,
      this.path]);

  Representative.fromJson(Map<String, dynamic> json) {

    companyname=json['companyname'];
    companyaddress=json['companyaddress'];
    companyphone=json['companyphone'];
    represtativename = json['represtativename'];
    represtativecode = json['represtativecode'];
    represtativenphone = json['represtativenphone'];
    represtativetarget = json['represtativetarget'];
    represtativesupervisor = json['represtativesupervisor'];
    represtativemanager = json['represtativemanager'];
    represtativearea1=json['represtativearea1'];
    represtativearea2=json['represtativearea2'];
    represtativearea3=json['represtativearea3'];
    represtativearea4=json['represtativearea4'];
    path=json['path'];
    id=json['id'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['companyname']=this.companyname;
    data['companyaddress']=this.companyaddress;
    data['companyphone']=this.companyphone;
    data['represtativename'] = this.represtativename;
    data['represtativecode'] = this.represtativecode;
    data['represtativenphone'] = this.represtativenphone;
    data['represtativetarget'] = this.represtativetarget;
    data['represtativesupervisor'] = this.represtativesupervisor;
    data['represtativemanager'] = this.represtativemanager;
    data['represtativearea1']=this.represtativearea1;
    data['represtativearea2']=this.represtativearea2;
    data['represtativearea3']=this.represtativearea3;
    data['represtativearea4']=this.represtativearea4;
    data['path']=this.path;
    data['id']=this.id;

    return data;
  }
}