import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../utils/globals.dart' as globals;
import '../utils/app_exception.dart';

class LoginPage extends StatefulWidget {  
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final username = TextEditingController();
  final password = TextEditingController();
  Future<Login> _futureLogin;

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'Login',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/images/logo.png'),
      ),
    );

    final usernameInput = TextFormField(
      controller: username,
      keyboardType: TextInputType.text,
      autofocus: false,      
      decoration: InputDecoration(
        hintText: 'Username',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),      
      inputFormatters: [        
        FilteringTextInputFormatter.allow( RegExp(r'^[a-zA-Z0-9@_.]+$')) 
      ],
    );

    final passwordInput = TextFormField(
      controller: password,
      autofocus: false,      
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        shadowColor: Colors.blue.shade100,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: 200.0,
          height: 42.0,
          onPressed: () async {
            setState(() { _futureLogin = postLogin(username.text,password.text);});        
          },
          color: Colors.blue,
          child: Text(
            'Log In',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
    
    final futureBuilder = FutureBuilder<Login>(
        future: _futureLogin,
        builder: (context, snapshot)  {
        if (snapshot.hasData)  {          
        /* --- simpan token ---*/
          if(snapshot.data.status == true){
            simpanToken(snapshot.data.message);
            /* --- Navigate to the second screen using a named route --- */  
            WidgetsBinding.instance.addPostFrameCallback((_) {                    
              Navigator.pushReplacementNamed(context, '/home');
            });
          }
                       
        } else if (snapshot.hasError) {
        /* --- Jika Error ---*/          
          return Center(
              child:Text("${snapshot.error}",style: TextStyle(color: Colors.red))
          );                    
        }
        return Container(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: CircularProgressIndicator(),
          )              
        );        
        },
    );    

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
            usernameInput,
            SizedBox(height: 8.0),
            passwordInput,
            SizedBox(height: 24.0),
            loginButton,
            if(_futureLogin != null) futureBuilder
          ],
        ),
      ),
    );
  }
}
/* --- simpan token ---*/
simpanToken(String userToken) async {
    /* --- simpan User token --*/
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userToken', userToken);    
}
/* --- fungsi post data ---*/
Future<Login> postLogin(String username,String password) async {
  final response = await http.post(
    Uri.http(globals.serverIP, '/login/machine'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'username': username,
      'password': password,
    }),
  );
Map<String, dynamic> error = jsonDecode(response.body);
 switch (response.statusCode) {
    case 200:
      return Login.fromJson(jsonDecode(response.body));
    case 400:
      throw BadRequestException(error['message']);
    case 401:
      throw UnauthorisedException(error['message']);  
    case 500:
    default:
      throw FetchDataException('Error occured while Communication with Server with StatusCode : ${response.statusCode}');
  }
}

class Login {  
  final String message;  
  final bool status;

  Login({this.message,this.status});

  factory Login.fromJson(Map<String,dynamic> json) {
    return Login(      
      message: json['message'],
      status: json['status'],
    );
  }
}
