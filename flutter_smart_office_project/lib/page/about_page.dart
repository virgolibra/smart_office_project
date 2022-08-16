import 'package:flutter/material.dart';
import '../widgets.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(color: Color(0xffffffff)),
        ),
        backgroundColor: Color(0xff242f35),
        foregroundColor: Color(0xffffffff),
      ),
      body: Column(
        children: const [
          Header("About"),
          Paragraph(
              "This is mobile application for Msc CE Dissertation Project. This application is not completed. I am still working on it."),
          Paragraph(
              "The implementation of some functions refers to the following websites."),
          Text(
              "+ App login feature is based on Colab tutorial https://firebase.google.com/codelabs/firebase-get-to-know-flutter#0"),
          SizedBox(
            height: 5,
          ),
          Text(
              "+ Firebase online tutorial on Youtube https://www.youtube.com/watch?v=wUSkeTaBonA&feature=emb_imp_woyt"),
          SizedBox(
            height: 5,
          ),
          Text(
              "+ Fetch weather is based on the example of [weather 2.0.1](https://pub.dev/packages/weather) flutter package."),
          SizedBox(
            height: 5,
          ),
          Text(
              "+ Uploading image to Firebase Storage online tutorial on Youtube (https://www.youtube.com/watch?v=YgjYVbg1oiA&t=927s)"),
          Header("Contact"),
          Text(
              "If you have any questions, please feel free to contact me: [minghao.zhang.21@ucl.ac.uk](minghao.zhang.21@ucl.ac.uk)"),
        ],
      ),
    );
  }
}
