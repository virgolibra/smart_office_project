import 'dart:developer';

import 'package:flutter/material.dart';
import 'theme/custom_theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';

enum AppState { NOT_DOWNLOADED, DOWNLOADING, FINISHED_DOWNLOADING }

class WeatherDisplay extends StatefulWidget {
  const WeatherDisplay({Key? key, required this.lat, required this.lon})
      : super(key: key);
  final double lat;
  final double lon;

  @override
  _WeatherDisplayState createState() => _WeatherDisplayState();
}

class _WeatherDisplayState extends State<WeatherDisplay> {
  String key = 'f03bed1c4ee9ac0e28a580ad73ff263d';
  late WeatherFactory ws;
  List<Weather> _data = [];
  AppState _state = AppState.NOT_DOWNLOADED;
  // double? lat, lon;

  // double? autoLat, autoLon;

  String? _weatherDescription;
  String? _areaName;
  String? _country;
  double? _humidity;
  double? _pressure;
  // late LatLng _userCurrentPosition;
  double? _temperature;
  double? _tempMin;
  double? _tempMax;
  double? _tempFeelsLike;

  int? _weatherConditionCode;
  String? _weatherIcon;

  @override
  void initState() {
    super.initState();
    ws = new WeatherFactory(key);

    queryWeather();
  }

  void queryWeather() async {
    // /// Removes keyboard
    // FocusScope.of(context).requestFocus(FocusNode());

    setState(() {
      _state = AppState.DOWNLOADING;
    });
    log("Starting Fetch weather");
    Weather weather = await ws.currentWeatherByLocation(widget.lat, widget.lon);
    // Weather weather = await ws.currentWeatherByLocation(lat!, lon!);
    setState(() {
      _data = [weather];
      _state = AppState.FINISHED_DOWNLOADING;
      _temperature = weather.temperature?.celsius;
      _tempMax = weather.tempMax?.celsius;
      _tempMin = weather.tempMin?.celsius;
      _tempFeelsLike = weather.tempFeelsLike?.celsius;
      _humidity = weather.humidity;
      _areaName = weather.areaName;
      _country = weather.country;
      _pressure = weather.pressure;
      _weatherDescription = weather.weatherDescription;
      _weatherConditionCode = weather.weatherConditionCode;
      _weatherIcon = weather.weatherIcon;
    });

    log("Weather Fetching Done!");
  }

  Widget contentFinishedDownload() {
    // return Center(
    //   child: ListView.separated(
    //     itemCount: _data.length,
    //     itemBuilder: (context, index) {
    //       return ListTile(
    //         title: Text(_data[index].toString()),
    //       );
    //     },
    //     separatorBuilder: (context, index) {
    //       return Divider();
    //     },
    //   ),
    // );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.4,
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
                  'Weather',
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
                        'based on current location',
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
            Row(
              children: [
                _weatherIconDisplay(),
                Expanded(
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '$_areaName',
                        style: const TextStyle(
                            fontSize: 22,
                            color: Color(0xffffffff),
                            fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${_temperature?.toStringAsFixed(0)}\u2103',
                        style: const TextStyle(
                            fontSize: 45,
                            color: Color(0xffffffff),
                            fontWeight: FontWeight.w300),
                      ),
                      Text(
                        '$_weatherDescription',
                        style: const TextStyle(
                            fontSize: 22,
                            color: Color(0xffffffff),
                            fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
              ],
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
                        '${_tempMin?.toStringAsFixed(0)}\u2103 - ${_tempMax?.toStringAsFixed(0)}\u2103',
                        style: const TextStyle(fontSize: 18, color: Color(0xffffffff)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: ListTile(
                      leading: const Icon(Icons.back_hand_rounded, color: Color(0xffffffff),),
                      minLeadingWidth: 2,
                      title: const Text('Feels Like', style: TextStyle(color: Color(0xffffffff)),),
                      selected: false,
                      trailing: Text(
                        '${_tempFeelsLike?.toStringAsFixed(0)}\u2103',
                        style: const TextStyle(fontSize: 18, color: Color(0xffffffff)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: ListTile(
                      leading: const Icon(Icons.water_drop_rounded, color: Color(0xffffffff),),
                      minLeadingWidth: 2,
                      title: const Text('Humidity', style: TextStyle(color: Color(0xffffffff)),),
                      selected: false,
                      trailing: Text(
                        '$_humidity%',
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
                        '$_pressure hPa',
                        style: const TextStyle(fontSize: 18, color: Color(0xffffffff)),
                      ),
                    ),
                  ),
                ],
              ),
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
        height: MediaQuery.of(context).size.height * 0.4,
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
              'Weather',
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
                  'Fetching Weather...',
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

  Widget contentNotDownloaded() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Text(
            'Press the button to download the Weather forecast',
          ),
        ],
      ),
    );
  }

  Widget _weatherView() => _state == AppState.FINISHED_DOWNLOADING
      ? contentFinishedDownload()
      : _state == AppState.DOWNLOADING
          ? contentDownloading()
          : contentNotDownloaded();

  Widget weatherIconNull() {
    return Container(
        margin: EdgeInsets.only(top: 10),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 5)));
  }

  Widget weatherIconNotNull() {
    return SizedBox(
      height: 120,
      width: 120,
      child: Image(
          image: NetworkImage(
              'http://openweathermap.org/img/wn/$_weatherIcon@4x.png')),
    );
  }

  Widget _weatherIconDisplay() =>
      _weatherIcon == null ? weatherIconNull() : weatherIconNotNull();

  @override
  Widget build(BuildContext context) {
    return _weatherView();
  }
}
