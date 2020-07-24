

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import './daymodel.dart';

class SessionModel extends ChangeNotifier {
  int _numberOfDays;
  String uid = null;
  List<DayModel> models = new List<DayModel>();
  SessionModel(this._numberOfDays, {this.uid}){
    _startSession();
  }

  DayModel _dayModelType;
  
  List<List<List<double>>> times = new List<List<List<double>>>();

  setModelType(DayModel newUserModel){
    _dayModelType = DayModel.fromDayModel(newUserModel);
  }

  List<DayModel> getDayModels(){
    return models;
  }

  List<List<List<double>>> getTimes(){
    times = [];
    models.forEach((model) {
      times.add(model.getTimes());
    });
    return times;
  }

  Future<bool> _startSession() async{
    for(int i = 0; i < _numberOfDays; i++){
      models.add(DayModel(i));
    }
    if(uid != null){
      int i = 0;
      Firestore.instance.collection("joined-sessions").document("${uid}_8437098010").get().then((doc){
        doc.data["days"].forEach((day){
          List<List<double>> ret = [];
          day['times'].forEach((curTime){
            ret.add([curTime['min'], curTime['max']]);
          });
          
          models[i].setLensFromTimes(ret);
          i += 1;
        });
      });
      return true;
    }

    var sessionData = {
      "date_range": {
        "min": "2020-07-21",
        "max": "2020-07-22",
      },
      "host_phone": "8437098010",
      "session_users": ["8437098010"],
    };

    Firestore.instance.collection("session").add(sessionData).then((doc){
      this.uid = doc.documentID;
      doc.updateData({"uid": this.uid});
      print(doc.documentID);
      return true;
    }).catchError((){ print("Error creating session"); return false;});
  }
}

