import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:water_level_report/business/NotificationManager.dart';
import 'package:water_level_report/model/LevelData.dart';
import 'package:water_level_report/model/SelectedDaysMode.dart';
import 'package:water_level_report/model/StationInfo.dart';
import 'package:water_level_report/model/UserSettings.dart';
import 'package:water_level_report/util/DataProvider.dart';
import 'package:water_level_report/util/Globals.dart' as globals;
import 'package:water_level_report/util/SettingsProvider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:workmanager/workmanager.dart';

import 'SelectDaysDialog.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsPageState();
  }
}

void callbackDispatcher() {
  Workmanager().executeTask(
    (task, inputData) async {
      Directory appDir = await getApplicationDocumentsDirectory();
      String settingsPath = appDir.path + globals.SETTINGS_PATH;
      UserSettings _settings =
          await SettingsProvider(settingsPath).loadSettings();

      if (!_settings.days.contains(DateTime.now().weekday)) {
        return true;
      }

      DataProvider provider = DataProvider();
      List<LevelData> data = await provider.getData();
      if (data.isEmpty) return false;

      if (data[0].value >= _settings.level) {
        NotificationManager _manager = NotificationManager();
        await _manager.sendNotification(
            id: 1, message: "Current level is ${data[0].value.toInt()}cm.");
      }

      return true;
    },
  );
}

class SettingsPageState extends State<SettingsPage> {
  late final SettingsProvider _settingsProvider;
  late final TextEditingController _levelController = TextEditingController();
  late UserSettings _settings = UserSettings();
  List<bool> _selectedDays = List.generate(7, (index) => false);
  List<StationInfo> _stations = [];

  Future<void> _startBackgroundTask() async {
    DateTime now = DateTime.now();
    DateTime target = DateTime(now.year, now.month, now.day,
        _settings.time.hour, _settings.time.minute, 0);

    if (now.millisecondsSinceEpoch > target.millisecondsSinceEpoch) {
      target = target.add(Duration(days: 1));
    }

    Duration delay = target.difference(now);

    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(globals.BGTASK_NAME, "checkLevel",
        frequency: Duration(days: 1),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        initialDelay: delay);
  }

  void _saveAndBack() {
    _settings.level = int.tryParse(_levelController.text) ?? _settings.level;

    _settingsProvider.saveSettings(_settings, context).then((result) {
      SnackBar snackbar = SnackBar(
        content: Text(result
            ? AppLocalizations.of(context)!.success
            : AppLocalizations.of(context)!.failure),
        duration: Duration(seconds: 2),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackbar);

      if (result) {
        if (Platform.isAndroid ||
            Platform.isIOS ||
            Platform.isLinux ||
            Platform.isMacOS) {
          _startBackgroundTask();
        }
        Navigator.pop(context);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    getApplicationDocumentsDirectory().then(
      (result) {
        String dir = result.path + globals.SETTINGS_PATH;
        _settingsProvider = SettingsProvider(dir);

        _settingsProvider.loadSettings().then(
          (result) {
            setState(() => _settings = result);
            _levelController.text = _settings.level.toString();
            _getSelectedDays();
          },
        );
      },
    );
  }

  String _getSelectedDayLabels() {
    final List<String> labels = [
      AppLocalizations.of(context)!.monShort,
      AppLocalizations.of(context)!.tueShort,
      AppLocalizations.of(context)!.wedShort,
      AppLocalizations.of(context)!.thuShort,
      AppLocalizations.of(context)!.friShort,
      AppLocalizations.of(context)!.satShort,
      AppLocalizations.of(context)!.sunShort
    ];

    return _settings.days.map((day) => labels[day - 1]).join(", ");
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> modes = [
      {
        "mode": SelectedDaysMode.EVERY_DAY,
        "title": Text(AppLocalizations.of(context)!.everyDay),
        "subtitle": null,
      },
      {
        "mode": SelectedDaysMode.WORK_DAY,
        "title": Text(AppLocalizations.of(context)!.workDays),
        "subtitle": null,
      },
      {
        "mode": SelectedDaysMode.CUSTOM,
        "title": Text("${AppLocalizations.of(context)!.selectedDays}:"),
        "subtitle": Text(
          _getSelectedDayLabels(),
          style: TextStyle(fontSize: 11),
        ),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("${AppLocalizations.of(context)!.inform} ..."),
                  Switch(
                      value: _settings.isActive,
                      activeColor: Theme.of(context).accentColor,
                      onChanged: (isActive) {
                        setState(() {
                          _settings.isActive = isActive;
                        });
                      })
                ],
              ),
              Visibility(
                visible: _settings.isActive,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: modes.length,
                      itemBuilder: (builder, index) {
                        return RadioListTile<SelectedDaysMode>(
                          value: modes[index]["mode"],
                          title: modes[index]["title"],
                          subtitle: modes[index]["subtitle"],
                          groupValue: _settings.mode,
                          onChanged: _modeChanged,
                          activeColor: Theme.of(context).accentColor,
                        );
                      },
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: Row(
                        children: [
                          Text("${AppLocalizations.of(context)!.at}" +
                              " ${_settings.time.format(context)}"),
                          Flexible(
                            child: Container(),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 20,
                              right: 20,
                            ),
                            child: ElevatedButton(
                              onPressed: () => showTimePicker(
                                context: context,
                                initialTime: _settings.time,
                              ).then((time) {
                                if (time != null)
                                  setState(() {
                                    _settings.time = time;
                                  });
                              }),
                              child: Icon(Icons.edit),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(AppLocalizations.of(context)!.threshold),
                    Container(
                      margin: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: FutureBuilder(
                        future: DataProvider()
                            .getStations()
                            .then((result) => _stations = result),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return DropdownButton(
                              isDense: false,
                              items: _stations
                                  .map(
                                    (station) => DropdownMenuItem(
                                      child: Text(
                                          "${station.water}:\n\t${station.name}"),
                                      value: station.id,
                                    ),
                                  )
                                  .toList(),
                              onChanged: (item) {
                                setState(
                                  () {
                                    StationInfo station = _stations.firstWhere(
                                        (element) => element.id == item);
                                    _settings.stationId = item.toString();
                                    _settings.stationName = station.name;
                                  },
                                );
                              },
                              value: _settings.stationId,
                            );
                          }
                          return DropdownButton(
                              isDense: true,
                              items: [
                                DropdownMenuItem(
                                    child: Text(_settings.stationName),
                                    value: _settings.stationId),
                              ],
                              value: _settings.stationId);
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Text("${AppLocalizations.of(context)!.above}"),
                        Container(
                          margin: EdgeInsets.only(
                            left: 10,
                            right: 2,
                          ),
                          width: 50.0,
                          child: TextField(
                            textAlign: TextAlign.right,
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            decoration: InputDecoration(
                              counterText: "",
                              contentPadding: EdgeInsets.only(bottom: 4),
                              isDense: true,
                              filled: false,
                            ),
                            controller: _levelController,
                          ),
                        ),
                        Text("cm."),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveAndBack,
        child: Icon(Icons.save),
      ),
    );
  }

  void _modeChanged(SelectedDaysMode? value) {
    setState(() {
      _settings.mode = value ?? SelectedDaysMode.WORK_DAY;
      switch (_settings.mode) {
        case SelectedDaysMode.EVERY_DAY:
          _settings.days = List<int>.generate(7, (index) => index + 1);
          break;
        case SelectedDaysMode.CUSTOM:
          _showSelectDaysDialog();

          break;
        case SelectedDaysMode.WORK_DAY:
        default:
          _settings.days = List<int>.generate(5, (index) => index + 1);
          break;
      }
    });
    _getSelectedDays();
  }

  void _getSelectedDays() {
    setState(
      () {
        for (int i = 0; i < _selectedDays.length; ++i) {
          _selectedDays[i] = _settings.days.contains(i + 1);
        }
      },
    );
  }

  void _showSelectDaysDialog() {
    showDialog(
      context: context,
      builder: (builder) => StatefulBuilder(
        builder: (context, setState) => SelectDaysDialog(_selectedDays, (days) {
          setState(() => _selectedDays = days);
        }),
      ),
    ).then(
      (value) {
        if (value != null) {
          List<int> temp = [];
          for (int i = 0; i < value.length; ++i) {
            if (value[i]) {
              temp.add(i + 1);
            }
          }

          setState(() => _settings.days = temp);
        } else {
          setState(() => _settings.days = _settings.days);
        }
      },
    );
  }
}
