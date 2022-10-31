import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/globals.dart' as globals;
import '../../utils/app_exception.dart';
import './api_absensi.dart';
import './model_absensi.dart';
import './item_absensi.dart';

class Absensi extends StatefulWidget {  

  const Absensi({Key key}) : super(key: key);

  @override
  _Absensi createState() => _Absensi();
}

class _Absensi extends State<Absensi> {  
  String userToken;
  static const pageSize = 10;
  final PagingController<int, AbsenList> _pagingController = PagingController(firstPageKey: 0);

  @override  
  void initState() {  
    _pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });          
    super.initState();     
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:CustomScrollView(
        slivers:[
          PagedSliverList<int, AbsenList>(
            pagingController: _pagingController,        
            builderDelegate: PagedChildBuilderDelegate<AbsenList>(
              itemBuilder: (context, item, index) => AbsenListItem(
                data: item, pagging:_pagingController
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {          
          _scanMasuk();
        },
        label: Text('Masuk'),
        icon: Icon(Icons.qr_code),
        backgroundColor: Colors.green,
      ),      
    );    
  }  

  /* --- fungsi auto get absensi ---*/
  Future<void> fetchPage(int pageKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();    
    try {
      final newItems = await RemoteApi.getAbsenList(pageKey, pageSize,prefs.getString('userToken'));

      final isLastPage = newItems.length < pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch(error) {
      _pagingController.error = error;
    }
  }
  /* --- fungsi scanQrcode masuk ---*/
  Future _scanMasuk() async {
    await Permission.camera.request();
    String qrCode = await scanner.scan();
    if (qrCode == null) {
      print('nothing return.');
    } else {
      final data = jsonDecode(qrCode);
      postMasuk(data["secret"],data["username"]);
      print(data["username"]);
    }
  }

  /* --- fungsi post masuk ---*/
  Future postMasuk(String secret,String mesin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();  
    final response = await http.post(
      Uri.http(globals.serverIP, '/api/mobile/absensi/masuk'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${prefs.getString('userToken')}',
          'CRSF': globals.crsf,
      },
      body: jsonEncode(<String, String>{
        'secret': secret,
        'machine': mesin        
      }),
    );
    Map<String, dynamic> msg = jsonDecode(response.body);
    if(response.statusCode == 201) {
      Future.sync(        
        () => _pagingController.refresh(),
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

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

}
