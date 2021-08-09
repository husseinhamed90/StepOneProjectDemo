import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:steponedemo/AddsScreens/AddClientPage.dart';
import 'package:steponedemo/ClientsCubit/ClientsCubit.dart';
import 'package:steponedemo/Helpers/Shared.dart';
import 'package:steponedemo/Helpers/Utilites.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
import 'package:steponedemo/Models/Visit.dart';
import 'package:steponedemo/VisitsCubit/VisitsCubit.dart';
import 'package:steponedemo/VisitsCubit/VisitsCubitStates.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import 'package:steponedemo/constants.dart';
import 'package:toast/toast.dart';
class AddnewVisit extends StatefulWidget {

  String worktype,dayname,date;
  AddnewVisit(this.worktype,this.date,this.dayname);
  @override
  _AddnewVisitState createState() => _AddnewVisitState();
}

class _AddnewVisitState extends State<AddnewVisit> {
  String reason = 'غير محدد';
  String choosentime ='غير محدد';
  String timezonetype="غير محدد";

  String dayname=DateFormat.yMEd().add_jms().format(DateTime.now()).split(' ')[0];
  String date=DateFormat.yMEd().add_jms().format(DateTime.now()).split(' ')[1];
  DateTime currentDate =DateTime.now();
  bool v =false;
  Future<void> _selectDate(BuildContext context) async {

    final DateTime pickedDate = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2050));
    if (pickedDate != null ){
      setState(() {
        currentDate = pickedDate;
        List<String> DateInyMEd = [];
        DateInyMEd = DateFormat.yMEd().add_jms().format(currentDate).split(' ');
        dayname =getnameofdayinarabic(DateInyMEd[0]);
        String last = DateInyMEd[1].split('/')[1] +
            "/" +
            DateInyMEd[1].split('/')[0] +
            "/" +
            DateInyMEd[1].split('/')[2] +
            " - " +
            DateInyMEd[2];
        List<String> ff = last.split('-');
        setState(() {
          date=ff[0];
          dateController.text=dayname+" - "+date;
        });
      });
    }
  }
  TextEditingController searchbar=TextEditingController();
  TextEditingController dateController=TextEditingController();
  FocusNode myFocusNode=FocusNode();
  @override
  Widget build(BuildContext context) {

    return BlocConsumer<VisitsCubit,VisitsCubitStates>(
      listener: (context, state) {
        if(state is nochoosenclientForVisit){
          getsnackbar(context, "لم تقم ب اختيار صاحب الزيارة");
        }
        else if(state is VisitAddedSuccssufully){
          Toast.show("تم الحفظ بنجاح", context, duration: 2, gravity: Toast.BOTTOM);
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        print(state);
        VisitsCubit brandsCubit =VisitsCubit.get(context);
        if(state is AddingVisitInProgress){
          return Scaffold(
            body: Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        return Scaffold(
          appBar: PreferredSize(
            child: CustomAppbar("اضافة زيارة جديدة"),
            preferredSize: Size.fromHeight(70),
          ),
          body: Container(
            padding: const EdgeInsets.all(10),

            color: Color(0xffe6e6e6),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 55,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      width: (MediaQuery.of(context).size.width-20)*0.8,
                      child: FocusScope(
                        key: Key("value2"),
                        child: Focus(
                          focusNode: myFocusNode,
                          onFocusChange: (value) {
                            brandsCubit.textfroemfoucesstateForVistSerachBar(value);
                          },
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                v=true;
                              });
                            },
                            child: TextFormField(
                              enabled: v,
                              controller: searchbar,
                              onChanged: (value) {
                                if(brandsCubit.choosenclientForVisit!=null){
                                  brandsCubit.changesuggestionresultListOfVisit(searchbar.text, ClientsCubit.get(context).clients);
                                }
                                brandsCubit.changesuggestionresultListOfVisit(searchbar.text, ClientsCubit.get(context).clients);
                              },
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                                  hintText: "ادخل اسم العميل"),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                        alignment: Alignment.centerLeft,
                        height: 50,
                        width: (MediaQuery.of(context).size.width-20)*0.2,
                        child: FittedBox(
                          child: FloatingActionButton(
                            child: Icon(Icons.add),
                            backgroundColor: Colors.blue,
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AddnewClientPage(),));
                            },
                          ),
                        )
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Expanded(
                  child: (!brandsCubit.foucesstateForVisitSearchBar)?
                  Container(
                      height: double.infinity,
                      width: double.infinity,
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 20,left: 20,top: 10,bottom: 10),
                            height: 50,

                            child: LayoutBuilder(
                              builder: (context, constraints) => Row(
                                children: [
                                  Container(

                                    width: constraints.maxWidth*0.3,
                                    child: FittedBox(
                                      child: AutoSizeText("سبب الزيارة : ",style: TextStyle(
                                          fontSize: 16
                                      ),maxLines: 1,),
                                    ),
                                  ),
                                  // SizedBox(width: 20,),
                                  Container(
                                    key: Key("value3"),
                                    width: constraints.maxWidth*0.7,
                                    child: DropdownButton(

                                      value: reason,
                                      iconSize: constraints.maxWidth*0.07,
                                      items:reasons.map((String items) {
                                        return DropdownMenuItem(
                                            value: items,
                                            child: Container(width: constraints.maxWidth*0.63,child: AutoSizeText(items,style: TextStyle(fontSize: 18),maxLines: 1,))
                                        );
                                      }
                                      ).toList(),
                                      onChanged: (String newValue){
                                        setState(() {
                                          reason = newValue;
                                        });
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                            width: double.infinity,

                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            margin: EdgeInsets.only(right: 20,left: 20,top: 10,bottom: 10),
                            child: LayoutBuilder(
                              builder: (context, constraints) => Row(
                                children: [
                                  Container(
                                    width: constraints.maxWidth*0.3,
                                    child: AutoSizeText("الساعة ",style: TextStyle(
                                        fontSize: 16
                                    ),maxLines: 1,),
                                  ),
                                  Container(

                                    width: constraints.maxWidth*0.35,
                                    child: Center(
                                      child: DropdownButton(
                                        value: choosentime,
                                        items: hours.map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String newValue){
                                          setState(() {
                                            choosentime = newValue;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: constraints.maxWidth*0.35,
                                    child: Center(
                                      child: DropdownButton(
                                        value: timezonetype,
                                        items: clocktypes
                                            .map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String newValue){
                                          setState(() {
                                            timezonetype = newValue;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            margin: EdgeInsets.only(right: 20,left: 20,top: 10,bottom: 10),
                            child: LayoutBuilder(
                              builder: (context, constraints) => Row(
                                children: [
                                  Container(
                                    width: constraints.maxWidth*0.3,
                                    child: FittedBox(
                                      child: AutoSizeText("الزيارة القادمة ",style: TextStyle(
                                          fontSize: 16
                                      ),maxLines: 1,),
                                    ),
                                  ),
                                  Container(

                                    height: 55,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    ),
                                    width: constraints.maxWidth*0.5,
                                    child: TextFormField(
                                      controller: dateController,
                                      decoration: InputDecoration(
                                        enabled: false,
                                        border: InputBorder.none,
                                        // contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                                        // hintText: "ادخل اسم العميل"
                                      ),
                                    ),
                                  ),
                                  InkWell(onTap: () {

                                  },child: Container(
                                    width: constraints.maxWidth*0.2,
                                    child: CircleAvatar(child: IconButton(icon: Icon(Icons.date_range,), onPressed: (){
                                      _selectDate(context);
                                    })),
                                  )),
                                ],
                              ),

                            ),
                          )

                        ],
                      )
                  ):
                  ListView.builder(
                    itemBuilder: (context, index) {
                      return LayoutBuilder(
                          builder: (context, constraints) => InkWell(
                            onTap: () async{

                              brandsCubit.setChoosenClientForVisit(brandsCubit.suggestionresultForVisit[index]);
                              //await brandsCubit.getCachedData();
                              searchbar.text=brandsCubit.suggestionresultForVisit[index].clientname;
                              brandsCubit.resetClintForVisit();
                              setState(() {
                                v=false;
                              });
                              //brandsCubit.textfroemfoucesstateForVistSerachBar(false);
                            },
                            child: Container(
                                padding: EdgeInsets.all(10),
                                child: Text(brandsCubit.suggestionresultForVisit[index].clientname)
                            ),
                          ));
                    },
                    itemCount: brandsCubit.suggestionresultForVisit.length,
                  ),
                )
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            key: Key("savevisit"),
            child: Icon(Icons.save),
            onPressed: () {
              visit v = visit(reason, date, dayname,widget.date, widget.dayname,widget.worktype,choosentime, timezonetype,AppCubit.get(context).currentrepresentative.id);
              brandsCubit.AddNewVisit(v,widget.date);
            },
          ),
        );
      },
    );
  }
}
