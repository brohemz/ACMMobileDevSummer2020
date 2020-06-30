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



    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MaterialButton(
          onPressed: () => _selectTime(context),
          child: Text("Show Slider"),
        ),
        Text(date),
        MaterialButton(
          onPressed: () => _addSlider(),
          child: Text("tap"),
        ),
      ] + (showSlider ? ret : []),
    );
  }

  _addSlider(){
    
    setState((){
      ret += [
        Consumer<DayModel>(
            builder: (context, model, child) {
              model.addLen(10);
              return SliderWidget(len: model.lastLen);
            }
        ),
      ];
    });
  } 

  _printSliderVal(int index){
    Consumer<DayModel>(
      builder: (context, model, child) {
        print(model.lenAt(index).toString());
      }
    );
  }


}