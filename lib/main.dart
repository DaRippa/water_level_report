import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:water_level_report/ui/MyHomePage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''),
        Locale('de', ''),
      ],
      //title: 'Water level report',
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.blueAccent,
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}
