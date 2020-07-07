import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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

  double boxWidth;
  double boxHeight;

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
    boxWidth = model.boxWidth;
    boxHeight = model.boxHeight;

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
          onPressed: () => print(model.getTimes()),
          child: Text("print"),
        ),
        SizedBox(
            width: boxWidth,
            height: boxHeight,
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
                  children: [
                    SizedBox(
                      width: boxWidth,
                      height: boxHeight,
                      child: CustomPaint(
                        painter: TimeSliderPainter(model.getRatio(), 10)
                      ) 
                    ) as Widget,
                  ] + ret
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
          child: SliderWidget(index: model.lens.length - 1, len: model.lastLen, range_high: boxHeight-position)
        )
      ];
    });
  } 

}

class TimeSliderPainter extends CustomPainter {
  final double _ratio;
  final double _hours;

  TimeSliderPainter(this._ratio, this._hours);

  @override
  void paint(Canvas canvas, Size size){
    final paintGrey = Paint()..color = Colors.grey;
    final paintBlack = Paint()..color = Colors.black;
    final double boxWidth = size.width.toDouble();
    final double boxHeight = size.height.toDouble();

    final rect = Rect.fromLTRB(0.0, 0.0, boxWidth, boxHeight);
    canvas.drawRect(rect, paintGrey);

    final double halfHourSample = (_ratio * 30);

    for(int i = 0; i < _hours * 2; i++){
      Offset p1 = Offset(0, i * halfHourSample);
      Offset p2 = Offset(40, i * halfHourSample);

      if(i % 2 == 0){
        p2 = Offset(80, i * halfHourSample);
      }

      canvas.drawLine(p1, p2, paintBlack);
    }
  }

  @override
  bool shouldRepaint(TimeSliderPainter oldDelegate) => oldDelegate._ratio != _ratio;
}