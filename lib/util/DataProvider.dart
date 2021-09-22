import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:water_level_report/model/LevelData.dart';
import 'package:water_level_report/model/StationInfo.dart';
import 'package:water_level_report/model/UserSettings.dart';
import 'package:water_level_report/util/SettingsProvider.dart';
import 'package:water_level_report/util/Globals.dart' as globals;

class DataProvider {
  Future<List<StationInfo>> getStations() async {
    List<StationInfo> result = [];

    String url =
        "https://www.pegelonline.wsv.de/webservices/rest-api/v2/stations.json";

    try {
      final http.Response response = await http.get(Uri.parse(url));

      Iterable list = jsonDecode(response.body);
      result = List.from(list.map((entry) => StationInfo.fromJSON(entry)));
    } catch (_) {
      throw Exception("Could not fetch stations!");
    }

    return result;
  }

  Future<List<LevelData>> getData() async {
    List<LevelData> result = [];

    DateFormat dateFormatter = DateFormat("y-MM-ddTHH:mm:00", "en_US");
    DateTime now = DateTime.now().subtract(Duration(days: 5, minutes: 15));

    String _filepath =
        (await getApplicationDocumentsDirectory()).path + globals.SETTINGS_PATH;

    UserSettings settings = await SettingsProvider(_filepath).loadSettings();

    String queryString = "${dateFormatter.format(now)}";

    String url = "https://www.pegelonline.wsv.de/webservices/rest-api/" +
        "v2/stations/${settings.stationId}/W/measurements.json?start=$queryString";

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
