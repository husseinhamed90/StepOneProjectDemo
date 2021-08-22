import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:steponedemo/MainCubit/MainCubitStates.dart';
import 'package:steponedemo/Widgets/CustomAppBar.dart';
import '../Widgets/BuildUserItem.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';

class Userslist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: PreferredSize(
        child: CustomAppbar("قائمة المستخدمين"),
        preferredSize: Size.fromHeight(70),
      ),
      body:  BlocConsumer<AppCubit,MainCubitState>(
          listener: (context, state) {},
          builder: (context, state) {
            AppCubit appCubit =AppCubit.get(context);
            if(state is ! userupdateload){
              return RefreshIndicator(
                onRefresh: () => appCubit.getUsers(),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return BuildUserItem(appCubit.users[index], appCubit, index);
                  },
                  itemCount: appCubit.users.length,
                ),
              );
            }
            else{
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

          }
      ),
    );
  }
}
