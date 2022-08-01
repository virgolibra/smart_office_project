import 'package:flutter/material.dart';


import 'about_page.dart';

class SmartSettingPage extends StatefulWidget {
  const SmartSettingPage({Key? key, required this.email}) : super(key: key);
  final String email;

  @override
  _SmartSettingPageState createState() => _SmartSettingPageState();
}

class _SmartSettingPageState extends State<SmartSettingPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffDEC29B),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.email),
          ElevatedButton(
            child: const Text('Log Out'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login_page', ModalRoute.withName('login_page'));
            },
          ),
          ElevatedButton(
            child: const Text('About'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AboutPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
