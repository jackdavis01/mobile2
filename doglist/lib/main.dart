import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/listpage.dart';
import 'pages/detailspage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures that SystemChrome settings are applied
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Allow only portrait mode
  ]).then((_) {
    runApp(DogListApp());
  });
}

class DogListApp extends StatelessWidget {
  const DogListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dog List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/list',
      routes: {
        '/list': (context) => ListPage(),
        '/details': (context) => DetailsPage(),
      },
    );
  }
}
