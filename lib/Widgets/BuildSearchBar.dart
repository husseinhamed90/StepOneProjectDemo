import 'package:flutter/material.dart';
class BuildSearchBar extends StatefulWidget {
  @override
  _BuildSearchBarState createState() => _BuildSearchBarState();
}

class _BuildSearchBarState extends State<BuildSearchBar> {
  @override
  Widget build(BuildContext context) {
    // return Row(
    //   children: [
    //     Container(
    //       height: 55,
    //       decoration: BoxDecoration(
    //           color: Colors.white,
    //           borderRadius: BorderRadius.all(Radius.circular(10))
    //       ),
    //       width: (MediaQuery.of(context).size.width-20)*0.8,
    //       child: FocusScope(
    //         child: Focus(
    //           focusNode: myFocusNode,
    //           onFocusChange: (value) {
    //             brandsCubit.textfroemfoucesstate(value);
    //           },
    //           child: TextFormField(
    //             controller: searchbar,
    //             onChanged: (value) {
    //               if(brandsCubit.choosenclient!=null){
    //                 brandsCubit.changesuggestionresultList(searchbar.text, ClientsCubit.get(context).clients);
    //
    //               }
    //               brandsCubit.changesuggestionresultList(searchbar.text, ClientsCubit.get(context).clients);
    //             },
    //             decoration: InputDecoration(
    //                 border: InputBorder.none,
    //                 contentPadding:
    //                 EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
    //                 hintText: "ادخل اسم العميل"),
    //           ),
    //         ),
    //       ),
    //     ),
    //     Container(
    //         alignment: Alignment.centerLeft,
    //         height: 50,
    //         width: (MediaQuery.of(context).size.width-20)*0.2,
    //         child: FittedBox(
    //           child: FloatingActionButton(
    //             child: Icon(Icons.add),
    //             backgroundColor: Colors.blue,
    //             onPressed: () {
    //               Navigator.push(context, MaterialPageRoute(builder: (context) => AddnewClientPage(),));
    //             },
    //           ),
    //         )
    //     ),
    //   ],
    // );

  }
}
