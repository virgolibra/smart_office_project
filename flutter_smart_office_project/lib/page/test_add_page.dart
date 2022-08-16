import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets.dart';
import 'login_page.dart';


class TestAddPage extends StatefulWidget {
  const TestAddPage({Key? key}) : super(key: key);

  @override
  _TestAddPageState createState() => _TestAddPageState();
}

class _TestAddPageState extends State<TestAddPage> {
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

  List<String> iconsListDescription = [
    'General',
    'Bills',
    'Eating out',
    'Delivery',
    'Entertainment',
    'Gifts',
    'Groceries',
    'Travel',
    'Shopping',
    'Transport',
    'Personal care',
    'Pets',
  ];

  int buttonOnPressed = 0;
  double? autoLat, autoLon;

  // int iconDescriptionIndex
  @override
  void initState() {
    super.initState();
    // ws = new WeatherFactory(key);
    // _getUserLocation();
  }



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
            color: const Color(0xffDEC29B),
            borderRadius: BorderRadius.circular(10)),
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            // Image.asset('assets/image1.jpg'),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Add Item',
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.black87,
                      fontWeight: FontWeight.w700),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text(
                        'Choose a category to get started',
                        style: TextStyle(
                          fontSize: 12,
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

            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 120,
                  padding: EdgeInsets.all(4),
                  // decoration: BoxDecoration(
                  //     color: const Color(0xffC9A87C),
                  //     borderRadius: BorderRadius.circular(10)),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),

                    gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 50,
                        childAspectRatio: 1,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5),
                    itemCount: iconsList.length,
                    // crossAxisSpacing: 10,
                    // mainAxisSpacing: 10,
                    // crossAxisCount: 2,
                    itemBuilder: (BuildContext context, int index) {
                      return IconButton(
                        iconSize: 40,
                        highlightColor: Colors.red,
                        // color: const Color(0xff5D4524),
                        onPressed: () {
                          setState(() {
                            buttonOnPressed = index;
                            // iconDescriptionIndex = index;
                          });
                        },
                        icon: Icon(iconsList[index]),
                        color: (buttonOnPressed == index)
                            ? Color(0xff936F3E)
                            : Color(0xffF5E0C3),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Text('Selected Category: '),
                    Text(
                      iconsListDescription[buttonOnPressed],
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),

            Consumer<ApplicationState>(
              builder: (context, appState, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // SpendingReport(
                  //   addMessage: (message, type) =>
                  //       appState.addMessageToSpendingReport(message, type),
                  //   messages: appState.spendingReportMessages,
                  // ),
                  AddSmartChairItem(
                    addItem: ( String chairId, String tagId, String checkInStatus, String imageId, bool isImageUpload) =>
                        appState.addMessageToSmartChairReport(
                            chairId,
                          imageId,
                          isImageUpload,
                            tagId,
                            checkInStatus,
                            buttonOnPressed,

                          ),

                    // String chairId,
                    // String imageId,
                    // bool isImageUpload,
                    // String tagId,
                    // String checkInStatus,
                    // int iconIndex,
                    // messages: appState.spendingReportMessages,
                  ),

                  // DisplaySpendingItem(
                  //   messages: appState.spendingReportMessages,
                  // ),
                ],
              ),
            ),

            //
            // Text(
            //   'Lat: $autoLat',
            //   style: TextStyle(fontSize: 15),
            // ),
            // Text(
            //   'Lon: $autoLon',
            //   style: TextStyle(fontSize: 15),
            // ),
            // const Divider(
            //   height: 8,
            //   thickness: 2,
            //   indent: 8,
            //   endIndent: 8,
            //   color: Colors.grey,
            // ),
            // ElevatedButton(
            //   child: const Text('Spending'),
            //   onPressed: () {
            //     Navigator.pushNamed(context, '/spending_display_page');
            //     // Navigator.pop(context);
            //   },
            // ),
            //
            // const Header("CASA0015 Assessment"),
            // const Paragraph(
            //   'Mobile application development for casa0015-assessment',
            // ),
          ],
        ),
      ),
    );
  }
}
