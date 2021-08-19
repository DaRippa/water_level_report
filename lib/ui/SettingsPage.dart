import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:water_level_report/model/SelectedDaysMode.dart';
import 'package:water_level_report/model/UserSettings.dart';
import 'package:water_level_report/util/SettingsProvider.dart';

import 'SelectDaysDialog.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsPageState();
  }
}

class SettingsPageState extends State<SettingsPage> {
  late final SettingsProvider _settingsProvider;
  late final TextEditingController _levelController = TextEditingController();
  late UserSettings _settings = UserSettings(context);
  List<bool> _selectedDays = List.generate(7, (index) => false);

  void _saveAndBack() {
    _settings.level = int.tryParse(_levelController.text) ?? _settings.level;

    _settingsProvider.saveSettings(_settings).then((result) {
      SnackBar snackbar = SnackBar(
        content: Text(result ? "Success!" : "Something went wrong..."),
        duration: Duration(seconds: 2),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackbar);

      if (result) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    getApplicationDocumentsDirectory().then((result) {
      String dir = result.path + "/Water Level Report/usersettings.json";
      _settingsProvider = SettingsProvider(dir, context);

      _settingsProvider.loadSettings().then((result) {
        setState(() => _settings = result);
        _levelController.text = _settings.level.toString();
        _getSelectedDays();
      });
    });
  }

  String _getSelectedDayLabels() {
    final List<String> labels = [
      "mon",
      "tue",
      "wed",
      "thu",
      "fri",
      "sat",
      "sun"
    ];

    return _settings.days.map((day) => labels[day - 1]).join(", ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Inform me..."),
                RadioListTile<SelectedDaysMode>(
                  value: SelectedDaysMode.EVERY_DAY,
                  title: Text("every day"),
                  groupValue: _settings.mode,
                  onChanged: _modeChanged,
                ),
                RadioListTile<SelectedDaysMode>(
                  value: SelectedDaysMode.WORK_DAY,
                  title: Text("on work days"),
                  groupValue: _settings.mode,
                  onChanged: _modeChanged,
                ),
                RadioListTile<SelectedDaysMode>(
                  value: SelectedDaysMode.CUSTOM,
                  title: Text("on these days:"),
                  subtitle: Text(
                    _getSelectedDayLabels(),
                    style: TextStyle(fontSize: 11),
                  ),
                  groupValue: _settings.mode,
                  onChanged: _modeChanged,
                ),
              ]),
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  children: [
                    Text("at ${_settings.time.format(context)}"),
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
              Row(
                children: [
                  Text("if the level rises above"),
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

        // _getSelectedDays();
      },
    );
  }
}
