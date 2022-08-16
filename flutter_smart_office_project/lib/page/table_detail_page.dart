import 'package:flutter/material.dart';

class TableDetailPage extends StatefulWidget {
  const TableDetailPage({
    Key? key,
    required this.id,
  }) : super(key: key);
  final String id;
  @override
  _TableDetailPageState createState() => _TableDetailPageState();
}

class _TableDetailPageState extends State<TableDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        title: Text(
          'Table Detail ${widget.id}',
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
