import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/mygrid.dart';

import 'common.dart';

class HomeState extends State<Home> {
  ToughnessLevel _level = ToughnessLevel.Easy;
  bool _vibration = true;

  LineChartData sampleData1() {
    return LineChartData(
      gridData: const FlGridData(
        show: true,
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          textStyle: TextStyle(
            color: const Color(0xff72719b),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          margin: 10,
          getTitles: (value) {
            switch (value.toInt()) {
              case 2:
                return 'SEPT';
              case 7:
                return 'OCT';
              case 12:
                return 'DEC';
            }
            return '';
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          textStyle: TextStyle(
            color: const Color(0xff75729e),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          margin: 8,
          reservedSize: 30,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(
              color: const Color(0xff4e4965),
              width: 4,
            ),
            left: BorderSide(
              color: Colors.transparent,
            ),
            right: BorderSide(
              color: Colors.transparent,
            ),
            top: BorderSide(
              color: Colors.transparent,
            ),
          )),
      minX: 0,
      maxX: 14,
      maxY: 4,
      minY: 0,
      lineBarsData: linesBarData1(),
    );
  }

  List<LineChartBarData> linesBarData1() {
    LineChartBarData lineChartBarData1 = const LineChartBarData(
      spots: [
        FlSpot(1, 1),
        FlSpot(3, 1.5),
        FlSpot(5, 1.4),
        FlSpot(7, 3.4),
        FlSpot(10, 2),
        FlSpot(12, 2.2),
        FlSpot(13, 1.8),
      ],
      isCurved: true,
      colors: [
        Colors.green,
      ],
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );
    return [
      lineChartBarData1
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Wecome to Grid Game"),
        ),
        body: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 0),
                      child: const Text("Reflex Level",
                          style: const TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                Column(
                    children: ToughnessLevel.values.map((ToughnessLevel tl) {
                  return ListTile(
                    contentPadding: EdgeInsets.all(0),
                    title: Text(tl.toString().split(".")[1]),
                    leading: Radio(
                      value: tl,
                      groupValue: _level,
                      onChanged: (ToughnessLevel value) {
                        setState(() {
                          _level = value;
                        });
                      },
                    ),
                  );
                }).toList()),
                Divider(color: Colors.grey),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 0, right: 20),
                      child: const Text("Vibration",
                          style: const TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold)),
                    ),
                    Switch(
                      value: _vibration,
                      onChanged: (val) {
                        _vibration = val;
                      },
                    )
                  ],
                ),
                Divider(color: Colors.grey),
                ConstrainedBox(
                  constraints: BoxConstraints.expand(height:150.0), // adjust the height here
                  child:LineChart(
                      sampleData1(),
                      swapAnimationDuration: Duration(milliseconds: 250))
                ),
                Divider(color: Colors.grey),
                Center(
                    child: RaisedButton(
                  textColor: Colors.white,
                  color: Colors.redAccent,
                  child: Text('Start'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                GridGame(GameConfig(_vibration, _level))));
                  },
                ))
              ],
            )));
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}
