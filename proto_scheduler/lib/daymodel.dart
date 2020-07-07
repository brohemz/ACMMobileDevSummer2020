
import 'package:flutter/foundation.dart';

class DayModel extends ChangeNotifier{
  final int _day;
  final double range_high;
  final double boxWidth;
  final double boxHeight;
  DayModel(this._day, {this.range_high = 240, this.boxWidth = 240, this.boxHeight = 505});
  
  List<String> times = new List<String>();
  int _number = 0;
  List<double> lens = new List<double>();
  List<double> startPos = new List<double>();

  int get totalTimes => _number;

  double range_low = 0;

  double clamp(double newLen){
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


  void increment(String time){
    _number = times.length;
    times.add(time);
    notifyListeners();
  }

  void addLen(double newLen){
    lens.add(clamp(newLen));
  }
  
  void addStartPos(double newLen){
    startPos.add(newLen);
  }

  double getStartPos(int index){
    return startPos[index];
  }

  // TODO: Add more ranges for time: currently 9 - 7
  double getRatio(){
    final double startTime = 9.00;
    final double endTime = 19.00;

    final double totalHours = endTime - startTime;
    final double totalMinutes = totalHours * 60;
    
    return boxHeight / totalMinutes;
  }

  // TODO: No Overlap on Drag
  List<List<double>> getRanges(){
    List<List<double>> ret = [];
    for(var i = 0; i < lens.length; i++){
      ret.add([startPos[i], startPos[i] + lens[i]]);
    }
    return ret;
  }

  // TODO: Use range in lieu of lens
  List<double> getTimes(){
    List<double> ret = [];
    
    final double ratioPerMinute = getRatio();
    
    lens.forEach((curLen){
      ret.add(curLen*ratioPerMinute);
    });

    return ret;
  }

  operator []=(int i, double val){
    lens[i] = clamp(val);
    notifyListeners();
  }
  operator [](int i) => lens[i];

  double lenAt(int index){
    return lens[index];
  }

  double get lastLen{
    return lens.last;
  }

}