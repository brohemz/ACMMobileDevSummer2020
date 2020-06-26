import 'package:flutter/material.dart';
import 'dart:math' as Math;

class SliderWidget extends StatefulWidget {
  double len;
  SliderWidget({this.len = 20});

  @override
  _SliderWidgetState createState() => _SliderWidgetState(len);
}

class Sky extends CustomPainter {

  final double _len;

  Sky(this._len) : super();
  
  @override
  void paint(Canvas canvas, Size size) {
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

  double _len;

  _SliderWidgetState(this._len);

  @override
  Widget build(BuildContext context){

    Widget gest = new GestureDetector(
      onVerticalDragStart: (detail) {
        _len = detail.localPosition.dy;
      },
      onVerticalDragUpdate: (detail) {
        setState(() {
          _len = detail.localPosition.dy;
          print(_len);
        });
      },
      child: SizedBox(
          width: 240,
          height: 120,
          child: CustomPaint(
            painter: Sky(_len),
          )
        )
    );

    Widget ret = (Padding(
      padding: EdgeInsets.all(5),
      child: gest,
    ));

    return ret;
  }
}