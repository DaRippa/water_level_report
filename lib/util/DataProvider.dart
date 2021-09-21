import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:water_level_report/model/LevelData.dart';

class DataProvider {
  Future<List<LevelData>> getData() async {
    List<LevelData> result = [];

    DateFormat dateFormatter = DateFormat("y-MM-ddTHH:mm:00", "en_US");
    DateTime now = DateTime.now().subtract(Duration(minutes: 15));

    String queryString = "${dateFormatter.format(now)}";

    String url = "https://www.pegelonline.wsv.de/webservices/rest-api/" +
        "v2/stations/502180/W/measurements.json?start=$queryString";

    try {
      final http.Response response = await http.get(Uri.parse(url));

      Iterable list = jsonDecode(response.body);
      result = List.from(list.map((entry) => LevelData.fromJSON(entry)));
    } catch (_) {
      throw Exception("Could not fetch data!");
    }

    return result;
  }
}
