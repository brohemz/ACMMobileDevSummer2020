
import 'package:flutter/foundation.dart';

class DayModel extends ChangeNotifier{
  int _day;
  DayModel(this._day);
  
  List<String> times = new List<String>();
  int _number = 0;
  List<double> lens = new List<double>();
  List<double> startPos = new List<double>();

  int get totalTimes => _number;

  double range_low = 0;
  double range_high = 240;

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

  List<List<double>> getRanges(){
    List<List<double>> ret = [];
    for(var i = 0; i < lens.length; i++){
      ret.add([startPos[i], startPos[i] + lens[i]]);
    }
    return ret;
  }

  operator []=(int i, double val){
    lens[i] = val;
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