import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class QrCode extends StatefulWidget {        
  final WebSocketChannel webSocket;  
  final Map<String, dynamic> decodedToken;

  QrCode({Key key, @required this.decodedToken, @required this.webSocket})
  : super(key: key);

  @override
  _QrCode createState() => _QrCode();
}

class _QrCode extends State<QrCode> {        
  String gambarSimpan;
  bool wsConnect = false;

  @override  
  void initState() { 
    _connected();
    _getLastSecret();
    super.initState();      
  }  

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {         
    return Scaffold(     
      body: Center(
       child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
          wsConnect ? Padding(
            padding: EdgeInsets.all(10),                                                    
            child: qrCode(gambarSimpan),                    
          ) : Column(
            children: [
              Text(
                "Koneksi Tak Tersedia , Silahkan Reconnect",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.0,color: Colors.black , fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              )  
            ],
          ),                          
          Container(
            margin: const EdgeInsets.only(top: 10),
            child:(
              FlatButton(
                padding: EdgeInsets.all(5.0),                
                color: wsConnect ? Colors.red : Colors.green,
                child: Text(
                  wsConnect ? "Disconnect":"Reconnect",
                  style: TextStyle(fontSize: 15.0,color: Colors.white),
                ),
                onPressed: () async {                            
                  Navigator.pushReplacementNamed(context, '/home');
                },
              )
            )
          ),          
          ],
       ),
      ),     
    );
  }

  void _getLastSecret() async {    
    var message = {};
    message["from"] = widget.decodedToken['username'];
    message["to"] = "server";
    message["data"] = "get";
    String send = json.encode(message);
    widget.webSocket.sink.add(send);          
  }

  void _connected(){
    widget.webSocket.stream.listen((onData){ 
      setState(() { wsConnect = true;});        
      final gambar = jsonDecode(onData);
      if (gambar['from'] == "server" && gambar['to'] == widget.decodedToken['username']){ 
        setState(() {
          gambarSimpan = gambar['data'];
        });
      }
    },
    onDone: _disconnect,
    onError: (dynamic error) => print(error),
    );  
  }

  void _disconnect(){
    print("done => disconnect");    
    setState(() { wsConnect = false;});
  }

  @override
  void dispose() {
    widget.webSocket.sink.close();  
    print("pindah halaman => disconnect");
    super.dispose();
  }
  
}

Widget qrCode (String thumbnail) {
  String placeholder = "iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==";
  if (thumbnail?.isEmpty ?? true)
      thumbnail = placeholder;
  else {
            switch (thumbnail.length % 4) {
              case 1:  break; // this case can't be handled well, because 3 padding chars is illeagal.
              case 2:  thumbnail = thumbnail + "=="; break;
              case 3:  thumbnail = thumbnail + "="; break;
            }
  }
  final _byteImage = Base64Decoder().convert(thumbnail);
  Widget image = Image.memory(_byteImage);
  return image;
}