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

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {

    var appBarTitle = Text("HOME");

    final themeData = ThemeData(
      accentColor: Colors.redAccent,
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.blueAccent[300],
        shape: RoundedRectangleBorder(),
        textTheme: ButtonTextTheme.accent,
      ),
    );

    return MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: appBarTitle,
                centerTitle: true,
              ),
              body: ChangeNotifierProvider(
                create: (context) => new SessionModel(2, uid: "b1mV01FG7BvXKcReUROp"),
                child: InputSchedule(),
              ),
            ),
            theme: themeData,
          );
  }
}

class InputSchedule extends StatefulWidget{
  _InputScheduleState createState() => new _InputScheduleState();
}

class _InputScheduleState extends State<InputSchedule> with AutomaticKeepAliveClientMixin<InputSchedule>{

  @override
  bool get wantKeepAlive => true;

  int val = 0;


  initState(){
    super.initState();
  }

  _submitSession(BuildContext context){

    final sessionModel = Provider.of<SessionModel>(context, listen: false);
    final times = sessionModel.getTimes();

    DocumentReference ref = Firestore.instance.collection("joined-sessions").document("${sessionModel.uid}_8437098010");

    ref.get().then((val) => print(val.data));

    print(times);

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
    };

    ref.setData(submitObject);

    print(submitObject);
  }

  @override
  Widget build(BuildContext context){

    var sessionModel = Provider.of<SessionModel>(context);

    // sessionModel.setModelType(DayModel(2, boxWidth: 240, boxHeight: 505));

    print(sessionModel.getDayModels());
    
    var pageView = PageView(
      controller: PageController(initialPage: 0),
      scrollDirection: Axis.horizontal,
      children: [
        Page(
            'no',
            'No, you may not!',
            ChangeNotifierProvider.value(
              value: sessionModel.getDayModels()[0],
              child: Center(
                      child: TimeSliderWidget("07/02")
                    )
            )
        ),
        Page(
            'yes',
            'Yes, you may!',
            ChangeNotifierProvider.value(
              value: sessionModel.getDayModels()[1],
              child: Center(
                      child: TimeSliderWidget("07/04")
                    )
            )
        )]
      );

      var sliderView = Scaffold(
          appBar: AppBar(
            title: Text("Select Times"),
            centerTitle: true,
          ),
          body: pageView,
        );
    return Center(
            child: Column(
              children:[
                Text("\n_DATES_\n"),
                PickerWidget("06/24", "06/27"),
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
                MaterialButton(
                  onPressed: () => print(sessionModel.getTimes()),
                  child: Text("Print Times")
                ),
                MaterialButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginView()),
                  ),
                  child: Text("Show Login"),
                ),
                FlatButton(
                  onPressed: () => _submitSession(context),
                  child: Text("Submit"),
                )
              ]
            )
          );
  }
}

class Page extends StatefulWidget {
  final text;
  final info;
  final Widget notifier;
  Page(this.text, this.info, this.notifier);

  @override
  _PageState createState() => _PageState(text, info, notifier);
}

class _PageState extends State<Page> with AutomaticKeepAliveClientMixin<Page> {
  final _text;
  final _info;
  final Widget _notifier;
  _PageState(this._text, this._info, this._notifier);

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // TODO: Loses state on navigation
    
    
    return Container(
      child: Column(
        children: [Expanded(child: Column(
          children: [ Text("\n_Date_\n"),
                      Center(
                        child: _notifier
                      ),
                    ]
        ))],
    ));
  }
}

