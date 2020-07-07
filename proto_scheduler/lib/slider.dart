import 'package:flutter/material.dart';
import 'dart:math' as Math;
import 'package:provider/provider.dart';
import './daymodel.dart';

class SliderWidget extends StatefulWidget {
  final double len;
  final int index;
  final double range_high;
  SliderWidget({this.index, this.len = 20.0, this.range_high});

  @override
  _SliderWidgetState createState() => _SliderWidgetState(index, len, range_high: range_high);
  
}

class _SliderWidgetState extends State<SliderWidget>{

  double _len;
  final int _index;
  final double range_high;

  _SliderWidgetState(this._index, this._len, {this.range_high = 240});

  final double range_low = 0;

  double _clamp(double newLen){
    double ret = 0;
    if(newLen < range_low){
      ret = range_low;
    }else if(newLen > range_high){
      ret = range_high;
    }else{
      ret = newLen;
    }
    return ret;
  }

  @override
  Widget build(BuildContext context){

    var model = Provider.of<DayModel>(context);
    setState((){
      _len = model[_index];
      print(_index);
    });
    

    Widget gest = new GestureDetector(
      onVerticalDragStart: (detail) {
        _len = detail.localPosition.dy;
        model[_index] = _len;
      },
      onVerticalDragUpdate: (detail) {
        setState(() {
          _len = detail.localPosition.dy;
          model[_index] = _len;
        });
      },
      // child: SizedBox(
      //     width: 240,
      //     height: 120,
      //     child: CustomPaint(
      //       painter: Sky(_clamp(_len)),
      //     )
      //   )
      child: SizedBox(
        width: 240,
        height: _clamp(_len),
        child: CustomPaint(
          painter: Sky(_clamp(_len))
        )
      )
     
    );

    Widget ret = (Padding(
      padding: EdgeInsets.all(1),
      child: gest,
    ));

    return ret;
  }

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
    // print("length: ${_len}");
  }
  
  @override
  bool shouldRepaint(Sky oldDelegate) => oldDelegate._len != _len;
}