import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import './info.dart';
import './picker.dart';
import './timeslider.dart';
import './session.dart';
import './daymodel.dart';

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
            'No, you may not!'
          ),
        Page(
            'yes',
            'Yes, you may!'
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

class Page extends StatelessWidget {
  final text;
  final info;
  const Page(this.text, this.info);

  @override
  Widget build(BuildContext context) {
    // TODO: Rebuilds on page flick, needs to keep state
    Widget ret1 = ChangeNotifierProvider(
            create: (context) => DayModel(5),
            child: TimeSliderWidget("06/22"));

    Widget ret2 =  ChangeNotifierProvider(
            create: (context) => DayModel(5),
            child: TimeSliderWidget("06/24")); 
    
    return Container(
      child: Column(
        children: [Expanded(child: Column(
          children: [Text(text), InfoWidget(info), PickerWidget("06/24", "06/27")] + (text == "yes" ? [ret1] : [ret2])),
        )],
    ));
  }
}

