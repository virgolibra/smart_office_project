import 'package:flutter/material.dart';
import 'package:flutter_smart_office_project/table_display.dart';

class SmartTablePage extends StatefulWidget {
  const SmartTablePage({Key? key}) : super(key: key);

  @override
  _SmartTablePageState createState() => _SmartTablePageState();
}

class _SmartTablePageState extends State<SmartTablePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffffffff),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          TableDisplay(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
