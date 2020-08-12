import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './picker.dart';
import './timeslider.dart';
import './sessionmodel.dart';
import './daymodel.dart';
import './contacts.dart';
import './login.dart';
import './home.dart';
import 'dart:math';
import 'dart:convert';

class SessionView extends StatelessWidget{

  final AsyncSnapshot<FirebaseUser> snapshot;
  final String sessionID;
  final bool isHost;

  SessionView(this.snapshot, {this.sessionID, this.isHost = false});

  @override
  Widget build(BuildContext context){
    if(isHost){
      print("HOSTING");
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("User: ${snapshot.data.phoneNumber}"),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeView(snapshot)));
            }
          )
      ),
      body: ChangeNotifierProvider(
        create: (context) => new SessionModel(2, userPhone: snapshot.data.phoneNumber, uid: sessionID),
        child: InputSchedule(snapshot, isHost),
      ),
    );
  }
  
}


class InputSchedule extends StatefulWidget{
  final bool isHost;
  final AsyncSnapshot<FirebaseUser> snapshot;
  InputSchedule(this.snapshot, this.isHost);

  _InputScheduleState createState() => new _InputScheduleState();
}

class _InputScheduleState extends State<InputSchedule> with AutomaticKeepAliveClientMixin<InputSchedule>{

  @override
  bool get wantKeepAlive => true;

  int val = 0;
  bool didCreateNewInviteCode = false;
  String inviteCode = null;


  initState(){
    super.initState();
    setState((){
      didCreateNewInviteCode = false;
      inviteCode = null;
    });
  }

  Future<String> _inviteToSession(SessionModel model) async{

    final Future<dynamic> ret = Firestore.instance.collection("session").document(model.uid).get().then((doc){
      if(doc.exists){
        final data = doc.data;
        if(data.containsKey("invite_code")){
          final inviteCode = data['invite_code']['code'];
          return inviteCode;
        }else{
          return "...";
        }
      }else{
        return "...";
      }
    }).catchError((e) => print("session.dart: Cannot Retrieve Invite Code"));

    return await ret;
  }

  // Reference https://stackoverflow.com/questions/61919395/how-to-generate-random-string-in-dart
  Future<String> _newInviteCode(SessionModel model) async{

    if(model.uid == null){
      if(await model.initiateSession() == null){
        return null;
      }
    }
    // random 6-character string
    const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';

    Random _rand = Random.secure();

    List<int> positions = List<int>.generate(6, (iter) => _rand.nextInt(_chars.length));

    String code = positions.map((index) => _chars[index].toString()).join("");

    String now = DateTime.now().toString().split(" ")[0];

    // may overwrite code, but worth the risk
    await Firestore.instance.collection("invite-codes").document(code).setData({
      "date_created": now,
      "linked_session": model.uid
    });

    await Firestore.instance.collection("session").document(model.uid).updateData({
      "invite_code": {
        "code": code,
        "date_created": now
      }
    });
    
    return code;
  }


  @override
  Widget build(BuildContext context){

    var sessionModel = Provider.of<SessionModel>(context);

    // sessionModel.setModelType(DayModel(2, boxWidth: 240, boxHeight: 505));

    final List<DayModel> dayModels = sessionModel.getDayModels();

    print(dayModels);


    // TODO: # of pages not updating after date-range change
    List<Widget> pages = [];

    if(!widget.isHost){
      final Widget _actionRow = new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MaterialButton(
            onPressed: () => print(sessionModel.getTimes()),
            child: Text("Print Times")
          ),
          Text(" | "),
          MaterialButton(
            onPressed: (){
              pages.clear();
              sessionModel.clearTimes();
              setState(() => true);
            },
            child: Text("Clear Times")
          )
        ]
      );

      final Widget _submit = new MaterialButton(
        onPressed: () => sessionModel.submitSession(),
        child: Text("Submit")
      );
      

      pages.add(Container(
        child: Column(
            children: [Container(height: 25), Text("${sessionModel.uid}"), _actionRow, _submit]
          )
        )
      );
    }

    var _pageController = PageController(initialPage: 0);
     
    dayModels.asMap().forEach((index, model){
      final newPage = new Page(
        ChangeNotifierProvider.value(
          value: dayModels[index],
          child: Center(
            child: TimeSliderWidget(dayModels[index].day),
          )
        ),
        sendToFront: (){
          _pageController.animateToPage(0, duration: Duration(milliseconds: 850), curve: Curves.decelerate);
        },
      );
      pages.add(newPage);
    });
    
    var pageView = PageView(
      controller: _pageController,
      scrollDirection: Axis.horizontal,
      children: pages ?? []
      );

    var sliderView = Scaffold(
        appBar: AppBar(
          title: Text("Select Times"),
          centerTitle: true,
        ),
        body: pageView,
      );


    // TODO: Clean up code / working end range
    
    DateTime start = sessionModel.startDate;
    // print(start);
    DateTime end = sessionModel.endDate;
    // print(end);

    List<Widget> hostWidgets = [
                Text("\n_DATES_\n"),
                PickerWidget(callback: (DateTime start, DateTime end){
                  sessionModel.numberOfDays = end.difference(start).inDays + 1;
                  sessionModel.setStartDate(start);
                  sessionModel.clearTimes();
                  print(sessionModel.numberOfDays);
                  setState(() => true);
                }, selectedDates: start != null? [start, end]: null),
                MaterialButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => sliderView),
                  ),
                  child: Text("Show Slider"),
                ),
                MaterialButton(
                  onPressed: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => ContactsView()),
                  ),
                  child: Text("Contacts")
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                      onPressed: () => print(sessionModel.getTimes()),
                      child: Text("Print Times")
                    ),
                    Text(" | "),
                    MaterialButton(
                      onPressed: (){
                        sessionModel.clearTimes();
                        print("Times Cleared");
                      },
                      child: Text("Clear Times"),
                    )
                  ]
                ),
                FlatButton(
                  onPressed: () => sessionModel.submitSession(),
                  child: Text("Submit"),
                ),
                Spacer(),
                DefaultTextStyle(
                  style: Theme.of(context).typography.englishLike.headline4.apply(color: Colors.black),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05)
                      ),
                      Text("Invite Code: "),
                      FutureBuilder(
                        future: _inviteToSession(sessionModel),
                        builder: (context, snapshot){
                          if(snapshot.hasData){
                            if(snapshot.data == "..."){
                              if(inviteCode == null && didCreateNewInviteCode){
                                return Center(
                                  child: CupertinoActivityIndicator()
                                );
                              }
                              return Center(
                                child: inviteCode == null ? IconButton(
                                    onPressed: (){
                                      setState((){
                                        didCreateNewInviteCode = true;
                                        _newInviteCode(sessionModel).then((code){
                                          setState((){
                                            inviteCode = code;
                                            didCreateNewInviteCode = false;
                                          });
                                        });
                                      });
                                    },
                                    icon: Icon(Icons.refresh, color: Colors.grey, size: 35)
                                ) : Text(inviteCode),
                                
                              );
                            }
                            return Center(child: 
                              Text("${snapshot.data}", softWrap: true)
                            );
                          }else if(snapshot.hasError){
                            return Text("${snapshot.error}");
                          }
                          // displays by default
                          return CupertinoActivityIndicator();
                        }
                      ),
                    ]
                  )
                )
            
                
              ];

    Widget hostView = Center(
      child: Column(
        children: hostWidgets,
      )
    );
    
    return SafeArea(
      minimum: EdgeInsets.all(10.0),
      child: widget.isHost ? hostView : Container(child: pageView)
    );
  }
}

class Page extends StatefulWidget {

  final Widget notifier;
  final Function sendToFront;
  Page(this.notifier, {this.sendToFront});

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> with AutomaticKeepAliveClientMixin<Page> {

  _PageState();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) { 
    return Container(
      child: Column(
        children: [Expanded(child: Column(
          children: [ Text("\n_Date_\n"),
                      Center(
                        child: Container(child: widget.notifier),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                            Container(
                              margin: EdgeInsets.only(left: 20),
                              child: CupertinoButton.filled(
                              padding: EdgeInsets.all(8),
                              onPressed: () => widget.sendToFront != null ? widget.sendToFront() : () => {},
                              child: Text("<--")
                            )
                          ),
                        ]
                      )
                    ]
        )),
        ],
    ));
  }
}
