import 'package:flutter/material.dart';

class SmartMqttPage extends StatefulWidget {
  const SmartMqttPage({Key? key}) : super(key: key);

  @override
  _SmartMqttPageState createState() => _SmartMqttPageState();
}

class _SmartMqttPageState extends State<SmartMqttPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffDEC29B),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('MQTT TEST'),
          ElevatedButton(
            child: const Text('About'),
            onPressed: () {
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => const AboutPage(),
              //   ),
              // );
            },
          ),
        ],
      ),
    );
  }
}
