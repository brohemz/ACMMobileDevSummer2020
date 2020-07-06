import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';

class ContactsView extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts")
      ),
      body: Center(
        child: Contacts()
      ),
    );
  }
}

class Contacts extends StatefulWidget{
  @override
  _ContactsState createState() => new _ContactsState();
}

class _ContactsState extends State<Contacts> {
  Permission permission;
  PermissionStatus permissionStatus;
  List<Contact> contacts;

  @override
  initState() {
    super.initState();
    setState((){
      this.permission = Permission.contacts;
      contacts = [];
    });
  }

  @override build(BuildContext context){
    return Column(
        children: [
          Text("Status: ${permissionStatus ?? "undeclared"}"),
          RaisedButton(
            onPressed: () => _requestPermission(),
            child: Text("Request Permission"),
          ),
          RaisedButton(
            onPressed: () => _getContacts(),
            child: Text("Get Contacts")
          ),
          // Text("Contacts: ${contacts.isNotEmpty ? contacts[0].givenName : "wow"}")
          SizedBox(
            height: 200,
            width: 400,
            child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: contacts.length,
            itemBuilder: (BuildContext context, int index){
              return Container(
                height: 50,
                child: Row(
                  children: [
                    Text("${contacts[index].givenName} ${contacts[index].familyName}"),
                    Spacer(),
                    Text("${contacts[index].phones.first.value}")
                  ]
                )
              );
            }
            )
          ),
          
        ],
    );
  }

  Future<Null> _requestPermission() async{
    final res = await permission.request();
    setState(() => permissionStatus = res);
    print(res.toString());
  }

  Future<Null> _getContacts() async{
    
    if(permissionStatus == PermissionStatus.granted){
      final res = await ContactsService.getContacts(withThumbnails: false);
      setState((){
        contacts = List.of(res);
        print(contacts);
      });
    }
  }

}



