import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './session.dart';
import 'package:flutter/cupertino.dart';
import 'recent_sessions.dart';
import './login.dart';


class HomeView extends StatelessWidget{

  final AsyncSnapshot<FirebaseUser> snapshot;

  HomeView(this.snapshot);

  _joinSession(BuildContext context, AsyncSnapshot<FirebaseUser> userSnapshot, {String uid, isHost, String inviteCode}) async{

    String invite = null;
    //TODO: Move this functionality to session
    if(inviteCode != null){
      invite = await Firestore.instance.collection("invite-codes").document(inviteCode.toUpperCase()).get().then((doc){
        if(doc.exists){
          final data = doc.data;
          return data['linked_session'];
        }else{
          return null;
        }
      }).catchError((e) => print("session.dart: Invalid invite code"));

      if(invite == null){
        print("Invalid Invite Code");
        Navigator.pop(context);
        return;
      }
    }
    if(Navigator.canPop(context)){
      Navigator.pop(context);
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SessionView(userSnapshot, sessionID: invite != null ? invite : uid, isHost: isHost ?? false)));
  }

  final _inviteCodeController = TextEditingController();

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: (){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginView()),
              );
            }
          )
        ]
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Pass function for onClick event of each recent session box (_joinSession)
            Expanded(
              flex: 3,
              // child: Container(
              //   margin: EdgeInsets.only(bottom: 10),
              //   color: Colors.grey,
              //   child: Text("Placeholder", textAlign: TextAlign.center),
              // )
              child: Container(
                margin: EdgeInsets.only(bottom: 10),
                color: Colors.grey,
                child: RecentSessionsWidget(snapshot, _joinSession),
              )
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton.filled(
                padding: EdgeInsets.all(15),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Enter Invite Code"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(controller: _inviteCodeController)
                      ]
                    ),
                    actions: [
                      FlatButton(
                        onPressed:(){
                          _joinSession(context, snapshot, inviteCode: _inviteCodeController.text.trim());
                        },
                        child: Text("Done")
                      )
                    ]
                  )
                ),
                child: Text(
                    "Join",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  )
                ),
                Container(
                  height: 10
                ),
                CupertinoButton.filled(
                padding: EdgeInsets.all(15),
                onPressed: () => _joinSession(context, snapshot, isHost: true),
                child: Text(
                    "Create Session",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  )
                )
              ]
            ),
            Expanded(
              flex: 2,
              child: Container(
                margin: EdgeInsets.only(top: 10),
                color: Colors.grey,
                child: Text("Placeholder", textAlign: TextAlign.center,),
              )
            ),
           ],
        )
      ),
    );
  }
}