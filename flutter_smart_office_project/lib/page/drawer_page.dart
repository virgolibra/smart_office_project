import 'package:flutter/material.dart';

import 'login_page.dart';
import 'about_page.dart';
import '../authentication.dart';

class DrawerPage extends StatelessWidget {
  const DrawerPage({Key? key, required this.email}) : super(key: key);
  final String email;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              // color: Colors.white70,
              color: Color(0xff242f35),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.account_circle_rounded,
                  size: 80,
                  color: Color(0xffffffff),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  email,
                  style: TextStyle(fontSize: 16, color: Color(0xffffffff)),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Log Out'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login_page', ModalRoute.withName('login_page'));
              // Navigator.of(context).pop(
              //   MaterialPageRoute(
              //     builder: (context) => const LoginPage(),
              //   ),
              // );
              // Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('About'),
            onTap: () {
              // Navigator.pop(context);
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
