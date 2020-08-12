import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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


class _TimeSliderWidgetState extends State<TimeSliderWidget>{
  var date;
  bool showSlider = true;
  bool didAppear = false;

  double boxWidth;
  double boxHeight;

  bool listenToDrag = false;

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

  initState(){
    super.initState();

    setState(() => didAppear = false);
  }

  @override
  Widget build(BuildContext context){
    


  //TODO: onTap: initialize new boxes

    var model = Provider.of<DayModel>(context);
    boxWidth = model.boxWidth;
    boxHeight = model.boxHeight;
    model.setDay(date);

    // if(model.lens.isNotEmpty){
    //   print(model.lastLen);
    // }

    //DONE: for loop for access to index values on sliderwidget
    // Initialize on reappearance
    if(!didAppear && model.lens.isNotEmpty){
      var ranges = model.getRanges();
      for(int i = 0; i < ranges.length; i++){
        setState((){
          ret += [
            Positioned(
              top: ranges[i][0],
              child: SliderWidget(index: i, len: model[i], range_high: boxHeight-ranges[i][0])
            )
          ];
        });
      }
    }
    // if(!didAppear){
    //   if(model.lens.isNotEmpty){
    //     var ranges = model.getRanges();
    //     model.getRanges().forEach((range){
    //       setState((){
    //           ret += [Positioned(
    //           top: range[0],
    //           child: SliderWidget(index: model.lens.length - 1, len: model.lastLen, range_high: boxHeight-range[0])
    //           )];
    //       });
    //     });
    //   }
    // }
    

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(date),
        MaterialButton(
          onPressed: () => print(model.getTimes()),
          child: Text("print"),
        ),
        SizedBox(
            width: boxWidth,
            height: boxHeight,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragDown: (details) {
                if(_isNotOnSlider(model, details.localPosition.dy.toDouble())){
                  _addSlider(model, details.localPosition.dy.toDouble());
                  print("GP: " + details.localPosition.dy.toString());
                  setState(() => listenToDrag = true);
                }else{
                  print("ON SLIDER!");
                  setState(() => listenToDrag = false);
                }
              },
              // Edge case: drag slider on instantiation
              onVerticalDragUpdate: (detail){
                if(listenToDrag){
                  model[model.lens.length - 1] = detail.localPosition.dy.toDouble() - model.startPos[model.lens.length - 1];
                }
              },
              onTapUp: (details){
                setState(() => listenToDrag = false);
              },
              // onVerticalDragUpdate: (detail) {
              //   model[model.lens.length - 1] = detail.localPosition.dy.toDouble();
              // },
              child: Stack(
                  children: [
                    SizedBox(
                      width: boxWidth,
                      height: boxHeight,
                      child: CustomPaint(
                        painter: TimeSliderPainter(model.getRatio(), 9, 19)
                      ) 
                    ) as Widget,
                  ] + ret + [IgnorePointer(child: SizedBox(
                    width: boxWidth,
                    height: boxHeight,
                    child: CustomPaint(
                      painter: TimeSliderPainter(model.getRatio(), 9, 19, overlay: true),
                    )
                  ))]
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
  final double _startTime;
  final double _endTime;
  final bool overlay;


  TimeSliderPainter(this._ratio, this._startTime, this._endTime, {this.overlay = false});

  @override
  void paint(Canvas canvas, Size size){
    final paintGrey = Paint()..color = Colors.grey;
    var paintLine = Paint();
    paintLine.color = Colors.black;
    paintLine.strokeWidth = 2;
    final double boxWidth = size.width.toDouble();
    final double boxHeight = size.height.toDouble();

    if(!overlay){
      final rect = Rect.fromLTRB(0.0, 0.0, boxWidth, boxHeight);
      canvas.drawRect(rect, paintGrey);
    }else{
      final double halfHourSample = (_ratio * 30);

      int hour = _startTime.toInt();

      for(int i = 0; i <= (_endTime - _startTime) * 2; i++){
        Offset p1 = Offset(0, i * halfHourSample);
        Offset p2 = Offset(40, i * halfHourSample);

        if(i % 2 == 0){
          p2 = Offset(80, i * halfHourSample);
          if(i != 0 && i != (_endTime - _startTime) * 2){
            hour++;
          }
        }else{
          var paraBuilder = ParagraphBuilder(ParagraphStyle(textAlign: TextAlign.center, fontSize: 15));

          int hour12 = hour % 12;
          if(hour12 == 0){
            hour12 = 12;
          }
          paraBuilder.addText(hour12.toString() + ":00");
          var build = paraBuilder.build();
          build.layout(ParagraphConstraints(width: 50));

          canvas.drawParagraph(build, Offset(boxWidth / 2 - 25, i * halfHourSample - (halfHourSample / 2 - 5)));
        }

        if(i == 0){
          p1 = Offset(0, 1);
          p2 = Offset(80, 1);
        }else if(i == (_endTime - _startTime) * 2){
          p1 = Offset(0, boxHeight - 1);
          p2 = Offset(80, boxHeight - 1);
        }
        canvas.drawLine(p1, p2, paintLine);
      }
    }
  }

  @override
  bool shouldRepaint(TimeSliderPainter oldDelegate) => oldDelegate._ratio != _ratio;
}