import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:water_level_report/model/UserSettings.dart';

class SettingsProvider {
  late final String _filepath;
  final BuildContext _context;

  SettingsProvider(this._filepath, this._context);

  Future<UserSettings> loadSettings() async {
    try {
      File settingsFile = File(_filepath);
      String content = await settingsFile.readAsString();

      return UserSettings.fromJSON(jsonDecode(content), _context);
    } catch (_) {
      return UserSettings(_context);
    }
  }

  Future<bool> saveSettings(UserSettings settings) async {
    String json = jsonEncode(settings.toMap());
    bool success = true;

    try {
      File settingsFile = File(_filepath);
      String directory = _filepath.substring(0, _filepath.lastIndexOf("/") + 1);
      Directory path = Directory(directory);

      if (!path.existsSync()) {
        await path.create(recursive: true);
      }

      await settingsFile.writeAsString(json);
    } catch (_) {
      success = false;
    }
    return success;
  }
}
