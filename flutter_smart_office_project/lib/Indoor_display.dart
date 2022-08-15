import 'dart:developer';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter_smart_office_project/secrets.dart';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

enum AppState {NOT_DOWNLOADED, DOWNLOADING, FINISHED_DOWNLOADING}
final client = MqttServerClient.withPort(myMqttBroker, '', myMqttPort);
var pongCount = 0; // Pong counter

class IndoorDisplay extends StatefulWidget {
  const IndoorDisplay({Key? key}) : super(key: key);

  @override
  _IndoorDisplayState createState() => _IndoorDisplayState();
}

class _IndoorDisplayState extends State<IndoorDisplay> {

  AppState _state = AppState.NOT_DOWNLOADED;
  final ValueNotifier<String> _msg = ValueNotifier<String>('unknown Message');
  final ValueNotifier<String> _tpc = ValueNotifier<String>('unknown Topic');
  double _temperature = 0.0;
  double _pressure = 0.0;
  double _altitude = 0.0;
  bool isDataCollected = false;

  @override
  void initState() {
    super.initState();
    connect();
  }

  @override
  Widget build(BuildContext context) {
    return _indoorView();
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
    // const topic1 = 'student/CASA0022/ucfnmz0/nano33/pressure'; // Not a wildcard topic
    const topic1 = 'student/CASA0022/ucfnmz0/nano33/temperature'; // Not a wildcard topic
    const topic2 = 'student/CASA0022/ucfnmz0/nano33/pressure'; // Not a wildcard topic
    const topic3 = 'student/CASA0022/ucfnmz0/nano33/altitude'; // Not a wildcard topic

    client.subscribe(topic1, MqttQos.atMostOnce);
    client.subscribe(topic2, MqttQos.atMostOnce);
    client.subscribe(topic3, MqttQos.atMostOnce);

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      _tpc.value = c[0].topic;
      _msg.value = pt;

      switch (_tpc.value) {
        case topic1:
          _temperature = double.parse(_msg.value);
          isDataCollected = true;
          break;
        case topic2:
          _pressure = double.parse(_msg.value);
          isDataCollected = true;
          break;
        case topic3:
          _altitude = double.parse(_msg.value);
          isDataCollected = true;
          break;
        default:
          break;
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
    await MqttUtilities.asyncSleep(4);

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

  Widget _indoorView() => _state == AppState.FINISHED_DOWNLOADING
      ? contentFinishedDownload()
      : _state == AppState.DOWNLOADING
      ? contentDownloading()
      : contentNotDownloaded();

  Widget contentNotDownloaded() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Text(
            'Press the button to download the MQTT',
          ),
        ],
      ),
    );
  }

  Widget contentDownloading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
            color: const Color(0xff242f35),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Indoor',
              style: TextStyle(
                  fontSize: 22,
                  color: Color(0xffffffff),
                  fontWeight: FontWeight.w700),
            ),
            const Divider(
              height: 8,
              thickness: 2,
              indent: 0,
              endIndent: 0,
              color: Color(0xffffffff),
            ),
            Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                const Text(
                  'Fetching Indoor Data...',
                  style: TextStyle(fontSize: 20, color: Color(0xffffffff)),
                ),
                Container(
                    margin: const EdgeInsets.only(top: 50),
                    child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 10))),
              ],
            ),

            // Expanded(child: _weatherIconDisplay()),
          ],
        ),
      ),
    );
  }

  Widget contentFinishedDownload() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
            color: const Color(0xff242f35),
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
                const Text(
                  'Indoor',
                  style: TextStyle(
                      fontSize: 22,
                      color: Color(0xffffffff),
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
                          color: Color(0xffffffff),
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
              color: Color(0xffffffff),
            ),
            SizedBox(
              height: 120,
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: 30,
                    child: ListTile(
                      leading: const Icon(Icons.device_thermostat_rounded, color: Color(0xffffffff),),
                      minLeadingWidth: 2,
                      title: const Text('Temperature', style: TextStyle(color: Color(0xffffffff)),),
                      selected: false,
                      trailing: Text(
                        '${_temperature.toStringAsFixed(1)}\u2103',
                        style: const TextStyle(fontSize: 18, color: Color(0xffffffff)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: ListTile(
                      leading: const Icon(Icons.cloud_circle_rounded, color: Color(0xffffffff),),
                      minLeadingWidth: 2,
                      title: const Text('Pressure', style: TextStyle(color: Color(0xffffffff)),),
                      selected: false,
                      trailing: Text(
                        '${_pressure.toStringAsFixed(1)} hPa',
                        style: const TextStyle(fontSize: 18, color: Color(0xffffffff)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: ListTile(
                      leading: const Icon(Icons.height_rounded, color: Color(0xffffffff),),
                      minLeadingWidth: 2,
                      title: const Text('Altitude', style: TextStyle(color: Color(0xffffffff)),),
                      selected: false,
                      trailing: Text(
                        '${_altitude.toStringAsFixed(0)} m',
                        style: const TextStyle(fontSize: 18, color: Color(0xffffffff)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                ],
              ),
            ),
            Text(isDataCollected ? "Iscollected" :"No Mqtt Please Check", style: TextStyle(color: Color(0xffffffff)),),

            // Expanded(child: _weatherIconDisplay()),
          ],
        ),
      ),
    );
  }
}


