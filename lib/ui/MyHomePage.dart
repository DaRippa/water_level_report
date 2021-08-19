import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:water_level_report/model/LevelData.dart';
import 'package:water_level_report/ui/SettingsPage.dart';
import 'package:water_level_report/util/DataProvider.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State {
  List<LevelData> _data = [];

  final Color headlineColor = Color(0x66FF00FF);

  @override
  void initState() {
    super.initState();

    _queryData();
  }

  void _queryData() async {
    setState(() {
      _data.clear();
    });

    DataProvider provider = DataProvider();

    provider
        .getData()
        .then((result) => setState(() => _data = result))
        .catchError(
      (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  Widget getDisplayWidget() {
    if (_data.length == 0)
      return Center(
        child: Platform.isIOS
            ? CupertinoActivityIndicator()
            : CircularProgressIndicator(),
      );

    DateFormat formatter = DateFormat("dd.MM.y, HH:mm", "de_DE");

    LevelData data = _data[_data.length - 1];
    TextStyle headlineStyle = TextStyle(
      color: headlineColor,
      fontWeight: FontWeight.bold,
      fontSize: 40,
    );

    return Padding(
      padding: EdgeInsets.only(left: 10, top: 10),
      child: ListView(
        children: [
          Text(
            "Current water level:",
            style: headlineStyle,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20, left: 30, bottom: 50),
            child: Text(
              "${data.value.toInt()}cm",
            ),
          ),
          Text(
            "Date:",
            style: headlineStyle,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20, left: 30),
            child: Text("${formatter.format(data.timestamp.toLocal())}"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Water level report")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (builder) => SettingsPage()));
        },
        child: Icon(Icons.edit),
      ),
      body: Container(
        color: Colors.transparent,
        child: GestureDetector(
          onDoubleTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(milliseconds: 500),
                content: Text("double tap!"),
              ),
            );
            _queryData();
          },
          child: getDisplayWidget(),
        ),
      ),
    );
  }
}
