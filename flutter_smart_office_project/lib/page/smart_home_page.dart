import 'package:flutter/material.dart';
import 'package:flutter_smart_office_project/Indoor_display.dart';

import '../weather_display.dart';
import '../widgets.dart';

class SmartHomePage extends StatefulWidget {
  const SmartHomePage({Key? key, required this.lat, required this.lon})
      : super(key: key);
  final double lat;
  final double lon;
  @override
  _SmartHomePageState createState() => _SmartHomePageState();
}

class _SmartHomePageState extends State<SmartHomePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Image.asset('assets/image1.jpg'),
        const SizedBox(height: 8),
        // const IconAndDetail(Icons.home_rounded, 'Home Page'),
        // const Divider(
        //   height: 8,
        //   thickness: 2,
        //   indent: 8,
        //   endIndent: 8,
        //   color: Color(0xffE09E45),
        // ),

        Expanded(
          child:
          Column(
            children: [
              WeatherDisplay(
                lat: widget.lat,
                lon: widget.lon,
              ),
              IndoorDisplay(),
            ],
          ),
        ),

        // Image.asset('assets/click_to_add.png'),
      ],
    );
  }
}
