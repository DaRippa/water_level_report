import 'package:flutter/material.dart';

class SelectDaysDialog extends StatefulWidget {
  final List<bool> _days;
  final ValueChanged<List<bool>> onSelectedDaysChanged;

  SelectDaysDialog(
    List<bool> selectedDays,
    this.onSelectedDaysChanged,
  ) : this._days = List.from(selectedDays);

  @override
  State<StatefulWidget> createState() => SelectDaysDialogState();
}

class SelectDaysDialogState extends State<SelectDaysDialog> {
  late List<bool> _selection;

  void _changeSelection(bool? value, int index) {
    setState(() {
      _selection[index] = value!;
    });

    widget.onSelectedDaysChanged(_selection);
  }

  String _getDayLabel(int index) {
    return <String>[
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ][index];
  }

  @override
  Widget build(BuildContext context) {
    _selection = List.from(widget._days);

    return Scaffold(
      body: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: 7,
            itemBuilder: (builder, index) {
              return CheckboxListTile(
                title: Text(_getDayLabel(index)),
                value: _selection[index],
                activeColor: Theme.of(context).accentColor,
                onChanged: (value) => _changeSelection(value, index),
              );
            },
          ),
          Flexible(child: Container()),
          Expanded(
            flex: 0,
            child: Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 10, right: 5),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel"),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 5, right: 10),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, _selection),
                        child: Text("Ok"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
