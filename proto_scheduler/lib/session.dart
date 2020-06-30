
import 'package:flutter/foundation.dart';

class SessionModel extends ChangeNotifier {
  int _numberOfDays;
  SessionModel(this._numberOfDays);
  
  List<String> times = new List<String>();
  int _number = 0;

  int get totalNumber => _number;


  void increment(int iter){
    _number += iter;
    notifyListeners();
  }

  void decrement(int iter){
    _number -= iter;
    notifyListeners();
  }
}