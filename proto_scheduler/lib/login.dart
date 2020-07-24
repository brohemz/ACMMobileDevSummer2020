import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './main.dart';

class LoginView extends StatelessWidget{

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> _handleSignIn(String phone, BuildContext context) async{

    final _signIn = (AuthResult result){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => App()));

      print("Signing in...");
      return result.user;
    };

    _auth.verifyPhoneNumber(
      phoneNumber: phone, 
      timeout: Duration(seconds: 60), 
      verificationCompleted: (AuthCredential credential){
        _auth.signInWithCredential(credential).then(_signIn);
      }, 
      verificationFailed: (AuthException ex) => print(ex.code), 
      codeSent: (String verificationID, [int forceResendingToken]){
        final _codeController = TextEditingController();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Enter Code"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _codeController)
              ]
            ),
            actions: [
              FlatButton(
                onPressed:(){
                  var smsCode = _codeController.text.trim();
                  
                  var _credential = PhoneAuthProvider.getCredential(verificationId: verificationID, smsCode: smsCode);

                  _auth.signInWithCredential(_credential).then(_signIn);
                },
                child: Text("Done"),
              )
            ]
          )
        );
      }, 
      codeAutoRetrievalTimeout: (String verificationId){
        verificationId = verificationId;
        print(verificationId);
        print("Timeout");
      });
  }

  _loginAction(BuildContext context) async {

    Future<FirebaseUser> user = _handleSignIn("+1 843-709-8010", context);

    user.then((currentUser) => print("${currentUser != null ? currentUser.phoneNumber : "No user signed in"}"));

    // user.then((user) => print("wow: ${user.displayName}"));

    // DocumentReference ref = Firestore.instance.collection("users").document("8437098010");

    // ref.get().then((value) => print(value.data));

    // await Firestore.instance.collection("users").getDocuments().then((val) => print(val.documents.last.data));

    // Widget stream = StreamBuilder<QuerySnapshot>(
    //   stream: Firestore.instance.collection('users').snapshots(),
    //   builder: (context, snapshot) {
    //     if(!snapshot.hasData){
    //       print("ughhh");
    //     }
    //     print(snapshot.data);
    //     return Text("wow");
    //   }
    // );
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Login")
      ),
      body: Center(
        child: FlatButton(
          onPressed: () => _loginAction(context),
          child: Text("Login")
        )
      ),
    );
  }
}