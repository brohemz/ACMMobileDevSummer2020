import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import './picker.dart';
import './timeslider.dart';
import './session.dart';
import './daymodel.dart';
import './contacts.dart';

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
              body: InputSchedule(),
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

  var pageView;
  var sliderView;
  int val = 0;


  initState(){
    super.initState();

    setState((){
      pageView = PageView(
        controller: PageController(initialPage: 0),
        scrollDirection: Axis.horizontal,
        children: [
          Page(
              'no',
              'No, you may not!',
              ChangeNotifierProvider(
                create: (context) => DayModel(5, boxWidth: 240, boxHeight: 505),
                child: Center(
                        child: TimeSliderWidget("07/02")
                      )
              )
          ),
          Page(
              'yes',
              'Yes, you may!',
              ChangeNotifierProvider(
                      create: (context) => DayModel(5, boxWidth: 240, boxHeight: 505),
                      child: Center(
                        child: TimeSliderWidget("07/04")
                      )   
              )
          )]
        );

      sliderView = Scaffold(
          appBar: AppBar(
            title: Text("Select Times"),
            centerTitle: true,
          ),
          body: pageView,
        );
    });
  }

  @override
  Widget build(BuildContext context){
    return ChangeNotifierProvider(
                create: (context) => SessionModel(5),
                child: Center(
                  child: Column(
                    children:[
                      Text("\n_DATES_\n"),
                      PickerWidget("06/24", "06/27"),
                      MaterialButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => sliderView, maintainState: true),
                        ),
                        child: Text("Show Slider"),
                      ),
                      MaterialButton(
                        onPressed: () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => ContactsView()),
                        ),
                        child: Text("Contacts")
                      )
                    ]
                  )
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

