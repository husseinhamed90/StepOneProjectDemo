import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';

import '../ListsScreens/ClientOrdersList.dart';
import 'package:steponedemo/ClientsCubit/ClientsCubit.dart';
import 'package:steponedemo/VisitsCubit/VisitsCubit.dart';
import 'package:steponedemo/VisitsCubit/VisitsCubitStates.dart';
import '../Helpers/Shared.dart';
import 'tables.dart';
import 'CreatePdf.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
class Reports extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Reports> {


  DateTime currentDate =DateTime.now();
  String selectedday;
  Future<void> selectDate(BuildContext context) async {

    final DateTime pickedDate = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2050));
    if (pickedDate != null){
      print(pickedDate);
      setState(() {
        currentDate = pickedDate;
        List<String> DateInyMEd = [];
        DateInyMEd = DateFormat.yMEd().add_jms().format(currentDate).split(' ');
        String last = DateInyMEd[1].split('/')[1] +
            "/" +
            DateInyMEd[1].split('/')[0] +
            "/" +
            DateInyMEd[1].split('/')[2] +
            " - " +
            DateInyMEd[2];
        List<String> ff = last.split('-');
        selectedday=ff[0];
        VisitsCubit.get(context).GetVisitsOfUser(AppCubit.get(context).currentrepresentative.id,ff[0]);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
          return Scaffold(
            appBar: PreferredSize(
              child: CustomAppbar("التقارير"),
              preferredSize: Size.fromHeight(70),
            ),
            body:  BlocConsumer<VisitsCubit,VisitsCubitStates>(
              listener: (context, state) {
                if(state is LoadVisitsOfSelectedDateIsDone){
                  saveTableToPdf(AppCubit.get(context).currentrepresentative, 'زياراتي.pdf',typeofwork: state.visitsoftheday[0].TypeofWork,dayofdate: state.visitsoftheday[0].dayOfCurrentVisit,choosendate: selectedday,visits:state.visitsoftheday );
                }
                else if(state is novisitsfoundState){
                  getsnackbar(context, "لا توجد زيارات في هذا اليوم");
                }
              },
              builder: (context, state) {
                if(state is RetrivingVisitsInProgress){
                  return Scaffold(
                    body: Container(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                return Container(
                  color: Colors.white,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomTextButtom(()async{
                            savePdf(AppCubit.get(context).currentrepresentative);
                          },"بيانات المندوب"),
                          CustomTextButtom(()async{
                            await saveTableToPdf(AppCubit.get(context).currentrepresentative, 'بيانات العملاء.pdf',clientsCubit:ClientsCubit.get(context) );
                          },"بيانات العملاء"),
                          CustomTextButtom((){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ClientOrdersList(),));
                          },"اوردراتي"),
                          CustomTextButtom(()async{
                            await selectDate(context);
                          },"زياراتي")
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          );
        }
}
