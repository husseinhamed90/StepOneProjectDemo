import 'package:steponedemo/Models/Visit.dart';

abstract class VisitsCubitStates{}

class initialState extends VisitsCubitStates{}
class choosenclientState extends VisitsCubitStates{}
class resetsearchbarState extends VisitsCubitStates{}
class newSearchsugestionlist extends VisitsCubitStates{}
class tetxformfoucesStateForVisit extends VisitsCubitStates{}


class AddingVisitInProgress extends VisitsCubitStates{}
class VisitAddedSuccssufully extends VisitsCubitStates{}
class VisitUpdatedSuccssufully extends VisitsCubitStates{}
class nochoosenclientForVisit extends VisitsCubitStates{}
class UpdatingVisitInProgress extends VisitsCubitStates{}
class RetrivingVisitsInProgress extends VisitsCubitStates{}
class LoadVisitsOfSelectedDateIsDone extends VisitsCubitStates{
  final List<visit>visitsoftheday;
  LoadVisitsOfSelectedDateIsDone(this.visitsoftheday);
}
class LoadVisitsDone extends VisitsCubitStates{
  final List<visit>visitsoftheday;
  LoadVisitsDone(this.visitsoftheday);
}
class novisitsfoundState extends VisitsCubitStates{}