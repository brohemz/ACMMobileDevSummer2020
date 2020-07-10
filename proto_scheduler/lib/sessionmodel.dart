
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import './daymodel.dart';

class SessionModel extends ChangeNotifier {
  int _numberOfDays;
  SessionModel(this._numberOfDays);
  
  List<String> times = new List<String>();
  List<String> users = new List<String>();
  HashMap<String, List<DayModel>> models = new HashMap<String, List<DayModel>>();
  int _number = 0;

  int get numberOfUsers => _number;

  addUser(String newUser, DayModel newUserModel){
    users.add(newUser);
    models[newUser] = new List<DayModel>();
    for(int i = 0; i < 2; i++){
      models[newUser].add(DayModel.fromDayModel(newUserModel));
    }
  }

  List<DayModel> getDayModels(String user){
    return models[user];
  }


}