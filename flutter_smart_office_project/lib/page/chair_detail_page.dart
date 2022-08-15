import 'package:flutter/material.dart';

class ChairDetailPage extends StatefulWidget {
  const ChairDetailPage({
    Key? key,
    required this.id,
  }) : super(key: key);
  final String id;
  @override
  _ChairDetailPageState createState() => _ChairDetailPageState();
}

class _ChairDetailPageState extends State<ChairDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        title: Text(
          'Seat Detail ${widget.id}',
          // widget.item,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xffffffff),
          ),
        ),
        backgroundColor: Color(0xff242f35),
        foregroundColor: Color(0xffffffff),
      ),
      body: ListView(
        children: [],
      ),
    );
  }
}
