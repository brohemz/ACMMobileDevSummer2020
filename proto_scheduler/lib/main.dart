import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import './info.dart';
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
    final controller = PageController(
      initialPage: 0,
    );

    final pageView = PageView(
      controller: controller,
      scrollDirection: Axis.horizontal,
      children: [
        Page(
            'no',
            'No, you may not!',
            ChangeNotifierProvider(
              create: (context) => DayModel(5),
              child: TimeSliderWidget("06/22"))
            ),
        Page(
            'yes',
            'Yes, you may!',
            ChangeNotifierProvider(
              create: (context) => DayModel(5),
              child: TimeSliderWidget("06/24"))
            ),
      ]
    );

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
                create: (context) => SessionModel(5),
                child: pageView
              ),
            ),
            theme: themeData,
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
    // TODO: Rebuilds on page flick, needs to keep state
    
    
    return Container(
      child: Column(
        children: [Expanded(child: Column(
          children: [MaterialButton(
                      onPressed: () => Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => ContactsView()),
                      ),
                      child: Text("Contacts")
                    ),Text(_text), InfoWidget(_info), PickerWidget("06/24", "06/27"), _notifier],
        ))],
    ));
  }
}

