import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather/currentWeather.dart';
import 'location_data.dart';
import 'models/location.dart';

void main() {
  runApp(MyApp(
    key: Key('weather_app'),
    locations: locations,
  ));
}

class UserCredentials {
  final String email;
  final String password;

  UserCredentials({required this.email, required this.password});
}

class MyApp extends StatefulWidget {
  final List<Location> locations; // Add this line

  MyApp({required this.locations, required Key key}); // Add this line

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UserCredentials? userCredentials;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/currentWeather') {
          return MaterialPageRoute(
            builder: (context) => CurrentWeatherPage(
              locations: widget.locations,
              email: userCredentials!.email,
              password: userCredentials!.password,
            ),
          );
        }
        return null;
      },
      home: userCredentials != null
          ? CurrentWeatherPage(
              locations: locations,
              email: userCredentials!.email,
              password: userCredentials!.password,
            )
          : LoginPage(this),
    );
  }
}

class LoginPage extends StatefulWidget {
  final _MyAppState parent;

  LoginPage(this.parent);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                String email = emailController.text;
                String password = passwordController.text;

                if (email.isNotEmpty && password.isNotEmpty) {
                  // Make the API request
                  final success = await _makeApiRequest(email, password);

                  if (success) {
                    widget.parent.setState(() {
                      widget.parent.userCredentials =
                          UserCredentials(email: email, password: password);
                    });

                    Navigator.pushReplacementNamed(context, '/currentWeather');
                  } else {
                    // Handle login failure (e.g., show an error message)
                    print('Login failed');
                  }
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _makeApiRequest(String email, String password) async {
    final String apiUrl = 'https://api.appmastery.co/api/v1/apps/login';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'CUSTOMERID': '5e72a0c611394600192020e0',
    };

    final Map<String, String> body = {
      'email': email,
      'password': password,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Request was successful
        print('API Response: ${response.body}');

        // Check if the credentials match the allowed values
        if (email == 'sindhya@appmastery.co' && password == '123456') {
          return true;
        } else {
          print('Invalid credentials');
          return false;
        }
      } else {
        // Request failed
        print('API Request failed with status code ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      // An error occurred
      print('Error making API request: $e');
      return false;
    }
  }
}
