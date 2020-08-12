import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './session.dart';
import 'package:flutter/cupertino.dart';
import 'recent_sessions.dart';
import './login.dart';


// Description: an example scrolling home screen. May implement later

class ScrollHomeView extends StatelessWidget{

  final AsyncSnapshot<FirebaseUser> snapshot;

  ScrollHomeView(this.snapshot);

  List<String> itemEx = ["Ryan", "Ashley", "Gary", "Kevin", "Karen"];
  List<String> items = new List<String>();


  _joinSession(BuildContext context, AsyncSnapshot<FirebaseUser> userSnapshot, {String uid, isHost}){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SessionView(userSnapshot, sessionID: uid, isHost: isHost ?? false))
    );
  }

  Widget _buildSliverListItem(BuildContext context, int i){
    return Container(
      height: 75,
      decoration: BoxDecoration(
        border: Border.all(width: 2.0, color: Theme.of(context).dividerColor),
        color: Colors.amber[100 * ((i % 5) + 1)],
        borderRadius: BorderRadius.all(Radius.circular(1.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          DefaultTextStyle(
              style: Theme.of(context).typography.black.bodyText1,
              child: Text("Hello: ${items[i]}"),
            )
        ]
      )
    );
  }


  @override
  Widget build(BuildContext context){
    for(int i = 0; i < 5; i++){
      items.addAll(itemEx);
    }
    return CustomScrollView(
      slivers: <Widget> [
        SliverAppBar(
          pinned: true,
          expandedHeight: 250.0,
          flexibleSpace: FlexibleSpaceBar(
            title: DefaultTextStyle(
              style: Theme.of(context).typography.black.bodyText1,
              child: Text("Hey there"),
            )
          )
        ),
        SliverFixedExtentList(
          itemExtent: 75.0,
          delegate: SliverChildBuilderDelegate((context, i) => _buildSliverListItem(context, i), childCount: 25)
        ),
      ]


    );
  }
}