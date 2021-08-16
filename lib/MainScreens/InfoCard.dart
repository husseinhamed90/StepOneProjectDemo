import 'package:flutter/material.dart';
class InfoCart extends StatefulWidget {
  @override
  _InfoCartState createState() => _InfoCartState();
}

class _InfoCartState extends State<InfoCart> with WidgetsBindingObserver{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          children: [
            Container(
              margin: EdgeInsets.only(top: 100),
              child: Image.asset("assets/info.jpeg"),
            ),
            SizedBox(height: 200,),
            InkWell(
              child: Container(
                child: Image.asset("assets/back.jpeg",height: 120,),
              ),
              onTap: () => Navigator.pop(context),
            ),

          ],
        ),
      ),
    );
  }
}
