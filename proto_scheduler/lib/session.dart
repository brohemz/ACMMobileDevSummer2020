
import 'package:flutter/foundation.dart';

class SessionModel extends ChangeNotifier {
  final List<String> _times = [];
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