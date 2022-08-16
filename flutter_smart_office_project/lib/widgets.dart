import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_office_project/page/table_record_page.dart';
// import 'package:flutter_casa0015_mobile_app/page/item_detail_page.dart';
import 'package:intl/intl.dart';

class Header extends StatelessWidget {
  const Header(this.heading);
  final String heading;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          heading,
          style: const TextStyle(fontSize: 24),
        ),
      );
}

class Paragraph extends StatelessWidget {
  const Paragraph(this.content);
  final String content;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          content,
          style: const TextStyle(fontSize: 18),
        ),
      );
}

class ListElement extends StatefulWidget {
  // final String id;
  // final String name;
  // final String tableId;
  // final int timestamp;
  // final String imageId;
  // final bool isImageUpload;
  // final String tagId;
  // final String checkInStatus;
  ListElement({
    Key? key,
    required this.id,
    required this.tableId,
    required this.timestamp,
    required this.imageId,
    required this.isImageUpload,
    required this.tagId,
    required this.checkInStatus,
    required this.iconIndex,
    required this.name,
  }) : super(key: key);
  // const ListElement(this.text, this.subText);
  final String id;
  final String tableId;
  final int timestamp;
  final String imageId;
  final bool isImageUpload;
  final String tagId;
  final String checkInStatus;
  final int iconIndex;
  final String name;

  @override
  State<ListElement> createState() => _ListElementState();
}

class _ListElementState extends State<ListElement> {
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

  @override
  void initState() {
    // TODO: implement initState

    dateTime = DateTime.fromMillisecondsSinceEpoch(widget.timestamp);
    formattedDateTime = DateFormat('HH:mm:ss dd/MM/yy').format(dateTime!);
    date =
        '${dateTime!.day.toString()} ${DateFormat('MMMM').format(dateTime!)} ${dateTime!.year.toString()}';
    time =
        '${dateTime!.hour.toString()}:${dateTime!.minute.toString()}:${dateTime!.second.toString()}';
    weekday = DateFormat('EEEE').format(dateTime!);

    super.initState();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          child: ListTile(
            // visualDensity: VisualDensity(vertical: 1),
            leading: Icon(
              iconsList[widget.iconIndex],
              color: Color(0xff242f35),
              size: 20,
            ),
            title: Text(
              widget.name,
              style: TextStyle(fontSize: 10),
            ),
            subtitle: Text(
              iconsDescribe[widget.iconIndex],
              style: TextStyle(fontSize: 10),
            ),
            // subtitle: Text(widget.category),
            tileColor: const Color(0xffffffff),
            horizontalTitleGap: 1,

            trailing: SizedBox(
              height: 20,
              width: 110,
              child: Text(
                formattedDateTime!,
                style: TextStyle(fontSize: 12),
              ),
            ),

            // enabled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: BorderSide(
                color: Color(0xffffffff),
                width: 2,
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TableRecordPage(
                    tableId: widget.tableId,
                    iconIndex: widget.iconIndex,
                    timestamp: widget.timestamp,
                    isImageUpload: widget.isImageUpload,
                    imageId: widget.imageId,
                    name: widget.name,
                    tagId: widget.tagId,
                  ),
                ),
              );
            },
          ),
        ),
      );
}

class IconAndDetail extends StatelessWidget {
  const IconAndDetail(this.icon, this.detail);
  final IconData icon;
  final String detail;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              color: const Color(0xffe5e5e5),
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 10),
              Text(
                detail,
                style: const TextStyle(fontSize: 18),
              )
            ],
          ),
        ),
      );
}

class StyledButton extends StatelessWidget {
  const StyledButton({required this.child, required this.onPressed});
  final Widget child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xffE09E45)),
          backgroundColor: const Color(0xffE09E45),
          textStyle: const TextStyle(fontSize: 15),
        ),
        onPressed: onPressed,
        child: child,
      );
}

class StyledIconButton extends StatelessWidget {
  const StyledIconButton(
      {required this.icon, required this.label, required this.onPressed});
  final Icon icon;
  final Widget label;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: Color(0xff354856),
            width: 2,
          ),
          backgroundColor: const Color(0xff354856),
          textStyle: const TextStyle(
            fontSize: 15,
          ),
        ),
        onPressed: onPressed,
        label: label,
        icon: icon,
      );
}

class StyledIconButton2 extends StatelessWidget {
  const StyledIconButton2(
      {required this.icon, required this.label, required this.onPressed});
  final Widget icon;
  final Widget label;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xffE09E45)),
          backgroundColor: const Color(0xffE09E45),
          textStyle: const TextStyle(fontSize: 15, color: Color(0xffffffff)),
        ),
        onPressed: onPressed,
        icon: icon,
        label: label,
      );
}

class StyledIconButton3 extends StatelessWidget {
  const StyledIconButton3(
      {required this.icon, required this.label, required this.onPressed});
  final Widget icon;
  final Widget label;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xff6D42CE), width: 4),
          backgroundColor: const Color(0xffF5E0C3),
          textStyle: const TextStyle(fontSize: 15),
        ),
        onPressed: onPressed,
        icon: icon,
        label: label,
      );
}

class StyledIconButton4 extends StatelessWidget {
  const StyledIconButton4(
      {required this.icon, required this.label, required this.onPressed});
  final Widget icon;
  final Widget label;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xff354856)),
          backgroundColor: const Color(0xff354856),
          textStyle: const TextStyle(fontSize: 15, color: Color(0xffffffff)),
        ),
        onPressed: onPressed,
        icon: icon,
        label: label,
      );
}

class StyledIconButton5 extends StatelessWidget {
  const StyledIconButton5(
      {required this.icon, required this.label, required this.onPressed});
  final Widget icon;
  final Widget label;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xffE09E45)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xffE09E45),
          textStyle: const TextStyle(fontSize: 12, color: Color(0xffffffff)),
        ),
        onPressed: onPressed,
        icon: icon,
        label: label,
      );
}
