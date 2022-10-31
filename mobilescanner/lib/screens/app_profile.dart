import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Profile extends StatefulWidget {

  const Profile({Key key}) : super(key: key);  
  @override
  _Profile createState() => _Profile();
}

class _Profile extends State<Profile> {  

  @override  
  void initState() {        
    super.initState();     
  }  

  @override
  Widget build(BuildContext context) {
    return Center(
            child:FlatButton(
              padding: EdgeInsets.all(10.0),                
              color: Colors.red,
              child: Text(
                'Logout',
                style: TextStyle(fontSize: 15.0,color: Colors.white),
              ),
              onPressed: () async {
                //logout                
                SharedPreferences prefs = await SharedPreferences.getInstance();                
                prefs.remove("userToken");
                // navigator menuju ke halaman login
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          );
  }
  
}