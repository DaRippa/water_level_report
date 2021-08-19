import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:water_level_report/ui/MyHomePage.dart';

void main() {
  initializeDateFormatting("de_DE");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water level report',
      theme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.blueAccent,
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}
