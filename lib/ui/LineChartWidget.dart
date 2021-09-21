import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:water_level_report/model/LevelData.dart';

class LineChartWidget extends StatelessWidget {
  final List<LevelData> _data;

  LineChartWidget({required List<LevelData> data}) : _data = data;

  @override
  Widget build(BuildContext context) {
    List<double> values = _data.map((elem) => elem.value).toList();
    double min =
        values.reduce((value, element) => element > value ? value : element) -
            10;
    double max =
        values.reduce((value, element) => element < value ? value : element) +
            10;

    DateFormat formatter = DateFormat("d.MM.yyyy", "de_DE");
    DateFormat timeFormatter = DateFormat("HH:mm", "de_DE");
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: _data.length.toDouble() - 1,
        minY: min,
        maxY: max,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (items) => items.map(
              (item) {
                int index = item.spotIndex;
                String result =
                    "${formatter.format(_data[index].timestamp)}\n" +
                        "${timeFormatter.format(_data[index].timestamp)}\n" +
                        "${_data[index].value.toInt()}cm";
                return LineTooltipItem(result, TextStyle());
              },
            ).toList(),
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: SideTitles(showTitles: false),
          rightTitles: SideTitles(showTitles: false),
          topTitles: SideTitles(
            showTitles: true,
            getTitles: (val) {
              int _value = val.toInt();

              return _value >= _data.length || _data[_value].timestamp.hour != 0
                  ? ""
                  : formatter.format(_data[_value].timestamp);
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            spots: List.generate(
              _data.length,
              (index) => FlSpot(index.toDouble(), _data[index].value),
            ),
            barWidth: 1,
            colors: [Theme.of(context).accentColor],
            show: true,
            belowBarData: BarAreaData(
              show: true,
              colors: [
                Theme.of(context).accentColor.withOpacity(0.3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
