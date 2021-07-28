
class TrProduct{
  dynamic Item,Description,Q1,Q2,Q,Price,Retail,Asset_Account,P_L_NO,BAR_CODE;
  String path="https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";

  TrProduct(this.Item, this.Description, this.Q1, this.Q2, this.Q, this.Price,
      this.Retail, this.Asset_Account, this.P_L_NO, this.BAR_CODE);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Item'] = this.Item;
    data['Description'] = this.Description;
    // data['1']=this.Q1;
    // data['2']=this.Q2;
    data['Q']=this.Q;
    data["Retail المستهلك"]=this.Retail;
    // data['Asset Account']=this.Asset_Account;
    // data['P.L.NO.']=this.P_L_NO;
    // data['BAR CODE']=this.BAR_CODE;
    data["path"]=this.path;
    return data;
  }

  TrProduct.fromJson(Map<String, dynamic> json) {
     this.Item=json['Item'];
     this.Description=json['Description'];
     // this.Q1= json['1'];
     // this.Q2= json['2'];
     this.Retail=json["Retail المستهلك"];
     this.Q=json['Q'];
     // this.Asset_Account=json['Asset Account'];
     // this.P_L_NO=json['P.L.NO.'];
     // this.BAR_CODE=json['BAR CODE'];
     this.path=json["path"];
  }

}