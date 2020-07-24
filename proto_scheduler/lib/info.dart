import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './sessionmodel.dart';

class InfoWidget extends StatefulWidget {
  final info;
  const InfoWidget(this.info);
  @override
  _InfoWidgetState createState() => _InfoWidgetState(info);
}


class _InfoWidgetState extends State<InfoWidget> {
  bool showInfo = true;
  String info = "";
  _InfoWidgetState(this.info);

  @override
  Widget build(BuildContext context){
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(showInfo ? info : ""),
        Consumer<SessionModel>(
            builder: (context, session, child) {
              return MaterialButton(
                  onPressed: (){ 
                    _toggleInfo(); 
                    session.increment(2);
                  },
                  child: Text("Count: ${session.totalNumber}"),
              );        
            },
          ),
        
      ]
    );
  }

  void _toggleInfo(){
  setState(() {
    showInfo = !showInfo;
  });
}
}