import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import '../widgets.dart';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter_smart_office_project/secrets.dart';
import 'package:flutter_smart_office_project/widgets.dart';

import 'login_page.dart';

enum AppState { NOT_DOWNLOADED, DOWNLOADING, FINISHED_DOWNLOADING }
final client = MqttServerClient.withPort(myMqttBroker, '', myMqttPort);
var pongCount = 0; // Pong counter

class TableDetailPage extends StatefulWidget {
  const TableDetailPage({
    Key? key,
    required this.tableId,
  }) : super(key: key);
  final String tableId;
  @override
  _TableDetailPageState createState() => _TableDetailPageState();
}

class _TableDetailPageState extends State<TableDetailPage> {
  AppState _state = AppState.NOT_DOWNLOADED;
  final ValueNotifier<String> _msg = ValueNotifier<String>('unknown Message');
  final ValueNotifier<String> _tpc = ValueNotifier<String>('unknown Topic');
  String _tagFlag = '0';
  String _tagID = '00000000';
  String _getTagID = '00000000';
  bool isDataCollected = false;
  String formattedTime = DateFormat("HH:mm:ss").format(DateTime.now());
  int buttonOnPressed = 0;

  List<IconData> iconsList = [
    Icons.login_rounded,
    Icons.logout_rounded,
  ];

  @override
  void initState() {
    super.initState();
    // connect();
  }

  Future<int> connect() async {
    setState(() {
      _state = AppState.DOWNLOADING;
    });
    log("Starting Fetch Indoor");
    client.logging(on: true);
    client.setProtocolV311();
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;

    final connMess = MqttConnectMessage()
        .authenticateAs(myMqttUsername, myMqttPassword)
        .withClientIdentifier('Mqtt_MyClientUniqueId')
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('EXAMPLE::Mosquitto client connecting....');
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      print('EXAMPLE::client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      // Raised by the socket layer
      print('EXAMPLE::socket exception - $e');
      client.disconnect();
    }

    /// Check we are connected
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('EXAMPLE::Mosquitto client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      print(
          'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      exit(-1);
    }

    /// Ok, lets try a subscription
    print('EXAMPLE::Subscribing to the student/CASA0022/ucfnmz0/nano33/');
    const topic1 =
        'student/CASA0022/ucfnmz0/nano33/tagFlag'; // Not a wildcard topic
    const topic2 =
        'student/CASA0022/ucfnmz0/nano33/tagID'; // Not a wildcard topic

    client.subscribe(topic1, MqttQos.atMostOnce);
    client.subscribe(topic2, MqttQos.atMostOnce);

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      _tpc.value = c[0].topic;
      _msg.value = pt;

      switch (_tpc.value) {
        case topic1:
          _tagFlag = _msg.value;
          // isDataCollected = true;
          break;
        case topic2:
          _tagID = _msg.value;
          // isDataCollected = true;
          break;
        default:
          break;
      }

      if (_tagFlag == '1') {
        _getTagID = _tagID;
        isDataCollected = true;
      }

      /// The above may seem a little convoluted for users only interested in the
      /// payload, some users however may be interested in the received publish message,
      /// lets not constrain ourselves yet until the package has been in the wild
      /// for a while.
      /// The payload is a byte buffer, this will be specific to the topic
      print(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
    });

    /// If needed you can listen for published messages that have completed the publishing
    /// handshake which is Qos dependant. Any message received on this stream has completed its
    /// publishing handshake with the broker.
    client.published!.listen((MqttPublishMessage message) {
      print(
          'EXAMPLE::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
    });

    /// Lets publish to our topic
    /// Use the payload builder rather than a raw buffer
    /// Our known topic to publish to
    const pubTopic = 'student/CASA0022/ucfnmz0/testtopic';
    final builder = MqttClientPayloadBuilder();
    builder.addString('Hello from mqtt_client');

    /// Subscribe to it
    print('EXAMPLE::Subscribing to the Dart/Mqtt_client/testtopic topic');
    client.subscribe(pubTopic, MqttQos.exactlyOnce);

    /// Publish it
    print('EXAMPLE::Publishing our topic');
    client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!);

    /// Ok, we will now sleep a while, in this gap you will see ping request/response
    /// messages being exchanged by the keep alive mechanism.
    print('EXAMPLE::Sleeping....');
    await MqttUtilities.asyncSleep(6);

    /// Finally, unsubscribe and exit gracefully
    print('EXAMPLE::Unsubscribing');
    client.unsubscribe(topic1);
    client.unsubscribe(topic2);

    /// Wait for the unsubscribe message from the broker if you wish.
    await MqttUtilities.asyncSleep(1);
    print('EXAMPLE::Disconnecting');
    client.disconnect();
    print('EXAMPLE::Exiting normally');

    setState(() {
      _state = AppState.FINISHED_DOWNLOADING;
      formattedTime = DateFormat("HH:mm:ss").format(DateTime.now());
    });
    return 0;
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    } else {
      print(
          'EXAMPLE::OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
      exit(-1);
    }
    if (pongCount == 3) {
      print('EXAMPLE:: Pong count is correct');
    } else {
      print('EXAMPLE:: Pong count is incorrect, expected 3. actual $pongCount');
    }
  }

  /// The successful connect callback
  void onConnected() {
    print(
        'EXAMPLE::OnConnected client callback - Client connection was successful');
  }

  /// Pong callback
  void pong() {
    print('EXAMPLE::Ping response client callback invoked');
    pongCount++;
  }

  @override
  void dispose() {
    _msg.dispose();
    _tpc.dispose();

    client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        title: Text(
          'Table Detail ${widget.tableId}',
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
        children: [
          //   StyledIconButton2(
          //   onPressed: () async {
          //
          //   },
          //   icon: const Text('Check in'),
          //   label: Icon(Icons.keyboard_arrow_right_rounded),
          // ),
          SizedBox(
            height: 10,
          ),
          widget.tableId == '01' ? _rfidView() : Text(" "),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: BoxDecoration(
                  color: const Color(0xffffffff),
                  border: Border.all(
                    color: Color(0xff242f35),
                    width: 8,
                  ),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Table ${widget.tableId} Record',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const Divider(
                    height: 8,
                    thickness: 2,
                    indent: 0,
                    endIndent: 0,
                    color: Colors.black,
                  ),
                  widget.tableId == '01'
                      ? Consumer<ApplicationState>(
                          builder: (context, appState, _) => Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              DisplaySmartTableItem(
                                items: appState.smartTableReportMessages,
                              ),
                            ],
                          ),
                        )
                      : Text(" "),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rfidView() => _state == AppState.FINISHED_DOWNLOADING
      ? contentFinishedDownload()
      : _state == AppState.DOWNLOADING
          ? contentDownloading()
          : contentNotDownloaded();

  Widget contentNotDownloaded() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
            color: const Color(0xffffffff),
            border: Border.all(
              color: Color(0xff242f35),
              width: 8,
            ),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            Text(
              'Table ${widget.tableId} Scan',
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.black,
                  fontWeight: FontWeight.w700),
            ),
            const Divider(
              height: 8,
              thickness: 2,
              indent: 0,
              endIndent: 0,
              color: Colors.black,
            ),
            Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Press the button to start check-in and check-out',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Please swipe the card over the reader',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      StyledIconButton5(
                        onPressed: () async {
                          connect();
                        },
                        icon: const Text(
                          'Scan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        label: Icon(
                          Icons.exit_to_app_outlined,
                          size: 50,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Expanded(child: _weatherIconDisplay()),
          ],
        ),
      ),
    );
  }

  Widget contentDownloading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
            color: const Color(0xffffffff),
            border: Border.all(
              color: Color(0xff242f35),
              width: 8,
            ),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            Text(
              'Table ${widget.tableId} Scan',
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.black,
                  fontWeight: FontWeight.w700),
            ),
            const Divider(
              height: 8,
              thickness: 2,
              indent: 0,
              endIndent: 0,
              color: Colors.black,
            ),
            Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Fetching RFID Data...',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  'Please do not leave this page.',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(top: 50),
                    child: const Center(
                        child: CircularProgressIndicator(
                      strokeWidth: 10,
                      color: Colors.black,
                    ))),
              ],
            ),

            // Expanded(child: _weatherIconDisplay()),
          ],
        ),
      ),
    );
  }

  Widget contentFinishedDownload() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
                color: const Color(0xffffffff),
                border: Border.all(
                  color: Color(0xff242f35),
                  width: 8,
                ),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Table ${widget.tableId} Scan',
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          Text(
                            'based on MQTT',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
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
                  color: Colors.black,
                ),
                SizedBox(
                  height: 50,
                  child: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 30,
                        child: ListTile(
                          leading: const Icon(
                            Icons.label_outline_rounded,
                            color: Colors.black,
                          ),
                          minLeadingWidth: 2,
                          title: const Text(
                            'Tag',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          selected: false,
                          trailing: Text(
                            '${_getTagID}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                Text(
                  isDataCollected
                      ? "Updated at $formattedTime "
                      : "No valid card data. Please swipe the card again or check the device connection.",
                  style: const TextStyle(color: Colors.black, fontSize: 8),
                ),
                // Expanded(child: _weatherIconDisplay()),
                SizedBox(
                  height: 2,
                ),
                Row(
                  children: [
                    StyledIconButton5(
                      onPressed: () async {
                        connect();
                        _state = AppState.DOWNLOADING;
                        setState(() {
                          _tagID = '00000000';
                          _getTagID = '00000000';
                          isDataCollected = false;
                        });

                      },
                      icon: const Text(
                        'Re-scan',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      label: Icon(
                        Icons.search_rounded,
                        size: 15,
                      ),
                    ),
                    IconButton(
                      iconSize: 30,
                      highlightColor: Colors.red,
                      // color: const Color(0xff5D4524),
                      onPressed: () {
                        setState(() {
                          buttonOnPressed = 0;
                          // iconDescriptionIndex = index;
                        });
                      },
                      icon: Icon(iconsList[0]),
                      color: (buttonOnPressed == 0)
                          ? Color(0xffE09E45)
                          : Colors.black,
                    ),
                    Text(
                      "In",
                      style: TextStyle(
                        fontSize: 12,
                        color: (buttonOnPressed == 0)
                            ? Color(0xffE09E45)
                            : Colors.black,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      iconSize: 30,
                      highlightColor: Colors.red,
                      // color: const Color(0xff5D4524),
                      onPressed: () {
                        setState(() {
                          buttonOnPressed = 1;
                          // iconDescriptionIndex = index;
                        });
                      },
                      icon: Icon(iconsList[1]),
                      color: (buttonOnPressed == 1)
                          ? Color(0xffE09E45)
                          : Colors.black,
                    ),
                    Text(
                      "Out",
                      style: TextStyle(
                        fontSize: 12,
                        color: (buttonOnPressed == 1)
                            ? Color(0xffE09E45)
                            : Colors.black,
                      ),
                    ),
                  ],
                ),

                isDataCollected
                    ? Consumer<ApplicationState>(
                        builder: (context, appState, _) => Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AddSmartTableItem(
                              addItem: (String checkInStatus, String imageId,
                                      bool isImageUpload) =>
                                  appState.addMessageToSmartTableReport(
                                widget.tableId,
                                imageId,
                                isImageUpload,
                                _getTagID,
                                checkInStatus,
                                buttonOnPressed,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                            color: const Color(0xff496571),
                            borderRadius: BorderRadius.circular(8)),
                        child: const SizedBox(
                            height: 100,
                            width: 300,
                            child: Text(
                              "No valid card data. Please swipe the card again",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            )),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
