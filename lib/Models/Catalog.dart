import 'file.dart';

class Catalog implements file{
  String path,title,date,id,extention,defauktphoto,mainimagepath;

  Catalog( this.title);

  Catalog.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    title = json['title'];
    date =json['date'];
    id=json['id'];
    mainimagepath=json['mainimagepath'];
    extention=json['fileextention'];
    defauktphoto=json['defauktphoto'];
  }
  @override
  Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['path'] = this.path;
      data['title'] = this.title;
      data['date']=this.date;
      data['id']=this.id;
      data['mainimagepath']=this.mainimagepath;
      data['fileextention']=this.extention;
      data['defauktphoto']=this.defauktphoto;
      return data;
  }
}