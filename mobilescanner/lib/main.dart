import 'package:flutter/material.dart';
import './screens/login.dart';
import './screens/landing.dart';
import './screens/app.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget{
  @override
  _MyAppState createState() => new _MyAppState();  
}

class _MyAppState  extends State<MyApp> {  
  
  @override
  void initState() {
    super.initState();    
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Machine QRCode',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(      
        primarySwatch: Colors.blue,        
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',                
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LandingPage(),
        '/login': (context) => LoginPage(),        
        '/apps': (context) => Apps(),        
      },
    );
  }

}