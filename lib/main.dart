import 'package:flutter/material.dart';
import 'package:weather/currentWeather.dart';
import 'location_data.dart';

void main() {
  runApp(MyApp());
}

class UserCredentials {
  final String email;
  final String password;

  UserCredentials({required this.email, required this.password});
}

class MyApp extends StatefulWidget {
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
            builder: (context) => CurrentWeatherPage(locations, context),
          );
        }
        return null;
      },
      home: userCredentials != null
          ? CurrentWeatherPage(locations, context)
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
              onPressed: () {
                String email = emailController.text;
                String password = passwordController.text;

                if (email.isNotEmpty && password.isNotEmpty) {
                  widget.parent.setState(() {
                    widget.parent.userCredentials =
                        UserCredentials(email: email, password: password);
                  });

                  Navigator.pushReplacementNamed(context, '/currentWeather');
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
