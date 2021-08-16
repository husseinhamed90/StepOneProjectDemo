import 'file.dart';

class News implements file{
  DateTime dataTime;

  News( this.title);

  News.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    title = json['title'];
    mainimagepath=json['mainimagepath'];

    date =json['date'];
    id=json['id'];
    extention=json['extention'];
    defauktphoto=json['defauktphoto'];
  }



  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['path'] = this.path;
    data['title'] = this.title;
    data['mainimagepath']=this.mainimagepath;
    data['date']=this.date;
    data['id']=this.id;
    data['extention']=this.extention;
    data['defauktphoto']=this.defauktphoto;
    return data;
  }

  @override
  String mainimagepath;

  @override
  String date;

  @override
  String defauktphoto;

  @override
  String extention;

  @override
  String id;

  @override
  String path;

  @override
  String title;

}