import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:steponedemo/Widgets/BuildVisitItem.dart';
import '../AddsScreens/AddNewVisit.dart';
import 'package:steponedemo/Helpers/Utilites.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
import 'package:steponedemo/VisitsCubit/VisitsCubit.dart';
import 'package:steponedemo/VisitsCubit/VisitsCubitStates.dart';
import 'package:steponedemo/constants.dart';
import '../Helpers/Shared.dart';
class Schadule extends StatefulWidget {
  @override
  _SchaduleState createState() => _SchaduleState();
}

class _SchaduleState extends State<Schadule> {
  String dayname=DateFormat.yMEd().add_jms().format(DateTime.now()).split(' ')[0];
  String date;
  DateTime currentDate =DateTime.now();
  @override
  void initState(){
    super.initState();
    List<String> ss = DateFormat.yMEd().add_jms().format(currentDate).split(' ');
    date =getDate(ss);
    dayname =getnameofdayinarabic(dayname);
    VisitsCubit.get(context).GetVisitsOfUser(AppCubit.get(context).currentrepresentative.id,date);
  }

  Future<void> _selectDate(BuildContext context) async {

    final DateTime pickedDate = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2050));
    if (pickedDate != null){
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
          VisitsCubit.get(context).GetVisitsOfUser(AppCubit.get(context).currentrepresentative.id,date);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: PreferredSize(
        child: AppBar(
          actions: [
            Container(
              child: CircleAvatar(child: IconButton(icon: Icon(Icons.search,), onPressed: (){
                _selectDate(context);
              })),
              margin: EdgeInsets.only(left: 10,top: 5),),
            InkWell(onTap: () {
              Navigator.pop(context);
            },child: Container(child: Image.asset("assets/backbutton.jpg",),margin: EdgeInsets.only(left: 10,top: 10),)),
          ],
          backgroundColor: Colors.white,
          elevation: 0,
          title: Container(
              height: 40,
              width: MediaQuery.of(context).size.width*0.5
              ,child: FittedBox(child: AutoSizeText("مواعيد الزيارات",style: TextStyle(fontSize: 25,color: Colors.black),maxLines: 1,))),
          leading:  Container(
            child: GestureDetector(onTap: () {

              showDialog(context: context, builder: (context) {
                return AlertDialog(
                  content: Container(
                    child: Text("هل تريد اغلاق التطبيق ؟"),
                  ),
                  actions: [
                    TextButton(onPressed: () {
                      Navigator.pop(context);
                      updateuserstatus('false',context).then((value) {
                      });
                    }, child: Text("نعم")),
                    TextButton(onPressed: () => Navigator.pop(context), child: Text("لا")),
                  ],
                );
              },
              );
            },child: Container(child: Image.asset("assets/exit.jpg",),margin: EdgeInsets.only(right: 10,top: 5),)),
          ),
          centerTitle: true,
        ),
        preferredSize: Size.fromHeight(70),
      ),
      body: BlocConsumer<VisitsCubit,VisitsCubitStates>(
        listener: (context, state) {
          if(state is LoadVisitsDone){
            if(state.visitsoftheday.isEmpty==false){
              worktype=state.visitsoftheday[0].TypeofWork;
            }
          }
        },
        builder: (context, state) {
          VisitsCubit visitsCubit =VisitsCubit.get(context);
          if(state is RetrivingVisitsInProgress){
            return Scaffold(
              body: Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
          return  RefreshIndicator(
            onRefresh: () => visitsCubit.GetVisitsOfUser(AppCubit.get(context).currentrepresentative.id,date),
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Color(0xffe6e6e6),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10,right: 10,top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            worktype="غير محدد";
                            List<String> ss = DateFormat.yMEd().add_jms().format(currentDate.add(Duration(days: 1))).split(' ');
                            dayname =getnameofdayinarabic(ss[0]);
                            currentDate=currentDate.add(Duration(days: 1));
                            date =getDate(ss);
                            VisitsCubit.get(context).GetVisitsOfUser(AppCubit.get(context).currentrepresentative.id,date);
                          },
                          child: Container(
                            height: 40,
                            child: FittedBox(
                              child: CircleAvatar(child: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
                                List<String> ss = DateFormat.yMEd().add_jms().format(currentDate.add(Duration(days: 1))).split(' ');
                                worktype="غير محدد";
                                dayname =getnameofdayinarabic(ss[0]);
                                currentDate=currentDate.add(Duration(days: 1));
                                date =getDate(ss);
                                VisitsCubit.get(context).GetVisitsOfUser(AppCubit.get(context).currentrepresentative.id,date);

                              })),
                            ),
                          ),
                        ),
                        //Spacer(),
                        AutoSizeText(dayname+" - "+date,style: TextStyle(
                            fontSize: 20,fontWeight: FontWeight.bold
                        ),maxLines: 1,),
                        InkWell(
                          onTap: () {
                            worktype="غير محدد";
                            List<String> ss = DateFormat.yMEd().add_jms().format(currentDate.subtract(Duration(days: 1))).split(' ');
                            dayname =getnameofdayinarabic(ss[0]);
                            currentDate=currentDate.subtract(Duration(days: 1));
                            date =getDate(ss);
                            VisitsCubit.get(context).GetVisitsOfUser(AppCubit.get(context).currentrepresentative.id,date);
                          },
                          child: Container(
                            height: 40,
                            child: FittedBox(
                              child: CircleAvatar(child: IconButton(icon: Icon(Icons.arrow_forward_rounded), onPressed: (){
                                worktype="غير محدد";
                                List<String> ss = DateFormat.yMEd().add_jms().format(currentDate.subtract(Duration(days: 1))).split(' ');
                                dayname =getnameofdayinarabic(ss[0]);
                                currentDate=currentDate.subtract(Duration(days: 1));
                                date =getDate(ss);
                                VisitsCubit.get(context).GetVisitsOfUser(AppCubit.get(context).currentrepresentative.id,date);
                              })),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20,left: 20,top: 10,bottom: 10),
                    height: 50,

                    child: LayoutBuilder(
                      builder: (context, constraints) => Row(
                        children: [
                          Container(
                            height: 35,
                            alignment: Alignment.centerRight,
                            width: constraints.maxWidth*0.3,
                            child: FittedBox(
                              child: Text("نوع العمل : ",style: TextStyle(
                                  fontSize: 20
                              ),maxLines: 1,),
                            ),
                          ),
                          //SizedBox(width: 20,),
                          Container(
                            alignment: Alignment.centerRight,
                            height: 35,
                            width: constraints.maxWidth*0.7,
                            child: DropdownButton(

                              value: worktype,
                              iconSize: constraints.maxWidth*0.07,
                              items:typesofwork.map((String items) {
                                return DropdownMenuItem(
                                    value: items,
                                    child: Container(
                                        height: 35,
                                        alignment: Alignment.centerRight,
                                        width: constraints.maxWidth*0.63,
                                        child: FittedBox(child: Text(items,style: TextStyle(fontSize: 18),maxLines: 1,)))
                                );
                              }
                              ).toList(),
                              onChanged: (String newValue){
                                setState(() {
                                  worktype = newValue;
                                  visitsCubit.updateworktypetovisits(AppCubit.get(context).currentrepresentative.id,date,worktype);
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    width: double.infinity,

                  ),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return BuildVisitItem(visitsCubit, index, date);
                      },
                      itemCount: visitsCubit.visits.length,
                    ),
                  ),
                  Container(
                    height: 80,
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(worktype=="غير محدد"){
            getsnackbar(context, "من فضلك قم باختيار نوع العمل اولا");
          }
          else{
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddnewVisit(worktype,date,dayname),));
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
