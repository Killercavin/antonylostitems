import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lostitems/account_screen.dart';
import 'package:lostitems/admin_dashboard.dart';
import 'package:lostitems/admin_dashboard.dart';
import 'package:lostitems/home_page.dart';
import 'package:lostitems/lostitem_eportscreen.dart';


import 'package:lostitems/claimitem.dart';


import 'package:lostitems/locationautocomplete.dart';
import 'package:lostitems/reporteditems.dart';

import 'itemlistscreen.dart';




class AdminNavBarRoots extends StatefulWidget {
  const AdminNavBarRoots ({Key? key}) : super(key: key);

  @override
  State<AdminNavBarRoots> createState() => _AdminNavBarRootsState();
}

class _AdminNavBarRootsState extends State<AdminNavBarRoots> {
  int _selectedIndex = 0;
  final _screens = [
    AdminDashboard(),
    ReportedItemsScreen(),
    ItemListScreen(),









  ];

  static get itemId => null;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: SizedBox(
        height: 80,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF7165D6),
          unselectedItemColor: Colors.black26,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [

            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home), label: "HomePage"),
            BottomNavigationBarItem(
                icon: Icon(Icons.list), label: "itemlists"),

            BottomNavigationBarItem(icon: Icon(CupertinoIcons.location_fill),label: "Location")
          ],
        ),
      ),
    );
  }
}
