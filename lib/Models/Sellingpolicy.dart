import 'file.dart';

class Sellingpolicy implements file
{

  Sellingpolicy(this.title);

  Sellingpolicy.fromJson(Map<String, dynamic> json) {
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

  @override
  String date;

  @override
  String defauktphoto;

  @override
  String extention;

  @override
  String id;

  @override
  String mainimagepath="https://www.pixsy.com/wp-content/uploads/2021/04/ben-sweet-2LowviVHZ-E-unsplash-1.jpeg";

  @override
  String path;

  @override
  String title;

}