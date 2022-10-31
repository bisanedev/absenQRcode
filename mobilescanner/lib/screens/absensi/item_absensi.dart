import './model_absensi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/globals.dart' as globals;
import '../../utils/app_exception.dart';

class AbsenListItem extends StatefulWidget {  

  final PagingController<int, AbsenList> pagging;
  
  const AbsenListItem({
    @required this.data,
    @required this.pagging,
    Key key,
  })  : assert(data != null),
        super(key: key);

  final AbsenList data;

  @override
  _AbsenListItem createState() => _AbsenListItem();
}

class _AbsenListItem extends State<AbsenListItem> {

  

  @override
  Widget build(BuildContext context) {  
  DateTime tanggal = new DateFormat("yyyy-MM-dd").parse(widget.data.masuk); 
  DateTime masuk = new DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(widget.data.masuk);    
  DateTime pulang = new DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(widget.data.pulang);  
  return Container(
  margin: EdgeInsets.only(left: 10, top: 25, right: 10, bottom: 0),
  height: 130,
  width: double.infinity,  
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.white, Colors.blue[50]],
      begin: Alignment.centerLeft, 
      end: Alignment.centerRight, 
      tileMode: TileMode.clamp
    ),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(8),
      topRight: Radius.circular(8),
      bottomLeft: Radius.circular(8),
      bottomRight: Radius.circular(8)
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.blueGrey.withOpacity(0.2),
        spreadRadius: 5,
        blurRadius: 7,
        offset: Offset(0, 3),
      ),
    ],
  ),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
    Column(
        mainAxisAlignment: MainAxisAlignment.center,        
        children:[
          Text('${widget.data.machineName}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
          Text('${tanggal.day}/${tanggal.month}/${tanggal.year}'),
        ]
    ),          
    Row(    
    mainAxisAlignment: MainAxisAlignment.spaceAround,  
    children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,        
        children:[
          Text('Waktu Masuk'),
          Text('${masuk.hour}:${masuk.minute}:${masuk.second}')
        ]
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,        
        children:[
          Text('Waktu Pulang'),
          widget.data.pulang == "0001-01-01T00:00:00Z" ? Text("00:00:00"):
          Text('${pulang.hour}:${pulang.minute}:${pulang.second}')
        ]
      ),
      widget.data.pulang == "0001-01-01T00:00:00Z" ? 
      FlatButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: BorderSide(color: Colors.red)),
        color: Colors.red,
        textColor: Colors.white,
        padding: EdgeInsets.all(8.0),
        onPressed: () {_scanPulang();},
        child: Row(
          children: [
            Icon(Icons.qr_code),
            Text(
              "Pulang",
              style: TextStyle(color: Colors.white)
            )            
          ]
        ),
      ) : Column(
        mainAxisAlignment: MainAxisAlignment.center,        
        children:[
          Text('Total Waktu '),     
          Text('${pulang.difference(masuk).inMinutes} Menit'),          
        ]
      ),      
    ],
    )
    ]
  )  
  );
  }


  Future _scanPulang() async {
    await Permission.camera.request();
    String qrCode = await scanner.scan();
    if (qrCode == null) {
      print('nothing return.');
    } else {
      final dataQR = jsonDecode(qrCode);
      postPulang(dataQR["secret"],dataQR["username"]);     
    }
  }

    /* --- fungsi post masuk ---*/
  Future postPulang(String secret,String mesin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();  
    final response = await http.post(
      Uri.http(globals.serverIP, '/api/mobile/absensi/pulang'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${prefs.getString('userToken')}',
          'CRSF': globals.crsf,
      },
      body: jsonEncode(<String, String>{
        'secret': secret,
        'machine': mesin,
        'absensi_id': widget.data.id.toString(),    
      }),
    );
    Map<String, dynamic> msg = jsonDecode(response.body);
    if(response.statusCode == 201) {
      Future.sync(        
        () => widget.pagging.refresh(),
      );
    } else {      
      print(msg['message']);
      dialogError(msg['message']);
    } 
  }

  Future<void> dialogError(String pesan) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mohon Maaf !'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(pesan),   
                Text('Mungkin seharusnya anda absensi Pulang di tempat yang sama pada saat absensi Masuk'),             
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}