import 'package:flutter/material.dart';
import 'package:water_level_report/model/SelectedDaysMode.dart';

class UserSettings {
  int level = 325;
  SelectedDaysMode mode = SelectedDaysMode.WORK_DAY;
  bool isActive = true;
  String stationId = "502180";
  String stationName = "MAGDEBURG-STROMBRÜCKE";

  List<int> days = [
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday
  ];
  TimeOfDay time = TimeOfDay(hour: 6, minute: 0);

  UserSettings();

  UserSettings.fromJSON(Map<String, dynamic> data)
      : this.level = data["threshold"],
        this.days = List.from(data["days"]),
        this.mode = SelectedDaysMode.values[data["mode"]],
        this.isActive = data["active"],
        this.stationId = data["stationid"],
        this.stationName = data["stationname"] {
    this.time = _parseTimeOfDay(data["time"]);
  }

  TimeOfDay _parseTimeOfDay(String value) {
    List<String> chunks = value.split(":");
    if (chunks.length < 2) {
      throw FormatException("Invalid TimeOfDay format");
    }

    return TimeOfDay(hour: int.parse(chunks[0]), minute: int.parse(chunks[1]));
  }

  Map<String, dynamic> toMap(_context) => {
        "threshold": level,
        "days": days.toList(),
        "time": time.format(_context),
        "mode": mode.index,
        "active": isActive,
        "stationid": stationId,
        "stationname": stationName
      };
}
