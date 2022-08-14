import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  ListElement(
      {Key? key,
        required this.id,
      required this.item,
      required this.category,
      required this.price,
      required this.iconIndex,
      required this.lat,
      required this.lon,
      required this.timestamp,
      required this.isReceiptUpload,
      required this.imageId})
      : super(key: key);
  // const ListElement(this.text, this.subText);
  final String id;
  final String item;
  final String category;
  final String price;
  final int iconIndex;
  final double lat;
  final double lon;
  final int timestamp;
  final bool isReceiptUpload;
  final String imageId;

  @override
  State<ListElement> createState() => _ListElementState();
}

class _ListElementState extends State<ListElement> {
  List<IconData> iconsList = [
    Icons.widgets_rounded, // General
    Icons.receipt_rounded, // Bills
    Icons.restaurant_rounded, // Eating out
    Icons.delivery_dining_rounded, // Delivery
    Icons.emoji_emotions_rounded, // Entertainment
    Icons.card_giftcard_rounded, // Gifts
    Icons.store_rounded, // Groceries
    Icons.airplanemode_active_rounded, // Travel
    Icons.shopping_cart_rounded, // Shopping
    Icons.directions_bus_rounded, // Transport
    Icons.favorite_rounded, // Personal care
    Icons.pets_rounded, // Pets
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
    formattedDateTime =
        DateFormat('HH:mm:ss dd/MM/yy').format(dateTime!);
    date =
        '${dateTime!.day.toString()} ${DateFormat('MMMM').format(dateTime!)} ${dateTime!.year.toString()}';
    time =
        '${dateTime!.hour.toString()}:${dateTime!.minute.toString()}:${dateTime!.second.toString()}';
    weekday = DateFormat('EEEE').format(dateTime!);

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: ListTile(
          leading: Icon(
            iconsList[widget.iconIndex],
            color: Color(0xff936F3E),
            size: 35,
          ),
          title: Text(widget.item),
          subtitle: Text(formattedDateTime!),
          // subtitle: Text(widget.category),
          tileColor: const Color(0xffDEC29B),

          trailing: SizedBox(
            height: 40,
            width: 110,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('£'),
                Text(
                  widget.price,
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),

          // enabled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: Color(0xffF5E0C3),
              width: 2,
            ),
          ),
          onTap: () {
            // Navigator.pushNamed(context, '/first_page');

            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => ItemDetailPage(
            //       id: widget.id,
            //       lat: widget.lat,
            //       lon: widget.lon,
            //       item: widget.item,
            //       category: widget.category,
            //       iconIndex: widget.iconIndex,
            //       price: widget.price,
            //       timestamp: widget.timestamp,
            //       isReceiptUpload: widget.isReceiptUpload,
            //       imageId: widget.imageId,
            //     ),
            //   ),
            // );

          },
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
          side: const BorderSide(color: Color(0xff6D42CE)),
          backgroundColor: const Color(0xff6D42CE),
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
            color: Color(0xffE09E45),
            width: 2,
          ),
          backgroundColor: const Color(0xffE09E45),
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
          side: const BorderSide(color: Color(0xff354856)),
          backgroundColor: const Color(0xff354856),
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
