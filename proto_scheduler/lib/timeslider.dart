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


class _TimeSliderWidgetState extends State<TimeSliderWidget> with AutomaticKeepAliveClientMixin<TimeSliderWidget>{
  var date;
  bool showSlider = true;

  @override
  bool get wantKeepAlive => true;

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
        Text(date),
        MaterialButton(
          onPressed: () => _addSlider(model, 0),
          child: Text("tap"),
        ),
        MaterialButton(
          onPressed: () => print(model.lenAt(0)),
          child: Text("print"),
        ),
        SizedBox(
            width: 240,
            height: 505,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (details) {
                if(_isNotOnSlider(model, details.localPosition.dy.toDouble())){
                  _addSlider(model, details.localPosition.dy.toDouble());
                  print("GP: " + details.localPosition.dy.toString());
                }else{
                  print("ON SLIDER!");
                }
               
              },
              child: Stack(
                  children: ret
                )
            )
          )
        
      ]
      // (showSlider ? ret : []),
    );
  }

  bool _isNotOnSlider(DayModel model, double pos){
    bool ret = true;
    List<List<double>> ranges = model.getRanges();
    print(ranges);
    ranges.forEach((range){
      if(pos >= range[0] && pos <= range[1]){
        ret = false;
      }
    });
    return ret;
  }

  _addSlider(DayModel model, double position){
    model.addLen(10.0);
    model.addStartPos(position);

    setState((){
      ret += [
      Positioned(
        top: position,
        child: SliderWidget(index: model.lens.length - 1, len: model.lastLen)
      )
      ];
    });
  } 

}