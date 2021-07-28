class Client{
  String path,clientname,phone,id,address,area,clinttype,ClientID,path2;
  String clientcode ="-";
  List<dynamic>orderitems=[];

  Client(this.clientname, this.clientcode,
      this.phone, this.address,
      this.area,[this.clinttype="غير محدد"]);

  Client.fromJson(Map<String, dynamic> json) {
    clientname = json['clientname'];
    clientcode = json['clientcode'];
    phone =json['phone'];
    id=json['id'];
    path=json['path'];
    path2=json['path2'];
    ClientID=json['ClientID'];
    address=json['address'];
    area=json['area'];
    clinttype=json['clinttype'];
  }

  Client.clone(Client randomObject): this(
      randomObject.clientname,
      randomObject.clientcode,
      randomObject.phone,
      randomObject.address,
      randomObject.area,
      randomObject.clinttype);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['clientname'] = this.clientname;
    data['clientcode'] = this.clientcode;
    data['phone']=this.phone;
    data['id']=this.id;
    data['path']=this.path;
    data['path2']=this.path2;
    data['address']=this.address;
    data['area']=this.area;
    data['clinttype']=this.clinttype;
    data['ClientID']=this.ClientID;
    return data;
  }
}