import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:flutter_smart_office_project/page/smart_home_page.dart';
import 'package:flutter_smart_office_project/page/smart_setting_page.dart';
import 'package:flutter_smart_office_project/page/smart_mqtt_page.dart';
import 'package:flutter_smart_office_project/page/smart_table_page.dart';
import 'package:flutter_smart_office_project/page/test_add_page.dart';
import 'package:geolocator/geolocator.dart';
import 'drawer_page.dart';
import 'package:bottom_bar/bottom_bar.dart';


class SmartBasePage extends StatefulWidget {
  const SmartBasePage({Key? key, required this.email}) : super(key: key);
  final String? email;

  @override
  State<SmartBasePage> createState() => _SmartBasePage();
}

class _SmartBasePage extends State<SmartBasePage> {
  int _currentPage = 0;
  final _pageController = PageController();

  double? autoLat, autoLon;
  @override
  void initState() {
    super.initState();
    _getUserLocation();

  }

  void _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    log("sdsddssssssssss $position");

    // List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      // _userCurrentPosition = LatLng(position.latitude, position.longitude);
      // print('${placemark[0].name}');

      autoLat = position.latitude;
      autoLon = position.longitude;
    });

    // await Future.delayed(Duration(milliseconds: 1000), () {});
  }
  // Widget build(BuildContext context) {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        title: const Text('Smart Office', style: TextStyle(color: Color(0xffffffff)),),
        backgroundColor: Color(0xff242f35),
        foregroundColor: Color(0xffffffff),
      ),
      drawer: DrawerPage(
        email: widget.email!,
      ),
      body: PageView(
        controller: _pageController,
        children: [
          SmartHomePage(lat: autoLat!, lon: autoLon!,),
          // Container(color: Colors.greenAccent.shade700),
          // Container(color: Colors.orange),
          SmartMqttPage(),
          SmartTablePage(),
          TestAddPage(),
          // SmartSettingPage(email: widget.email!),
        ],
        onPageChanged: (index) {
          // Use a better state management solution
          // setState is used for simplicity
          setState(() => _currentPage = index);
        },
      ),
      bottomNavigationBar: BottomBar(
        backgroundColor: const Color(0xff242f35),
        selectedIndex: _currentPage,
        onTap: (int index) {
          _pageController.jumpToPage(index);
          setState(() => _currentPage = index);
        },
        items: <BottomBarItem>[
          BottomBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
            activeColor: Color(0xffffffff),
            inactiveColor: Color(0xffffffff),
          ),
          BottomBarItem(
            icon: Icon(Icons.chair_rounded),
            title: Text('Seat'),
            activeColor: Color(0xffffffff),
            inactiveColor: Color(0xffffffff),
          ),
          BottomBarItem(
            icon: Icon(Icons.table_restaurant_rounded),
            title: Text('Table'),
            activeColor: Color(0xffffffff),
            inactiveColor: Color(0xffffffff),
          ),
          BottomBarItem(
            icon: Icon(Icons.settings),
            title: Text('Settings'),
            activeColor: Color(0xffffffff),
            inactiveColor: Color(0xffffffff),

          ),
        ],
      ),
    );
  }
}
