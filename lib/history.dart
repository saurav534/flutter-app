import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/repo.dart';

import 'common.dart';

class HistoryState extends State<History> {
  @override
  initState() {
    var allScores = getAllScores();
    typeScoresMap = Map();
    typeScoresMap = {
      getLevelValue(ToughnessLevel.Easy): [],
      getLevelValue(ToughnessLevel.Medium): [],
      getLevelValue(ToughnessLevel.Hard): []
    };
    allScores.then((scoreList) {
      setState(() {
        totalGameCount = scoreList.length;
        scoreList.forEach((m) {
          typeScoresMap[m["gameType"]].add(m);
        });
        loading = false;
      });
    });
    super.initState();
  }

  bool loading = true;
  int totalGameCount;
  int highestSurvival;
  Map<String, List<Map<String, dynamic>>> typeScoresMap;

  String selectedLevel = getLevelValue(ToughnessLevel.Easy);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Score History'),
        ),
        backgroundColor: Colors.white,
        body: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 10, top: 20),
                          child: Text(
                            "Game Played :",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5, top: 20),
                          child: Text(
                            totalGameCount.toString(),
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 15),
                    ),
                    Container(
                        height: 400,
                        child: typeScoresMap[selectedLevel].length > 2
                            ? CarouselSlider(
                                autoPlay: true,
                                pauseAutoPlayOnTouch: Duration(seconds: 10),
                                autoPlayInterval: Duration(milliseconds: 1500),
                                viewportFraction: 1.0,
                                height: 400.0,
                                items: [0, 1, 2, 3, 4, 5].map((i) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(),
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                  right: 5, left: 5),
                                              child: getSwiperWidget(
                                                  i,
                                                  typeScoresMap[
                                                      selectedLevel])));
                                    },
                                  );
                                }).toList(),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Padding(
                                        child: Icon(Icons.insert_chart,
                                            size: 75, color: Colors.blue[500]),
                                        padding: EdgeInsets.all(20)),
                                    Text(
                                      "Not Enough History",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ]))
                  ]));
  }
}

class History extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HistoryState();
}

Widget getSwiperWidget(int index, List<Map<String, dynamic>> scores) {
  LineChartData data;
  String key;
  String displayName;
  double maxY = 0.0;
  double horizontalInterval = 100.0;
  int leftTileSkip = 100;
  FlGridData gridData;
  Color belowBarColor = Colors.green;
  bool dontChangeMaxY = true;

  List<double> values = List();

  switch (index) {
    case 0:
      {
        key = "survivalTime";
        displayName = "Survival Time (sec)";
        horizontalInterval = 3.0;
        leftTileSkip = 3;
        belowBarColor = Colors.blue;
        dontChangeMaxY = false;
        break;
      }
    case 1:
      {
        key = "avgTime";
        displayName = "Average Time (mil sec)";
        maxY = 1000.0;
        belowBarColor = Colors.amber;
        break;
      }
    case 2:
      {
        key = "correctPercent";
        displayName = "Correct Hits (percent)";
        horizontalInterval = 10.0;
        leftTileSkip = 10;
        maxY = 100.0;
        break;
      }
    case 3:
      {
        key = "wrongPercent";
        displayName = "Wrong Hits (percent)";
        horizontalInterval = 10.0;
        leftTileSkip = 10;
        belowBarColor = Colors.red;
        maxY = 100.0;
        break;
      }
    case 4:
      {
        key = "delayedPercent";
        displayName = "Delayed Hits (percent)";
        horizontalInterval = 10.0;
        leftTileSkip = 10;
        belowBarColor = Colors.deepPurple;
        maxY = 100.0;
        break;
      }
    case 5:
      {
        key = "missedPercent";
        displayName = "Missed Hits (percent)";
        horizontalInterval = 10.0;
        leftTileSkip = 10;
        belowBarColor = Colors.pink;
        maxY = 100.0;
        break;
      }
  }

  scores.forEach((elem) {
    double val = double.parse(elem[key].toString());
    values.add(val);
    maxY = val > maxY ? val : maxY;
  });

  if (!dontChangeMaxY) maxY = maxY + maxY * 0.1;

  return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Center(
        child: Padding(
      child: Text(
        displayName,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 16, color: belowBarColor),
      ),
      padding: EdgeInsets.only(bottom: 10, top: 8),
    )),
    Padding(child: LineChart(plotScore(
        values, maxY, horizontalInterval, leftTileSkip, belowBarColor)),
      padding: EdgeInsets.only(right: 8),
    )

  ]);
}

LineChartData plotScore(List<double> values, double maxY, horizontalInterval,
    leftTileSkip, belowBarColor) {
  return LineChartData(
    lineTouchData: LineTouchData(
        touchTooltipData:
            LineTouchTooltipData(tooltipBgColor: belowBarColor[50])),
    gridData: FlGridData(
        show: true,
        horizontalInterval: horizontalInterval,
        drawVerticalGrid: true,
        verticalInterval:
            values.length > 70 ? 10.0 : values.length > 15 ? 5.0 : 1.0),
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
          if (values.length > 15) {
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
            return value % leftTileSkip == 0 ? value.toInt().toString() : "";
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
    maxX: values.length.toDouble(),
    minY: 0.0,
    maxY: maxY,
    lineBarsData: plotLines(values, belowBarColor),
  );
}

List<LineChartBarData> plotLines(List<double> values, Color belowBarColor) {
  List<FlSpot> spotValues = List<FlSpot>();

  for (int i = 0; i < values.length; i++) {
    spotValues.add(
        FlSpot((i + 1).toDouble(), double.parse(values[i].toStringAsFixed(2))));
  }

  LineChartBarData valueBar = LineChartBarData(
    spots: spotValues,
    isCurved: true,
    colors: [
      belowBarColor,
    ],
    barWidth: 2,
    isStrokeCapRound: true,
    dotData: FlDotData(
      dotSize: 2.0,
      show: true,
    ),
    belowBarData:
        BarAreaData(show: true, colors: [belowBarColor.withOpacity(0.2)]),
  );
  return [valueBar];
}

String getLevelValue(ToughnessLevel tl) {
  return tl.toString().split(".")[1];
}
