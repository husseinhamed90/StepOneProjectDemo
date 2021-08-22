import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:steponedemo/Widgets/CircularProgressIndicatorForDownload.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import '../AddsScreens/AddnewSellingPolicy.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
import 'package:steponedemo/SellingPolicyCubit/PolicyCubitState.dart';
import 'package:steponedemo/Widgets/BuildPolicyItem.dart';
import '../SellingPolicyCubit/PolicyCubit.dart';

class Sellingpolicypage  extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PolicyCubit,PolicyCubitState>(
      listener: (context, state) {
      },
      builder: (context, state) {
        PolicyCubit policyCubit =PolicyCubit.get(context);
        if(state is loaddatafromfirebase){
          return Scaffold(
            body: Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        else if(state is downloadinprogressstate){
          return CircularProgressBarIndicatorDorDownload(state.percentage);
        }
        return Scaffold(
            appBar: PreferredSize(child: CustomAppbar("السياسة البيعية") ,preferredSize: Size.fromHeight(70),),
            body:  RefreshIndicator(
              onRefresh: () async=> await PolicyCubit.get(context).getpolices(),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child:Container(
                  color: Color(0xffe6e6e6),
                  height: MediaQuery.of(context).size.height-200,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return LayoutBuilder(
                        builder: (context, constraints) => BuildPolicyItem(policyCubit, policyCubit.polices[index],constraints)
                      );
                    },
                    itemCount: policyCubit.polices.length,
                  ),
                ),
              ),
            ),
            floatingActionButton:(AppCubit.get(context).currentUser.usertype=="admin")? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () async{
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddnewSellingPolicyss(),));
              },
            ):Container()
        );
      },
    );
  }
}

