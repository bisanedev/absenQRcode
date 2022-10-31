import 'package:flutter/material.dart';
import './absensi/app_absensi.dart';
import './app_profile.dart';
import '../utils/customBars.dart';


class Apps extends StatefulWidget {          
  @override
  _Apps createState() => _Apps();
}

class _Apps extends State<Apps> { 
  int _selectedIndex = 0;    
  String title = "Absensi";  

  @override  
  void initState() {        
    super.initState();     
  }  

  /* --- Widget Page Absensi & Profile --- */
  static const List<Widget> halaman = <Widget>[
    Absensi(
      key: PageStorageKey('absensi'),      
    ),
    Profile(
      key: PageStorageKey('profile'),
    ),
  ];

  final PageStorageBucket bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      backgroundColor: Color(0xFFF2F1F1), 
      appBar: new CustomBars(title:title),     
      body: PageStorage(
        child: halaman[_selectedIndex],
        bucket: bucket,        
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Absensi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'Profile',
          ),     
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    switch(index){
      case 0:
        setState(() {
          title = "Absensi";
          _selectedIndex = index;
        });
        break;
      case 1:
        setState(() {
          title = "Profil";
          _selectedIndex = index;
        });
        break;        
    }   
  }

}

