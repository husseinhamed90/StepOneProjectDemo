
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:steponedemo/NewsCubit/NewsCubit.dart';
import 'package:steponedemo/Widgets/BuildNewItem.dart';
import 'package:steponedemo/Widgets/CircularProgressIndicatorForDownload.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import '../AddsScreens/AddnewNews.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
import 'package:steponedemo/NewsCubit/NewsCubitState.dart';

class NewsListpage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewsCubit,NewsCubitState>(
      listener: (context, state) {

      },
      builder: (context, state) {
        NewsCubit newsCubit =NewsCubit.get(context);
        print(state);
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
            appBar: PreferredSize(child: CustomAppbar("الاخبار") ,preferredSize: Size.fromHeight(70),),
            body:  RefreshIndicator(
              onRefresh: () async=> await NewsCubit.get(context).getnews(),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      color: Color(0xffe6e6e6),
                      height: MediaQuery.of(context).size.height-200,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return LayoutBuilder(
                              builder: (context, constraints) => BuildNewItem(newsCubit, newsCubit.news[index],constraints)
                          );
                        },
                        itemCount: newsCubit.news.length,
                      ),
                    ),
                  ),
                  Container(height: 70,),
                ],
              ),
            ),
            floatingActionButton:(AppCubit.get(context).currentuser.usertype=="admin")? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () async{
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddnewNews(),));
              },
            ):Container()
        );
      },
    );
  }

}
