import 'file.dart';

class Order implements file
{
  String path,title,date,id,extention,defauktphoto,mainimagepath;

  Order(this.title);

  Order.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    mainimagepath=json['mainimagepath'];
    title = json['title'];
    date =json['date'];
    id=json['id'];
    extention=json['fileextention'];
    defauktphoto=json['defauktphoto'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['path'] = this.path;
    data['title'] = this.title;
    data['date']=this.date;
    data['id']=this.id;
    data['mainimagepath']=this.mainimagepath;
    data['defauktphoto']=this.defauktphoto;
    data['fileextention']=this.extention;
    return data;
  }

}