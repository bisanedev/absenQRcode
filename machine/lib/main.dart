import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import './utils/globals.dart' as globals;
import './screens/login.dart';
import './screens/landing.dart';
import './screens/home.dart';
import './screens/qrcode.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget{
  @override
  _MyAppState createState() => new _MyAppState();  
}

class _MyAppState  extends State<MyApp> {
  String userToken;  
  Map<String, dynamic> decodedToken;
  
  @override
  void initState() {
    super.initState();
    getToken();
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
        '/home': (context) => HomePage(),              
        '/qrcode': (context) => QrCode(decodedToken:decodedToken,webSocket: IOWebSocketChannel.connect('ws://'+globals.serverIP+'/websocket/qrcode?tipe=machine&token='+userToken)),          
      },
    );
  }

  void getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();        
    setState(() { 
      userToken = prefs.getString('userToken');
      decodedToken = JwtDecoder.decode(prefs.getString('userToken')); 
    });   
  }

}