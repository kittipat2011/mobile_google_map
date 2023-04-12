import 'package:flutter/material.dart';
import 'package:mobile_google_map/screen/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Map',
      theme: ThemeData(
        primarySwatch: const MaterialColor(
          0xFF0A182B,
          <int, Color>{
            50: Color(0xFFE3E9F0),
            100: Color(0xFFBAC7D6),
            200: Color(0xFF8FABBD),
            300: Color(0xFF627F9F),
            400: Color(0xFF3F5E84),
            500: Color(0xFF0A182B),
            600: Color(0xFF0A1629),
            700: Color(0xFF09121F),
            800: Color(0xFF070E17),
            900: Color(0xFF050A0F),
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
