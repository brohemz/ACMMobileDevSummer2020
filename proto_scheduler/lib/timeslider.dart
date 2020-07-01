import 'package:flutter/material.dart';
import 'dart:math' as Math;
import './slider.dart';
import './daymodel.dart';
import 'package:provider/provider.dart';

class TimeSliderWidget extends StatefulWidget {
  final date;
  const TimeSliderWidget(this.date);
  @override
  _TimeSliderWidgetState createState() => _TimeSliderWidgetState(date);
}


class _TimeSliderWidgetState extends State<TimeSliderWidget> {
  var date;
  bool showSlider = true;

  List<Widget> ret = List<Widget>();

  

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
    


  //TODO: onTap: initialize new boxes

    var model = Provider.of<DayModel>(context);
    if(model.lens.isNotEmpty){
      print(model.lastLen);
    }
    

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MaterialButton(
          onPressed: () => _selectTime(context),
          child: Text("Show Slider"),
        ),
        Text(date),
        MaterialButton(
          onPressed: () => _addSlider(model),
          child: Text("tap"),
        ),
        MaterialButton(
          onPressed: () => print(model.lenAt(0)),
          child: Text("print"),
        ),
      ] + (showSlider ? ret : []),
    );
  }

  _addSlider(DayModel model){
    model.addLen(10.0);

    setState((){
      ret += [
       SliderWidget(index: model.lens.length - 1, len: model.lastLen)
      ];
    });
  } 

}