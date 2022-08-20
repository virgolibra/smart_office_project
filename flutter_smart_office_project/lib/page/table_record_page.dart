import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:intl/intl.dart';

import '../widgets.dart';

enum AppState { NOT_DOWNLOADED, DOWNLOADING, FINISHED_DOWNLOADING }

class TableRecordPage extends StatefulWidget {
  const TableRecordPage({
    Key? key,
    required this.tableId,
    required this.iconIndex,
    required this.timestamp,
    required this.isImageUpload,
    required this.imageId,
    required this.name,
    required this.tagId,
  }) : super(key: key);
  final String tableId;
  final int iconIndex;
  final int timestamp;
  final bool isImageUpload;
  final String imageId;
  final String name;
  final String tagId;

  @override
  _TableRecordPageState createState() => _TableRecordPageState();
}

class _TableRecordPageState extends State<TableRecordPage> {
  AppState _state = AppState.NOT_DOWNLOADED;

  List<IconData> iconsList = [
    Icons.login_rounded,
    Icons.logout_rounded,
  ];

  List<String> iconsDescribe = [
    "Check-in",
    "Check-out",
  ];

  DateTime? dateTime;
  String? date;
  String? time;
  String? weekday;
  String? formattedDateTime;

  late final Uint8List? data;
  late final String? imageUrl;
  late XFile image;

  @override
  void initState() {
    // TODO: implement initState
    dateTime = DateTime.fromMillisecondsSinceEpoch(widget.timestamp);

    formattedDateTime =
        DateFormat('E  dd MMMM yyyy  HH:mm:ss').format(dateTime!);

    date =
        '${dateTime!.day.toString()} ${DateFormat('MMMM').format(dateTime!)} ${dateTime!.year.toString()}';
    time = DateFormat('HH:mm:ss').format(dateTime!);
    // '${dateTime!.hour.toString()}:${dateTime!.minute.toString()}:${dateTime!.second.toString()}';
    weekday = DateFormat('EEEE').format(dateTime!);

    // if (widget.isReceiptUpload){
    //   downloadImage();
    // }

    downloadImage();
    super.initState();
  }

  Future<void> downloadImage() async {
    setState(() {
      _state = AppState.DOWNLOADING;
    });

    final storageRef = FirebaseStorage.instance.ref();
    final islandRef = storageRef.child(
        "images/spendingReport/H731NtAnbnPrhB02ZDj585bb9Ma2/CAP638979139413938825.jpg");

    try {
      imageUrl = await storageRef
          .child(
              'images/spendingReport/${FirebaseAuth.instance.currentUser?.uid}${widget.imageId}')
          .getDownloadURL();
      log('22222222222222222222222222222222$imageUrl!');

      setState(() {
        _state = AppState.FINISHED_DOWNLOADING;
      });
    } on FirebaseException catch (e) {
      // Handle any errors.
    }
  }

  Widget contentFinishedDownload() {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          width: MediaQuery.of(context).size.width * 0.95,
          child: Image(image: NetworkImage(imageUrl!)),
        ),
      ],
    );
  }

  Widget contentDownloading() {
    return Container(
      margin: EdgeInsets.all(5),
      child: Column(children: [
        Text(
          'Fetching Image...',
          style: TextStyle(fontSize: 20),
        ),
        Container(
            margin: EdgeInsets.only(top: 10),
            child: Center(child: CircularProgressIndicator(strokeWidth: 10)))
      ]),
    );
  }

  Widget contentNotDownloaded() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Wait for starting downloading',
          ),
        ],
      ),
    );
  }

  Widget _resultView() => _state == AppState.FINISHED_DOWNLOADING
      ? contentFinishedDownload()
      : _state == AppState.DOWNLOADING
          ? contentDownloading()
          : contentNotDownloaded();

  // Future<void> deleteMessageToSpendingReport() {
  //   return FirebaseFirestore.instance
  //       .collection('SpendingReport')
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .collection(FirebaseAuth.instance.currentUser!.uid)
  //       .doc(widget.id)
  //       .delete();
  // }

  Future<bool?> showAddItemDoneDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Press Yes to remove this item."),
          content: const Text(
            "Item will be permanently deleted.",
            style: TextStyle(color: Colors.red, fontSize: 15),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(color: Colors.black87, fontSize: 20),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),

            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(color: Colors.red, fontSize: 20),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
                setState(() {});
              },
            ),
            // TextButton(
            //   child: Text("delete"),
            //   onPressed: () {
            //     Navigator.of(context).pop(true);
            //   },
            // ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Table ${widget.tableId} Record',
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xffffffff),
          ),
        ),
        backgroundColor: Color(0xff242f35),
        foregroundColor: Color(0xffffffff),
      ),
      backgroundColor: Color(0xffffffff),
      body: ListView(
        children: [
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                  color: const Color(0xffffffff),
                  border: Border.all(
                    color: Color(0xff242f35),
                    width: 8,
                  ),
                  borderRadius: BorderRadius.circular(10)),
              child: ListView(
                // physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  SizedBox(
                    height: 1,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        iconsDescribe[widget.iconIndex],
                        style: TextStyle(
                            fontSize: 22,
                            color: Colors.black87,
                            fontWeight: FontWeight.w700),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              formattedDateTime!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    height: 8,
                    thickness: 2,
                    indent: 0,
                    endIndent: 0,
                    color: Colors.black87,
                  ),

                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Icon(
                          iconsList[widget.iconIndex],
                          size: 80,
                        ),
                      ),
                      //
                    ],
                  ),
                  SizedBox(
                    height: 130,
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: 30,
                          child: ListTile(
                            leading: const Icon(
                                Icons.drive_file_rename_outline_rounded),
                            minLeadingWidth: 2,
                            title: const Text('Name'),
                            selected: false,
                            trailing: Text(
                              widget.name,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: ListTile(
                            leading: const Icon(
                              Icons.label_rounded,
                            ),
                            minLeadingWidth: 2,
                            title: const Text('Tag ID'),
                            selected: false,
                            trailing: Text(
                              widget.tagId,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: ListTile(
                            leading: const Icon(Icons.punch_clock_rounded),
                            minLeadingWidth: 2,
                            title: const Text('Time Added'),
                            selected: false,
                            trailing: Text(
                              time!,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: ListTile(
                            leading: const Icon(Icons.date_range_rounded),
                            minLeadingWidth: 2,
                            title: const Text('Date Added'),
                            selected: false,
                            trailing: Text(
                              date!,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    height: 8,
                    thickness: 2,
                    indent: 0,
                    endIndent: 0,
                    color: Colors.black87,
                  ),
                  const IconAndDetail(Icons.photo_rounded, 'Uploaded Photo'),
                  widget.isImageUpload == true
                      ? _resultView()
                      : const Text(
                          'No photo upload',
                          style: TextStyle(fontSize: 16),
                        ),
                  const Divider(
                    height: 8,
                    thickness: 2,
                    indent: 0,
                    endIndent: 0,
                    color: Colors.black87,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  // SizedBox(
                  //   height: 40,
                  //   child: OutlinedButton(
                  //     style: OutlinedButton.styleFrom(
                  //         backgroundColor: Color(0xffE09E45),
                  //         side: const BorderSide(
                  //             color: Color(0xffE09E45), width: 4),
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(25),
                  //         ),
                  //         // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  //         textStyle: const TextStyle(
                  //             fontSize: 30, fontWeight: FontWeight.bold)),
                  //     onPressed: () async {
                  //       // await showAddItemDoneDialog();
                  //
                  //       var isTrue = await showAddItemDoneDialog();
                  //       if (isTrue!) {
                  //         // deleteMessageToSpendingReport();
                  //         Navigator.of(context).pop();
                  //       }
                  //     },
                  //     child: Row(
                  //       children: const [
                  //         Icon(
                  //           Icons.remove_circle_outline_rounded,
                  //           color: Color(0xffF5E0C3),
                  //         ),
                  //         SizedBox(width: 10),
                  //         Text(
                  //           'Remove Item',
                  //           style: TextStyle(
                  //               fontSize: 16,
                  //               color: Color(0xffF5E0C3),
                  //               fontWeight: FontWeight.bold),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 5,
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
