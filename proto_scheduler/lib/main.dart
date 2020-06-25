import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import './info.dart';
import './picker.dart';
import './slider.dart';
import './session.dart';

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

    return ChangeNotifierProvider(
          create: (context) => SessionModel(),
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: appBarTitle,
                centerTitle: true,
              ),
              body: pageView,
            ),
            theme: themeData,
          ),
        );
  }
}

class Page extends StatelessWidget {
  final text;
  final info;
  const Page(this.text, this.info);

  @override
  Widget build(BuildContext context) {

    
    return Container(
      child: Column(
        children: [Expanded(child: Column(
          children: [Text(text), InfoWidget(info), PickerWidget("06/24", "06/27"), SliderWidget("06/22")]
          )
        )],
      ),
    );
  }
}

