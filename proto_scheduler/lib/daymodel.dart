
import 'package:flutter/foundation.dart';

class DayModel extends ChangeNotifier{
  final int id;
  final double range_high;
  final double boxWidth;
  final double boxHeight;
  String day;

  DayModel(this.id, {this.day, this.range_high = 240, this.boxWidth = 240, this.boxHeight = 505});

  static DayModel fromDayModel(DayModel oldModel){
    return new DayModel(oldModel.id, range_high: oldModel.range_high, boxWidth: oldModel.boxWidth, boxHeight: oldModel.boxHeight);
  }
  
  List<List<double>> times = new List<List<double>>();
  int _number = 0;
  List<double> lens = new List<double>();
  List<double> startPos = new List<double>();

  int get totalTimes => _number;

  static const double range_low = 0;

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

  void setDay(String adjustedDate){
    day = adjustedDate;
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

  void setLensFromTimes(List<List<double>> times){
    times.forEach((range){
      final len = (range.last - range.first) * getRatio();
      final start = range.first * getRatio();

      lens.add(len);
      startPos.add(start);
    });
    notifyListeners();
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

  // TODO: Return DateTime instead - currently in minutes
  // Returns sorted time-ranges for each slider
  List<List<double>> getTimes(){
    List<List<double>> ret = [];

    final double startTime = 9.00;
    
    final double ratioPerMinute = 1 / getRatio();

    List<List<double>> ranges = getRanges();

    ranges.forEach((curRange){
      final double curLen = curRange[1] - curRange[0];

      final double time = curLen * ratioPerMinute;
      final double timeOffset = (curRange[0] * ratioPerMinute);

      double adjustedTime = startTime + timeOffset + time;

      ret.add([startTime + timeOffset, adjustedTime]);
      ret.sort((a, b) => a[0].compareTo(b[0]));
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