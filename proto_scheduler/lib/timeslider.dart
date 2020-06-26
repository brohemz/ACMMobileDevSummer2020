import 'package:flutter/material.dart';
import 'dart:math' as Math;
import './slider.dart';

class TimeSliderWidget extends StatefulWidget {
  final date;
  const TimeSliderWidget(this.date);
  @override
  _TimeSliderWidgetState createState() => _TimeSliderWidgetState(date);
}


class _TimeSliderWidgetState extends State<TimeSliderWidget> {
  var date;
  bool showSlider = false;
  var _len = 50.0;
  _TimeSliderWidgetState(this.date);
  
  List<DateTime> selectedDates = [DateTime.now()];

  // async func
  Future<Null> _selectTime(BuildContext context) async{
    // var ret = "${selectedDates.first.toLocal()}".split(' ')[1];

    setState((){
      // date = ret;
      showSlider = !showSlider;
    });
  }


  @override
  Widget build(BuildContext context){
    List<Widget> ret = new List<Widget>();


  //TODO: onTap: initialize new boxes
    

    ret += [SliderWidget(len: 75), SliderWidget(len: 40)];
    

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MaterialButton(
          onPressed: () => _selectTime(context),
          child: Text("Show Slider"),
        ),
        Text(date),
      ] + ret,
    );
  }




}