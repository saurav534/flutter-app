import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/repo.dart';

import 'common.dart';

class PerGameScore extends StatelessWidget {
  PerGameScore(this.score) {
    survivalTime = score.survivalTime;
    averageResponseTime = score.avgTime;
    delayedResponsePercent = score.delayedPercent.toStringAsFixed(2);
    correctResponsePercent = score.correctPercent.toStringAsFixed(2);
    wrongResponsePercent = score.wrongPercent.toStringAsFixed(2);
    missedResponsePercent = score.missedPercent.toStringAsFixed(2);
  }

  final Score score;

  int survivalTime;
  int averageResponseTime;
  String delayedResponsePercent;
  String correctResponsePercent;
  String wrongResponsePercent;
  String missedResponsePercent;

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Score Analysis'),
        ),
        backgroundColor: Colors.white,
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 10, top: 20),
                    child: Text(
                      "Game Level :",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 5, top: 20),
                    child: Text(
                      score.gameType,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                child: ConstrainedBox(
                    constraints: BoxConstraints.expand(height: 250.0),
                    // adjust the height here
                    child: LineChart(plotScore(score.allClick),
                        swapAnimationDuration: Duration(milliseconds: 250))),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                      child: ListTile(
                          leading: Icon(
                            Icons.access_time,
                            color: Colors.black,
                            size: 35,
                          ),
                          title: Text(
                            "Survival Time",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("$survivalTime seconds"))),
                  Flexible(
                      child: ListTile(
                          leading: Icon(
                            Icons.timer,
                            color: Colors.blue,
                            size: 35,
                          ),
                          title: Text(
                            "Avg Res Time",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("$averageResponseTime ms")))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                      child: ListTile(
                          leading: Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 35,
                          ),
                          title: Text(
                            "Correct Res",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("$correctResponsePercent %"))),
                  Flexible(
                      child: ListTile(
                          leading: Icon(
                            Icons.highlight_off,
                            color: Colors.red,
                            size: 35,
                          ),
                          title: Text(
                            "Wrong Res",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("$wrongResponsePercent %")))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                      child: ListTile(
                          leading: Icon(
                            Icons.access_alarm,
                            color: Colors.orange,
                            size: 35,
                          ),
                          title: Text(
                            "Delayed Res",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("$delayedResponsePercent %"))),
                  Flexible(
                      child: ListTile(
                          leading: Icon(
                            Icons.call_missed_outgoing,
                            color: Colors.deepPurpleAccent,
                            size: 35,
                          ),
                          title: Text(
                            "Missed Res",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("$missedResponsePercent %")))
                ],
              )
            ]));
  }

  LineChartData plotScore(List<SingleClick> allClick) {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            if (touchedSpots == null) {
              return null;
            }

            List<LineTooltipItem> items = List<LineTooltipItem>();
            LineTooltipItem addLast;
            for (int i = 0; i< touchedSpots.length; i++) {
              if (touchedSpots[i] == null) {
                return null;
              }
              final TextStyle textStyle = TextStyle(
                color: touchedSpots[i].bar.colors[0],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
              if(!touchedSpots[i].bar.show) {
                addLast =
                    LineTooltipItem("Lost", textStyle);
              } else {
                items.add(
                    LineTooltipItem(touchedSpots[i].y.toString(), textStyle));
              }
            }
            if(addLast != null) {
              items.add(addLast);
            }
            return items;
          }
        ),
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(
          show: true,
          horizontalInterval: 100.0,
          drawVerticalGrid: true,
          verticalInterval: allClick.length > 70
              ? 10.0
              : allClick.length > 15 ? 5.0 : 1.0),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 2,
          textStyle: TextStyle(
            color: const Color(0xff72719b),
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
          margin: 10,
          getTitles: (value) {
            if (allClick.length > 15) {
              return value % 5 == 0 ? value.toInt().toString() : "";
            }
            return value.toInt().toString();
          },
        ),
        leftTitles: SideTitles(
            showTitles: true,
            textStyle: TextStyle(
              color: const Color(0xff75729e),
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
            margin: 8,
            reservedSize: 20,
            getTitles: (value) {
              return value % 100 == 0 ? value.toInt().toString() : "";
            }),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(
              color: Colors.black,
            ),
            left: BorderSide(
              color: Colors.black,
            ),
            right: BorderSide(
              color: Colors.black,
            ),
            top: BorderSide(
              color: Colors.black,
            ),
          )),
      minX: 1.0,
      maxX: allClick.length.toDouble(),
      maxY: 1050.0,
      minY: 100.0,
      lineBarsData: plotLines(score.allClick),
    );
  }

  List<LineChartBarData> plotLines(List<SingleClick> allClick) {
    List<FlSpot> actualTimeSpots = List<FlSpot>();
    List<FlSpot> allowedTimeSpots = List<FlSpot>();
    List<FlSpot> lossTimeSpots = List<FlSpot>();
    for (int i = 0; i < allClick.length; i++) {
      actualTimeSpots
          .add(FlSpot((i + 1).toDouble(), allClick[i].actualTime.toDouble()));
      allowedTimeSpots
          .add(FlSpot((i + 1).toDouble(), allClick[i].allowedTime.toDouble()));
      if(allClick[i].pointLost) {
        lossTimeSpots
            .add(FlSpot((i + 1).toDouble(), allClick[i].actualTime.toDouble()));
      }
    }

    LineChartBarData actualTime = LineChartBarData(
      spots: actualTimeSpots,
      isCurved: true,
      colors: [
        Colors.green,
      ],
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(
        dotSize: 2.0,
        show: true,
      ),
      belowBarData:
          BarAreaData(show: true, colors: [Colors.green.withOpacity(0.2)]),
    );

    LineChartBarData lossTime = LineChartBarData(
      spots: lossTimeSpots,
      show: false,
      dotData: FlDotData(
        dotColor: Colors.red,
        dotSize: 4.0,
        show: true,
      )
    );

    LineChartBarData allowedTime = LineChartBarData(
      spots: allowedTimeSpots,
      isCurved: true,
      colors: [
        Colors.red,
      ],
      barWidth: 1,
      isStrokeCapRound: true,
      dotData: FlDotData(
        dotSize: 2.0,
        show: true,
      ),
      aboveBarData:
          BarAreaData(show: true, colors: [Colors.red.withOpacity(0.2)]),
    );
    return [allowedTime, actualTime, lossTime];
  }
}
