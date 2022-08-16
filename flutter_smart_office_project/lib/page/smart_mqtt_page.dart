import 'package:flutter/material.dart';
import 'package:flutter_smart_office_project/chair_display.dart';



class SmartMqttPage extends StatefulWidget {
  const SmartMqttPage({Key? key}) : super(key: key);

  @override
  _SmartMqttPageState createState() => _SmartMqttPageState();
}

class _SmartMqttPageState extends State<SmartMqttPage> {


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffffffff),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChairDisplay(),
          // const WidgetA(),
          // Text('MQTT TEST'),
          //
          // ValueListenableBuilder<String>(
          //   builder: (context, value, child) {
          //     // return Text(value);
          //     return Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Text(value),
          //         // _ch1 == 1 ? Icon(Icons.chair_rounded) : Icon(Icons.chair_outlined),
          //         // _ch2 == 1 ? Icon(Icons.chair_rounded) : Icon(Icons.chair_outlined),
          //         // _ch3 == 1 ? Icon(Icons.chair_rounded) : Icon(Icons.chair_outlined),
          //
          //       ],
          //     );
          //   },
          //   valueListenable: _msg,
          // ),
          // ValueListenableBuilder<String>(
          //   builder: (context, value, child) {
          //     return Text(value);
          //
          //     // imageData.receiptStatus == true
          //     //     ? SizedBox(
          //     //     height: 100,
          //     //     width: 300,
          //     //     child: Image.file(File(imageData.imagePath)))
          //     //     : const Text("Click to add a receipt"),
          //   },
          //   valueListenable: _msg2,
          // ),

        ],
      ),
    );
  }

  @override
  void dispose() {

    super.dispose();
  }
}

