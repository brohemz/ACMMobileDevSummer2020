import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './main.dart';

class LoginView extends StatelessWidget{

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> _handleSignIn(String phone, BuildContext context) async{

    final _signIn = (AuthResult result){
      final userDoc = Firestore.instance.collection("users").document(phone);
      
      userDoc.get().then((DocumentSnapshot doc){
        if(!doc.exists){
          userDoc.setData({ 'email': null, 'verified': true, 'recent_sessions': []});
        }
      });
      
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => App()));

      print("Signing in...");
      return result.user;
    };

    final _verificationCompleted = (AuthCredential credential){
      _auth.signInWithCredential(credential).then(_signIn);
    };

    final _verificationFailed = (AuthException ex) => print(ex.code);

    final _codeSent = (String verificationID, [int forceResendingToken]){
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
                Navigator.pop(context);
                var smsCode = _codeController.text.trim();
                
                var _credential = PhoneAuthProvider.getCredential(verificationId: verificationID, smsCode: smsCode);

                _auth.signInWithCredential(_credential).then(_signIn);
              },
              child: Text("Done"),
            )
          ]
        )
      );
    };

    final _codeAutoRetrievalTimeout = (String verificationID){
        print(verificationID);
        print("Timeout");
    };

    _auth.verifyPhoneNumber(
      phoneNumber: phone, 
      timeout: Duration(seconds: 60), 
      verificationCompleted: _verificationCompleted, 
      verificationFailed: _verificationFailed, 
      codeSent: _codeSent, 
      codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout
    );

  }

  _loginAction(BuildContext context) async {

    final _phoneController = TextEditingController();

    final retVal = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Choose Phone"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton.filled(
              padding: EdgeInsets.all(15),
              
              child: Text("User 1"),
              onPressed: () => _phoneController.text = "+18437098010",
            ),
            Container(
              height: 50
            ),
            CupertinoButton.filled(
              padding: EdgeInsets.all(15),
              child: Text("User 2"),
              onPressed: () => _phoneController.text = "+18437095882"
            ),
          ]
        ),
        actions: [
          FlatButton(
            child: Text("Continue"),
            onPressed: (){
              Navigator.pop(context, _phoneController.text);
            }
          )
        ]
      ),
    );

    Future<FirebaseUser> user = _handleSignIn(retVal, context);

    user.then((currentUser) => print("${currentUser != null ? currentUser.phoneNumber : "No user signed in"}"));

    // user.then((user) => print("wow: ${user.displayName}"));

    // DocumentReference ref = Firestore.instance.collection("users").document("+18437098010");

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