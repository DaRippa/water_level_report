import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:water_level_report/model/LevelData.dart';
import 'package:water_level_report/ui/SettingsPage.dart';
import 'package:water_level_report/ui/VerticalDragUpdater.dart';
import 'package:water_level_report/util/DataProvider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State {
  final Color headlineColor = Color(0xFF05B8FF);
  @override
  void initState() {
    super.initState();
  }

  Future<List<LevelData>> _queryData() async {
    DataProvider provider = DataProvider();

    return provider.getData();
  }

  Widget getDisplayWidget() {
    DateFormat formatter = DateFormat("dd.MM.y, HH:mm", "de_DE");
    TextStyle headlineStyle = TextStyle(
      color: headlineColor,
      fontWeight: FontWeight.bold,
      fontSize: 40,
    );

    return FutureBuilder(
      future: _queryData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: Platform.isIOS
                ? CupertinoActivityIndicator()
                : CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: EdgeInsets.only(top: 10, left: 10),
            child: ListView(
              children: [
                Text(
                  AppLocalizations.of(context)!.error,
                  style: headlineStyle,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 30),
                  child: Text(
                    snapshot.error.toString(),
                  ),
                ),
              ],
            ),
          );
        }

        List data = snapshot.data as List;
        int index = data.length - 1;

        LevelData leveldata = data[index];

        return ListView(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: Text(
                AppLocalizations.of(context)!.level + ":",
                style: headlineStyle,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20, left: 40, bottom: 50),
              child: Text(
                "${leveldata.value.toInt()}cm",
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                AppLocalizations.of(context)!.date + ":",
                style: headlineStyle,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20, left: 40),
              child: Text("${formatter.format(leveldata.timestamp.toLocal())}"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.appTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (builder) => SettingsPage()));
        },
        child: Icon(Icons.edit),
      ),
      body: Container(
        color: Colors.transparent,
        child: VerticalDragUpdater(
          content: getDisplayWidget(),
          onUpdate: () {
            setState(() {});
          },
        ),
      ),
    );
  }
}
