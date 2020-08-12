import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecentSessionsWidget extends StatefulWidget{
  final AsyncSnapshot<FirebaseUser> _user;
  final Function(BuildContext context, AsyncSnapshot<FirebaseUser> userSnapshot, {String uid, bool isHost}) onClick;
  const RecentSessionsWidget(this._user, this.onClick);
  @override
  _RecentSessionsState createState() => _RecentSessionsState(_user, onClick);
}


class _RecentSessionsState extends State<RecentSessionsWidget>{
  final AsyncSnapshot<FirebaseUser> user;
  final onClick;
  _RecentSessionsState(this.user, this.onClick);
  

  // State variables
  String picked;
  List<Map<String, String>> sessions = new List<Map<String, String>>();

  // FIXME: update start/end time 
  List<String> _convertRangeMinutesToHours(List<double> range){
    final startTime = 9.00;
    final endTime = 19.00;
    
    final newStartRange = ((range[0]/60) + startTime) % 12;
    final newEndRange = ((range[1]/60) + startTime) % 12;

    var startRemainder = newStartRange.truncate() != 0 ? newStartRange % newStartRange.truncate() * 60 : newStartRange;


    var endRemainder = newEndRange.truncate() != 0 ? newEndRange % newEndRange.truncate() * 60 : newEndRange;

    final retPrefixStart = (newStartRange.truncate() == 0 ? "12" : newStartRange.truncate().toString()) + ":";
    
    final retPrefixEnd = (newEndRange.truncate() == 0 ? "12" : newEndRange.truncate().toString()) + ":";

    var retSuffixStart = startRemainder.truncate().toString();
    var retSuffixEnd = endRemainder.truncate().toString();

    retSuffixStart = retSuffixStart.padLeft(2, "0");
    retSuffixEnd = retSuffixEnd.padLeft(2, "0");

    final retStart = retPrefixStart + retSuffixStart;
    final retEnd = retPrefixEnd + retSuffixEnd;
    
    return [retStart, retEnd];
  }

  Future<Map<String, String>> _getSessionInfo(String uid) async{
    print(uid);
    return await Firestore.instance.collection("session").document("${uid}").get().then((doc){
      if(doc.exists){

        final data = doc.data;

        if(!data.containsKey("host_phone")){
          print("recent_sessions.dart: Key Not Found | host_phone");
        }

        Map<String, String> ret = new Map<String, String>();

        ret["uid"] = uid;
        ret["host_phone"] = data["host_phone"].toString();
        ret["date_range"] = data["date_range"].toString();

        //FIXME: need to verify data (led to bug with day_offset not present)
        if(data["optimal_time"] != null){
          final startDate = DateTime.parse(data["date_range"]['min']);
          final optimalDate = startDate.add(Duration(days: data["optimal_time"]["day_offset"]));

          final range = [data["optimal_time"]["range"][0] as double, data["optimal_time"]["range"][1] as double];

          final convertedTimes = _convertRangeMinutesToHours(range);

          ret["optimal_time"] = convertedTimes[0].toString() + "  < -- >  " + convertedTimes[1].toString();

          ret["optimal_date"] = optimalDate.toString().split(" ")[0];
        }

        
        return ret;
      }
    }).catchError((e){print("recent_sessions: Error $e"); return null;});
  }

  initState(){
    super.initState();
    
    Firestore.instance.collection("users").document(user.data.phoneNumber).get().then((doc){
      if(doc.exists){
        final data = doc.data;

        if(!data.containsKey("recent_sessions")){
          print("recent_sessions.dart: No Recent Sessions");
          return;
        }

        final dbSessions = data["recent_sessions"] as List<dynamic>;

        print(dbSessions);
        
        dbSessions.forEach((session){
          if(session != null){
             _getSessionInfo(session as String).then((info){
              setState((){
                sessions.add(info);
              });
          });
          }
        });

      }
    });
  }

  @override
  Widget build(BuildContext context){

    final show = sessions.isNotEmpty;
    final list = ListView(
      padding: const EdgeInsets.all(8),
      children: sessions.map((session){

        if(session == null){
          print("recent_sessions.dart: Error mapping sessions");
          return Text("Error");
        }
        
        final bool isHost = session["host_phone"] == user.data.phoneNumber;
       

        final delegate = Container(
          margin: EdgeInsets.only(bottom: 10.0),
          decoration: BoxDecoration(
            border: Border.all(width: 2.0, color: Theme.of(context).dividerColor),
            color: Colors.deepOrange[200],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              !isHost ? Text(session["uid"]) : Text(session["uid"] + " | HOST"),
              Text(session["optimal_time"] != null ? "Date ${session["optimal_date"]}" : "___"),
              Text(session["optimal_time"] != null ? session["optimal_time"] : "No Suggested Time"),
            ]
          )
        );

         return GestureDetector(
           onTap: (){
             print(session);
             onClick(context, user, uid: session["uid"], isHost: isHost);
           },
           child: ConstrainedBox(
             constraints: BoxConstraints(
               minHeight: 50,
               maxHeight: 100,
             ),
             child: DefaultTextStyle(
               style: Theme.of(context).typography.black.bodyText2,
               child: delegate
             )
           )
         );
      }).toList()
    );

    if(show){
      print(sessions);
    }

    final ret = Container(
      child: show ? list : Center(
        child: CupertinoActivityIndicator(
          animating: true,
          radius: 20.0
        )
      )
    );

    return ret;
  }
}
