import 'package:steponedemo/Models/Representative.dart';

abstract class RepresentatersState{}
class initialState extends RepresentatersState{}
class admindataiscame extends RepresentatersState{}
class validrepresentativestate extends RepresentatersState{}
class loaddatafromfirebase extends RepresentatersState{}
class representativeaddedsuccefulltstate extends RepresentatersState{
  Representative representative;
  representativeaddedsuccefulltstate(this.representative);
}
class representativeupdatedstate extends RepresentatersState{}
class updatestatuesloading extends RepresentatersState{}
class exitapp extends RepresentatersState{}
class imageiscome extends RepresentatersState{}
class dataofrepresentativeState extends RepresentatersState{}