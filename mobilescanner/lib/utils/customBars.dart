import 'package:flutter/material.dart';

class CustomBars extends StatelessWidget implements PreferredSizeWidget {
      final String title;      
      final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

      CustomBars({Key key, @required this.title}) : super(key: key);      

      @override
      Size get preferredSize => const Size.fromHeight(55);

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          key: _scaffoldKey,
          body: Container( 
            color: Colors.blue,                               
            height: 120,
            child: Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 24.0),                
                  color: Colors.blue,
                  width: MediaQuery.of(context).size.width,
                  height: 120.0,
                  child: Center(
                    child: Text(
                      title,
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                  ),
                ),                
              ],
            ),
          ),
        );
      }
    }