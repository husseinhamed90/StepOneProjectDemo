import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
class CircularProgressParForUpload extends StatefulWidget {
  double percentage;
  CircularProgressParForUpload(this.percentage);
  @override
  _CircularProgressParForUploadState createState() => _CircularProgressParForUploadState();
}

class _CircularProgressParForUploadState extends State<CircularProgressParForUpload> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
          child: Center(
            child: CircularPercentIndicator(
              radius: 60.0,
              lineWidth: 4.0,
              percent: widget.percentage,
              center: new Text("${(widget.percentage *100)}".split(".")[0]+"%"),
              progressColor: Colors.blue,
            ),
          )
      ),
    );
  }
}
