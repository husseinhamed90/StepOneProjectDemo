import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
class CircularProgressBarIndicatorDorDownload extends StatefulWidget {
  int percentage;
  CircularProgressBarIndicatorDorDownload(this.percentage);
  @override
  _CircularProgressBarIndicatorDorDownloadState createState() => _CircularProgressBarIndicatorDorDownloadState();
}

class _CircularProgressBarIndicatorDorDownloadState extends State<CircularProgressBarIndicatorDorDownload> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: Center(
            child: CircularPercentIndicator(
              radius: 60.0,
              lineWidth: 4.0,
              percent: widget.percentage/100,
              center: new Text("${widget.percentage}%"),
              progressColor: Colors.blue,
            ),
          )
      ),
    );
  }
}
