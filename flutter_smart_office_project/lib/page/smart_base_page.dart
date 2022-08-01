import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:flutter_smart_office_project/page/smart_home_page.dart';
import 'package:flutter_smart_office_project/page/smart_setting_page.dart';
import 'package:flutter_smart_office_project/page/smart_mqtt_page.dart';
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
      backgroundColor: Color(0xffF5E0C3),
      appBar: AppBar(
        title: const Text('Smart Office'),
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
          SmartHomePage(lat: autoLat!, lon: autoLon!,),
          SmartSettingPage(email: widget.email!),
        ],
        onPageChanged: (index) {
          // Use a better state management solution
          // setState is used for simplicity
          setState(() => _currentPage = index);
        },
      ),
      bottomNavigationBar: BottomBar(
        backgroundColor: const Color(0xffE09E45),

        selectedIndex: _currentPage,
        onTap: (int index) {
          _pageController.jumpToPage(index);
          setState(() => _currentPage = index);
        },
        items: <BottomBarItem>[
          BottomBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
            activeColor: Color(0xffF5E0C3),
          ),
          BottomBarItem(
            icon: Icon(Icons.add_box_rounded),
            title: Text('Add Item'),
            activeColor: Color(0xffF5E0C3),
          ),
          BottomBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            title: Text('Transaction'),
            activeColor: Color(0xffF5E0C3),
          ),
          BottomBarItem(
            icon: Icon(Icons.settings),
            title: Text('Settings'),
            activeColor: Color(0xffF5E0C3),

          ),
        ],
      ),
    );
  }
}