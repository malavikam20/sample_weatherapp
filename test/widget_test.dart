import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather/models/location.dart';
import 'package:weather/main.dart';

void main() {
  testWidgets('MyApp widget test', (WidgetTester tester) async {
    List<Location> dummyLocations = [
      Location(
          city: 'New York', country: 'USA', lat: '40.7128', lon: '-74.0060'),
      Location(city: 'Paris', country: 'France', lat: '48.8566', lon: '2.3522'),
    ];
    await tester
        .pumpWidget(MyApp(locations: dummyLocations, key: Key('weather_app')));
    expect(find.byKey(Key('weather_app')), findsOneWidget);
  });
}
