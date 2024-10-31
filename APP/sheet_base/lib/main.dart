import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Make sure to add this package in your pubspec.yaml

// Import the home page
import 'package:sheet_base/Pages/HomePage.dart'; // Make sure this file is in the same directory or adjust the path accordingly.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pirate List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: MyHomePage(), // Navigate to the home page
    );
  }
}
