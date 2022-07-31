import 'package:flutter/material.dart';
import './theme/custom_theme.dart';
import './page/login_page.dart';
// import './page/spending_display_page.dart';
import 'package:provider/provider.dart';
import 'splash.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      builder: (context, _) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Test App',
      // theme: ThemeData(
      //   buttonTheme: Theme.of(context).buttonTheme.copyWith(
      //         highlightColor: Colors.deepPurple,
      //       ),
      //   // primaryColor: Colors.yellow[700],
      //   primarySwatch: Colors.deepPurple,
      //   textTheme: GoogleFonts.robotoTextTheme(
      //     Theme.of(context).textTheme,
      //   ),
      //   visualDensity: VisualDensity.adaptivePlatformDensity,
      // ),
      theme: CustomTheme.lightTheme,
      // home: const LoginPage(), // home:   MyHomePage(),
      home: const Splash(), // home:   MyHomePage(),
      routes: {

        '/login_page': (BuildContext context) => const LoginPage(),
        // // '/message_test_page': (BuildContext context) => const MessageTestPage(),
        // '/spending_display_page': (BuildContext context) => const SpendingDisplayPage(),

        // '/camera_test_page': (BuildContext context) =>  CameraTestPage(),
      },
    );
  }
}