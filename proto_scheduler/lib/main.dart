import 'package:firebase_auth/firebase_auth.dart';
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
import './session.dart';
import './home.dart';
import './scrollHome.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // await Firestore.instance.settings(
  //     host: '192.168.1.10:8080',
  //     sslEnabled: false,
  //     persistenceEnabled: false
  // );
// 
  runApp(App());
}

class Authentication {
  // Source: https://www.youtube.com/watch?v=RvocbCaGzlM&t=609s @ 10:02
  static handler() {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if(snapshot.hasData) {
          return HomeView(snapshot);
          // return ScrollHomeView(snapshot);
        }else{
          return LoginView();
        }
      },
    );
  }
}

class App extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {

    final themeData = ThemeData(
      accentColor: Colors.redAccent,
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.blueAccent[300],
        shape: RoundedRectangleBorder(),
        textTheme: ButtonTextTheme.accent,
      ),
      typography: Typography.material2018(platform: TargetPlatform.iOS)
    );

    return MaterialApp(
            home: Authentication.handler(),
            theme: themeData,
          );
  }
}


