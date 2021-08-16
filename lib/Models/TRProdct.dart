class TrProduct{
  dynamic Item,Description,Q1,Q2,Q,Price,Retail,Asset_Account,P_L_NO,BAR_CODE;
  String path="https://zainabalkhudairi.com/wp-content/uploads/2020/01/%D9%84%D8%A7-%D8%AA%D9%88%D8%AC%D8%AF-%D8%B5%D9%88%D8%B1%D8%A9.png";

  TrProduct(this.Item, this.Description, this.Q1, this.Q2, this.Q, this.Price,
      this.Retail, this.Asset_Account, this.P_L_NO, this.BAR_CODE);

  TrProduct.CodesWithNames(this.Item, this.Description);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Item'] = this.Item;
    data['Description'] = this.Description;
    data['Q']=this.Q;
    data["Retail المستهلك"]=this.Retail;
    data["path"]=this.path;
    return data;
  }

  TrProduct.fromJson(Map<String, dynamic> json) {
     this.Item=json['Item'];
     this.Description=json['Description'];
     this.Retail=json["Retail المستهلك"];
     this.Q=json['Q'];
     this.path=json["path"];
  }

  Map<String, dynamic> toJsonForCodesWithNames() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Item'] = this.Item;
    data['Description'] = this.Description;
    data["path"]=this.path;
    return data;
  }
  TrProduct.fromJsonForCodesWithNames(Map<String, dynamic> json) {
    this.Item=json['Item'];
    this.Description=json['Description'];
    this.path=json["path"];
  }

}