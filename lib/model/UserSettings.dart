import 'package:flutter/material.dart';
import 'package:water_level_report/model/SelectedDaysMode.dart';

class UserSettings {
  int level = 325;
  SelectedDaysMode mode = SelectedDaysMode.WORK_DAY;
  BuildContext _context;

  List<int> days = [
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday
  ];
  TimeOfDay time = TimeOfDay(hour: 6, minute: 0);

  UserSettings(this._context);

  UserSettings.fromJSON(Map<String, dynamic> data, this._context)
      : this.level = data["threshold"],
        this.days = List.from(data["days"]),
        this.mode = SelectedDaysMode.values[data["mode"]] {
    this.time = _parseTimeOfDay(data["time"]);
  }

  TimeOfDay _parseTimeOfDay(String value) {
    List<String> chunks = value.split(":");
    if (chunks.length < 2) {
      throw FormatException("Invalid TimeOfDay format");
    }

    return TimeOfDay(hour: int.parse(chunks[0]), minute: int.parse(chunks[1]));
  }

  Map<String, dynamic> toMap() => {
        "threshold": level,
        "days": days.toList(),
        "time": time.format(_context),
        "mode": mode.index,
      };
}
