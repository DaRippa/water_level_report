class StationInfo {
  String id = "";
  String name = "";
  String water = "";

  StationInfo.fromJSON(Map<String, dynamic> o)
      : id = o["number"],
        name = o["longname"],
        water = o["water"]["longname"];
}
