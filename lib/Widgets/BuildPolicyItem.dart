import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:steponedemo/Helpers/Utilites.dart';
import 'package:steponedemo/MainCubit/AppCubit.dart';
import 'package:steponedemo/MainScreens/EditPolicy.dart';
import 'package:steponedemo/Models/Sellingpolicy.dart';
import 'package:steponedemo/SellingPolicyCubit/PolicyCubit.dart';
import 'package:steponedemo/Widgets/BuildItemContent.dart';

class BuildPolicyItem extends StatefulWidget {
  PolicyCubit policyCubit;
  Sellingpolicy sellingpolicy;
  BoxConstraints constraints;

  BuildPolicyItem(this.policyCubit, this.sellingpolicy, this.constraints);

  @override
  _BuildPolicyItemState createState() => _BuildPolicyItemState();
}

class _BuildPolicyItemState extends State<BuildPolicyItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.policyCubit.loadfile(widget.sellingpolicy.path,
            widget.sellingpolicy.extention, widget.sellingpolicy.title);
      },
      child: BuildItemContent(widget.constraints,widget.sellingpolicy,widget.policyCubit,EditPolicy(widget.sellingpolicy)),
    );
  }
}
