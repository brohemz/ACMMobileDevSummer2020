import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import './daymodel.dart';

class SessionModel extends ChangeNotifier {
  int numberOfDays;
  DateTime startDate;
  String uid = null;
  String userPhone;
  List<DayModel> models = new List<DayModel>();
  SessionModel(this.numberOfDays, {this.userPhone = "+18437098010", this.startDate, this.uid}){
    _startSession().then((val) => notifyListeners());
  }

  DateTime get endDate => startDate != null ? startDate.add(Duration(days: numberOfDays)) : null;


  DayModel _dayModelType;
  
  List<List<List<double>>> times = new List<List<List<double>>>();
  
  setModelType(DayModel newUserModel){
    _dayModelType = DayModel.fromDayModel(newUserModel);
  }

  setStartDate(DateTime newDate){
    startDate = newDate;
    print(newDate);
    models.asMap().forEach((index, day){
      day.setDay(startDate.add(Duration(days: index)).toString().split(" ")[0]);
    });
    notifyListeners();
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

  void clearTimes({int index}){
    final _index = index;
    if(_index != null){
      times[index] = [];
      models[index] = DayModel(index);
      notifyListeners();
      return;
    }

    times = [];
    models.clear();
    for(int i = 0; i < numberOfDays; i++){
      DateTime date = startDate.add(Duration(days: i));
      String dateStr = date.toString().split(" ")[0];
      models.add(DayModel(i, day: dateStr));
    }
    notifyListeners();
  }

  Future<bool> _startSession() async{

    for(int i = 0; i < numberOfDays; i++){
      models.add(DayModel(i));
    }

    // session already created, update ui with user times
    if(uid != null){
      await Firestore.instance.collection("session").document("${uid}").get().then((doc){
        if(doc.exists){
          final data = doc.data;

          final List<int> _min =data["date_range"]["min"].toString().split("-").map((val) => (int.parse(val))).toList();
          final List<int> _max = data["date_range"]["max"].toString().split("-").map((val) => (int.parse(val))).toList();

          final start = new DateTime(_min[0], _min[1], _min[2]);
          final end = new DateTime(_max[0], _max[1], _max[2]);

          final prevNum = numberOfDays;
          
          // Set Number of Days
          numberOfDays = end.difference(start).inDays;

          for(int i = prevNum - 1; i < numberOfDays; i++){
            models.add(DayModel(i));
          }

          setStartDate(start);

          int i = 0;
          Firestore.instance.collection("joined-sessions").document("${uid}_${userPhone}").get().then((doc){
            doc.data["days"].forEach((day){
              List<List<double>> ret = [];
              day['times'].forEach((curTime){
                ret.add([curTime['min'], curTime['max']]);
              });
            
              models[i].setLensFromTimes(ret);
              i += 1;
            });
          }).catchError((error) => print(error));

        }
      });

      
      return true;
    }

    return false;

  }

  Future<String> _createSession() async{
    final _min = DateTime.now().toString().split(" ")[0];
    final _max = DateTime.now().add(Duration(days: numberOfDays)).toString().split(" ")[0];
    var sessionData = {
      "description": "Test Session",
      "date_range": {
        "min": _min,
        "max": _max,
      },
      "host_phone": "${userPhone}",
      "session_users": ["${userPhone}"],
    };

    return await Firestore.instance.collection("session").add(sessionData).then((doc){
      this.uid = doc.documentID;
      doc.updateData({"uid": this.uid});
      return doc.documentID;
    }).catchError((error){ print("Error creating session: $error"); return null;});

  }

  Future<String> initiateSession() async{
    return _createSession();
  }

  // TODO: Remove redundant calls/code
  Future<bool> submitSession() async{

    var sessionRef = Firestore.instance.collection("session").document("${uid}");
    
    Future<bool> shouldUpdateUser = await sessionRef.get().then((snapshot) async {

      var data = snapshot.data;

      if(!snapshot.exists){
        // pause until session created
        uid = await _createSession();
        print("newID: $uid");
        final newSnap = await Firestore.instance.collection("session").document("${uid}").get().then((snap) => snap);
        
        data = newSnap.data;
        sessionRef = Firestore.instance.collection("session").document("${uid}");
      }

      if(!data.containsKey("session_users")){
        final post = {"session_users": ["${userPhone}"]};
        sessionRef.setData(post, merge: true);
      }

      var dbSessionUsers = data["session_users"];

      if(!dbSessionUsers.contains("${userPhone}")){
        final post = {
          "session_users" : FieldValue.arrayUnion(["${userPhone}"])
        };
        sessionRef.updateData(post);
      }

    }).catchError((e) => print("sessionmodel.dart: Cannot retrieve session during submission"));

    final times = getTimes();

    // add times for User
    DocumentReference ref = Firestore.instance.collection("joined-sessions").document("${uid}_${userPhone}");

    ref.get().then((val) => print(val.data));

    var dayArr = [];
    times.forEach((day){
      var dayObject = {"times": []};
      day.forEach((curRange){
        dayObject["times"].add({
            "min": curRange.first,
            "max": curRange.last
          });
      });
      dayArr.add(dayObject);
    });

    var submitObject = {
      "days": dayArr,
      "session_id": uid,
      "phone_number": userPhone
    };

    ref.setData(submitObject);

    print("Submitted");


    // add this session user's recent_sessions
    DocumentReference userRef = Firestore.instance.collection("users").document("${userPhone}");

    userRef.get().then((snapshot) async{
      if(!snapshot.exists){
        return false;
      }

      final data = snapshot.data;

      if(!data.containsKey("recent_sessions")){
        final post = {"recent_sessions" : ["${uid}"]};
        userRef.setData(post, merge: true);
        return true;
      }

      var dbSessions = data["recent_sessions"] as List<dynamic>;

      await shouldUpdateUser;
      
      // Updates inline if current uid is not in db array
      if(!dbSessions.contains("${uid}")){
        final post = {
          "recent_sessions" : FieldValue.arrayUnion(["${uid}"])
        };
        userRef.updateData(post);
      }
    });

    return true;
  }
}

