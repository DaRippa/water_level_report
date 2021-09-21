class LevelData {
  DateTime timestamp;
  double value;

  LevelData.fromJSON(Map<String, dynamic> o)
      : timestamp = DateTime.parse(o["timestamp"]),
        value = o["value"];

  Map<String, dynamic> toMap() => {"timestamp": timestamp, "value": value};
}
