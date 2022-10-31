import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class LandingPage extends StatefulWidget {    
  @override
  _LandingPage createState() => _LandingPage();
}

class _LandingPage  extends State<LandingPage> {
  @override
  void initState() {
      super.initState();
      // The delay fixes it
      Future.delayed(Duration(seconds: 2)).then((_) {
         checkIfAuthenticated().then((success) {
            if (success) {
              Navigator.pushReplacementNamed(context, '/home');
            } else {
              Navigator.pushReplacementNamed(context, '/login');
            }  
          });
      });
  }

  @override 
  Widget build(BuildContext context) {      
    return Container(
        child: CircularProgressIndicator(),
        color: Colors.white,
        alignment: Alignment.center,
    );
  }
}


checkIfAuthenticated() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return bool  
  String userToken = prefs.getString('userToken');
  if(userToken == null){ 
    return false;
  }
  return true;
}