import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:web_socket_channel/io.dart';
import '../utils/globals.dart' as globals;
import './qrcode.dart';

class HomePage extends StatefulWidget {          
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {  
  String userToken;
  Map<String, dynamic> decodedToken;

  @override  
  void initState() {        
    super.initState(); 
    getToken();
  }  

  @override
  Widget build(BuildContext context) {        
    return Scaffold(     
      body: Center(
       child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Container(
              margin: const EdgeInsets.only(top: 10),
              child:(
                FlatButton(
                  padding: EdgeInsets.all(5.0),                
                  color: Colors.blue,
                  child: Text(
                    'Connect Ke Server',
                    style: TextStyle(fontSize: 15.0,color: Colors.white),
                  ),
                  onPressed: () async {              
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QrCode(decodedToken:decodedToken,webSocket: IOWebSocketChannel.connect('ws://'+globals.serverIP+'/websocket/qrcode?tipe=machine&token='+userToken)),
                        ),
                    );                    
                  },
                )
              )
            ),                    
            Container(
              margin: const EdgeInsets.only(top: 10),
              child:(
                FlatButton(
                  padding: EdgeInsets.all(5.0),                
                  color: Colors.blue,
                  child: Text(
                    'Logout',
                    style: TextStyle(fontSize: 15.0,color: Colors.white),
                  ),
                  onPressed: () async {
                  // hapus usertoken
                    SharedPreferences prefs = await SharedPreferences.getInstance();                
                    prefs.remove("userToken");                  
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                )
              )
            ),          
          ],
       ),
      ),     
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