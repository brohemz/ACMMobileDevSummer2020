import 'package:flutter/material.dart';
import 'dart:math' as Math;

class SliderWidget extends StatefulWidget {
  final date;
  const SliderWidget(this.date);
  @override
  _SliderWidgetState createState() => _SliderWidgetState(date);
}

class Sky extends CustomPainter {

  final double _len;

  Sky(this._len) : super();
  
  @override
  void paint(Canvas canvas, Size size) {
    final radius = Math.min(size.width, size.height) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..color = Colors.blue;

    var height = _len;

    if(_len < 0){
      height = 0;
    }else if(_len > size.height.toDouble()){
      height = size.height.toDouble();
    }
    
    final rect = Rect.fromLTRB(0.0, 0.0, size.width.toDouble(), (height % (size.height.toDouble() + 1)));
    canvas.drawRect(rect, paint);
    print("length: ${_len}");
  }
  
  @override
  bool shouldRepaint(Sky oldDelegate) => oldDelegate._len != _len;
}


class _SliderWidgetState extends State<SliderWidget> {
  var date;
  bool showSlider = false;
  var _len = 50.0;
  var _len2 = 50.0;
  _SliderWidgetState(this.date);
  
  List<DateTime> selectedDates = [DateTime.now()];

  // async func
  Future<Null> _selectTime(BuildContext context) async{
    var ret = "${selectedDates.first.toLocal()}".split(' ')[1];

    setState((){
      date = ret;
      showSlider = !showSlider;
    });
  }


  @override
  Widget build(BuildContext context){
    List<Widget> ret = new List<Widget>();

    var _y = 0.0;

    Widget gest = new GestureDetector(
      onVerticalDragStart: (detail) {
        _y = detail.globalPosition.dy;
      },
      onVerticalDragUpdate: (detail) {
        setState(() {
          _y = detail.localPosition.dy;
          _len = _y;
          print(_len);
        });
      },
      child: SizedBox(
          width: 240,
          height: 120,
          child: CustomPaint(
            painter: showSlider ?  Sky(_len) : null,
          )
        )
    );

    ret.add(Padding(
      padding: EdgeInsets.all(5),
      child: gest,
    ));

  //TODO: onTap: initialize new boxes
    

    ret.add(
      SizedBox(
          width: 240,
          height: 120,
          child: CustomPaint(
            painter: showSlider ?  Sky(75.0) : null,
          )
        )
    );
    ret.add(SizedBox(
          width: 240,
          height: 120,
          child: CustomPaint(
            painter: showSlider ?  Sky(75.0) : null,
          )
        )
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(date),
        MaterialButton(
          onPressed: () => _selectTime(context),
          child: Text("Show Slider"),
        ),
      ] + ret,
    );
  }




}