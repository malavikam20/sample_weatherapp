import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/location.dart';
import 'models/weather.dart';
import 'extensions.dart';
import 'package:intl/intl.dart';

class CurrentWeatherPage extends StatefulWidget {
  final List<Location> locations;
  final String email;
  final String password;

  const CurrentWeatherPage({
    required this.locations,
    required this.email,
    required this.password,
  });

  @override
  _CurrentWeatherPageState createState() => _CurrentWeatherPageState();
}

class _CurrentWeatherPageState extends State<CurrentWeatherPage> {
  late Location location;
  late Weather? weather;

  void _changeLocation(Location newLocation) {
    setState(() {
      location = newLocation;
    });
  }

  @override
  void initState() {
    super.initState();
    location = widget.locations[0];
    _fetchCurrentWeather();
  }

//This method makes an HTTP POST request to the login API to authenticate and then fetches the current weather data.
  Future<void> _fetchCurrentWeather() async {
    int maxRetries = 3;
    int retry = 0;

    while (retry < maxRetries) {
      final response = await http.post(
        Uri.parse('https://api.appmastery.co/api/v1/apps/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': widget.email,
          'password': widget.password,
        }),
      );

      if (response.statusCode == 200) {
        // Login successful, fetch weather data
        final jsonResponse = jsonDecode(response.body);
        // Assuming your API response structure, modify accordingly
        weather = Weather.fromJson(jsonResponse['weather']);
        break; // Break the loop if successful
      } else if (response.statusCode == 429) {
        // Too many requests, wait before retrying
        await Future.delayed(Duration(seconds: 5 * (retry + 1)));
        retry++;
      } else {
        // Handle other errors
        print('Login failed with status code ${response.statusCode}');
        break;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ListView(
        children: <Widget>[
          currentWeatherViews(),
        ],
      ),
    );
  }

  Widget currentWeatherViews() {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Text("Error getting weather");
        } else {
          Weather _weather = snapshot.data as Weather;
          return Column(
            children: [
              createAppBar(widget.locations, location, context),
              weatherBox(_weather),
              weatherDetailsBox(_weather),
            ],
          );
        }
      },
      future: Future.value(weather), // Use the weather fetched during login
    );
  }

  Widget createAppBar(
      List<Location> locations, Location location, BuildContext context) {
    // Location dropdownValue = locations.first;
    return Container(
        padding:
            const EdgeInsets.only(left: 20, top: 15, bottom: 15, right: 20),
        margin: const EdgeInsets.only(
            top: 35, left: 15.0, bottom: 15.0, right: 15.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(60)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              )
            ]),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<Location>(
              value: location,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.black,
                size: 24.0,
                semanticLabel: 'Tap to change location',
              ),
              elevation: 16,
              underline: Container(
                height: 0,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (Location? newLocation) {
                _changeLocation(newLocation!);
              },
              items:
                  locations.map<DropdownMenuItem<Location>>((Location value) {
                return DropdownMenuItem<Location>(
                  value: value,
                  child: Text.rich(
                    TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                            text: '${value.city.capitalizeFirstOfEach}, ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        TextSpan(
                            text: '${value.country.capitalizeFirstOfEach}',
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 16)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ));
  }

  Widget weatherDetailsBox(Weather _weather) {
    return Container(
      padding: const EdgeInsets.only(left: 15, top: 25, bottom: 25, right: 15),
      margin: const EdgeInsets.only(left: 15, top: 5, bottom: 15, right: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            )
          ]),
      child: Row(
        children: [
          Expanded(
              child: Column(
            children: [
              Container(
                  child: Text(
                "Wind",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.grey),
              )),
              Container(
                  child: Text(
                "${_weather.wind} km/h",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.black),
              ))
            ],
          )),
          Expanded(
              child: Column(
            children: [
              Container(
                  child: Text(
                "Humidity",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.grey),
              )),
              Container(
                  child: Text(
                "${_weather.humidity.toInt()}%",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.black),
              ))
            ],
          )),
          Expanded(
              child: Column(
            children: [
              Container(
                  child: Text(
                "Pressure",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.grey),
              )),
              Container(
                  child: Text(
                "${_weather.pressure} hPa",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.black),
              ))
            ],
          ))
        ],
      ),
    );
  }

  Widget weatherBox(Weather _weather) {
    return Stack(children: [
      Container(
        padding: const EdgeInsets.all(15.0),
        margin: const EdgeInsets.all(15.0),
        height: 160.0,
        decoration: BoxDecoration(
            color: Colors.indigoAccent,
            borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
      ClipPath(
          clipper: Clipper(),
          child: Container(
              padding: const EdgeInsets.all(15.0),
              margin: const EdgeInsets.all(15.0),
              height: 160.0,
              decoration: BoxDecoration(
                  color: Colors.indigoAccent[400],
                  borderRadius: BorderRadius.all(Radius.circular(20))))),
      Container(
          padding: const EdgeInsets.all(15.0),
          margin: const EdgeInsets.all(15.0),
          height: 160.0,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Row(
            children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                    getWeatherIcon(_weather.icon),
                    Container(
                        margin: const EdgeInsets.all(5.0),
                        child: Text(
                          "${_weather.description.capitalizeFirstOfEach}",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              color: Colors.white),
                        )),
                    Container(
                        margin: const EdgeInsets.all(5.0),
                        child: Text(
                          "H:${_weather.high.toInt()}° L:${_weather.low.toInt()}°",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 13,
                              color: Colors.white),
                        )),
                  ])),
              Column(children: <Widget>[
                Container(
                    child: Text(
                  "${_weather.temp.toInt()}°",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 60,
                      color: Colors.white),
                )),
                Container(
                    margin: const EdgeInsets.all(0),
                    child: Text(
                      "Feels like ${_weather.feelsLike.toInt()}°",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                          color: Colors.white),
                    )),
              ])
            ],
          ))
    ]);
  }

  Image getWeatherIcon(String _icon) {
    String path = 'assets/icons/';
    String imageExtension = ".png";
    return Image.asset(
      path + _icon + imageExtension,
      width: 70,
      height: 70,
    );
  }

  Image getWeatherIconSmall(String _icon) {
    String path = 'assets/icons/';
    String imageExtension = ".png";
    return Image.asset(
      path + _icon + imageExtension,
      width: 40,
      height: 40,
    );
  }

  String getTimeFromTimestamp(int timestamp) {
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var formatter = new DateFormat('h:mm a');
    return formatter.format(date);
  }

  String getDateFromTimestamp(int timestamp) {
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var formatter = new DateFormat('E');
    return formatter.format(date);
  }

  String getDayFromTimestamp(int timestamp) {
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var formatter = new DateFormat('d');
    return formatter.format(date);
  }
}

class Clipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height - 20);

    path.quadraticBezierTo((size.width / 6) * 1, (size.height / 2) + 15,
        (size.width / 3) * 1, size.height - 30);
    path.quadraticBezierTo((size.width / 2) * 1, (size.height + 0),
        (size.width / 3) * 2, (size.height / 4) * 3);
    path.quadraticBezierTo((size.width / 6) * 5, (size.height / 2) - 20,
        size.width, size.height - 60);

    path.lineTo(size.width, size.height - 60);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(Clipper oldClipper) => false;
}

//This function makes an HTTP GET request to an OpenWeatherMap API to fetch the current weather based on the provided location.
Future<Weather?> getCurrentWeather(Location location) async {
  Weather? weather;

  String city = location.city;
  String apiKey = "fbb3ba27b78b905ec48a1e1354370b1e";

  var url = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
    'q': city,
    'appid': apiKey,
    'units': 'metric',
  });

  final response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(response.body);
    // Check if the response contains an error message
    if (jsonResponse['cod'] != null && jsonResponse['cod'] == '404') {
      print('City not found');
      return null;
    }
    // Parse the weather data
    weather = Weather.fromJson(jsonResponse);
  } else {
    // Handle the error, e.g., throw an exception or return null.
    print('Failed to fetch current weather: ${response.statusCode}');
    return null;
  }

  return weather;
}
