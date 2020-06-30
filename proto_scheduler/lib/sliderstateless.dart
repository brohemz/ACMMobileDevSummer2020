import 'package:flutter/material.dart';
import 'dart:math' as Math;

class SliderStatelessWidget extends StatelessWidget {
  final double len;
  SliderStatelessWidget({this.len = 20.0});

    @override
    Widget build(BuildContext context) {
      // print("len: $len");
      
      return SizedBox(
        width: 240,
        height: 120,
        child: CustomPaint(
          painter: Sky(len),
        )
      );
  }
  
}

class Sky extends CustomPainter {

  final double len;

  Sky(this.len) : super();
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blue;

    var height = len;

    if(len < 0){
      height = 0;
    }else if(len > size.height.toDouble()){
      height = size.height.toDouble();
    }
    
    final rect = Rect.fromLTRB(0.0, 0.0, size.width.toDouble(), (height % (size.height.toDouble() + 1)));
    canvas.drawRect(rect, paint);
    print("length: ${len}");
  }
  
  @override
  bool shouldRepaint(Sky oldDelegate) => oldDelegate.len != len;
}
