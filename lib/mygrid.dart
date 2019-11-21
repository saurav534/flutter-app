import 'dart:async';
import 'dart:math';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:synchronized/synchronized.dart';
import 'package:vibrate/vibrate.dart';

import 'common.dart';

class MatchScore {
  int allowedTime;
  int actualTime;
  bool isCorrect;
}

class GridGameState extends State<GridGame> {
  GameConfig _gameConfig;
  var _activeGrid = [0, 0, 0, 0, 0, 0, 0, 0, 0];
  var _random = Random();
  var _misses = 0;
  var _secondElapsed = 0;
  var _paused = false;
  var _clicked = false;
  BuildContext _gameContext;
  Timer _timer;
  final _lock = new Lock();
  var scoreCounter = List();

  @override
  initState() {
    _timer = Timer.periodic(
        Duration(seconds: 1),
        _gameConfig.level == ToughnessLevel.Easy
            ? _easyLevel
            : _gameConfig.level == ToughnessLevel.Medium
                ? _mediumLevel
                : _hardLevel);

    super.initState();
  }

  _checkGameEnd() {
    if (_misses == 15) {
      setState(() {
        _paused = true;
      });

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Game Over'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Survival Time - $_secondElapsed seconds.'),
                  Text('Score recorded'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Exit'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(_gameContext);
                },
              ),
              FlatButton(
                child: Text('Restart'),
                onPressed: () {
                  setState(() {
                    _misses = 0;
                    _secondElapsed = 0;
                    _activeGrid = [0, 0, 0, 0, 0, 0, 0, 0, 0];
                    _paused = false;
                  });
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    }
  }

  _recordScore() {}

  _easyLevel(Timer t) {
    if (!_paused) {
      setState(() {
        var index = _random.nextInt(9);
        _secondElapsed++;
        _activeGrid[index] = 1;
        Timer(
            Duration(
                milliseconds: 600 - _secondElapsed > 150
                    ? 600 - _secondElapsed
                    : 150), () {
          if (mounted) {
            setState(() {
              _lock.synchronized(() {
                if (_activeGrid[index] == 1) {
                  _misses++;
                  _activeGrid[index] = 0;
                  _checkGameEnd();
                }
                _clicked = false;
              });
            });
          }
        });
      });
    }
  }

  _mediumLevel(Timer t) {
    if (!_paused) {
      setState(() {
        var indexGreen = _random.nextInt(9);
        var indexRed = _random.nextInt(9);
        _secondElapsed++;
        _activeGrid[indexRed] = 10;
        _activeGrid[indexGreen] = 1;
        Timer(
            Duration(
                milliseconds: 600 - _secondElapsed > 150
                    ? 600 - _secondElapsed
                    : 150), () {
          if (mounted) {
            setState(() {
              _lock.synchronized(() {
                if (_activeGrid[indexGreen] == 1) {
                  _misses++;
                  _activeGrid[indexGreen] = 0;
                  _checkGameEnd();
                }
                _activeGrid[indexRed] = 0;
                _clicked = false;
              });
            });
          }
        });
      });
    }
  }

  _hardLevel(Timer t) {
    if (!_paused) {
      setState(() {
        var indexGreen = _random.nextInt(9);
        var indexRed = _random.nextInt(9);
        _secondElapsed++;
        _activeGrid[indexRed] = 11;
        _activeGrid[indexGreen] = 2;
        Timer(
            Duration(
                milliseconds: 600 - _secondElapsed > 150
                    ? 600 - _secondElapsed
                    : 150), () {
          if (mounted) {
            setState(() {
              _lock.synchronized(() {
                if (_activeGrid[indexGreen] == 2) {
                  _misses++;
                  _activeGrid[indexGreen] = 0;
                  _checkGameEnd();
                }
                _activeGrid[indexRed] = 0;
                _clicked = false;
              });
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _gameContext = context;
    List<Widget> gridList = [];
    for (int i = 0; i < _activeGrid.length; i++) {
      gridList.add(Container(
          child: RaisedButton(
            color: _activeGrid[i] == 0
                ? Colors.white54
                : _activeGrid[i] == 1
                    ? Colors.green
                    : [2, 11].contains(_activeGrid[i])
                        ? [Colors.red, Colors.green][_random.nextInt(2)]
                        : Colors.red,
            child: [1, 10].contains(_activeGrid[i])
                ? Icon(Icons.adjust)
                : _activeGrid[i] == 2
                    ? Text("GREEN", style: TextStyle(color: Colors.white))
                    : _activeGrid[i] == 11
                        ? Text("RED", style: TextStyle(color: Colors.white))
                        : null,
            onPressed: () {
              if (_clicked) return;
              var x = i;
              setState(() {
                _lock.synchronized(() {
//                  _clicked = true;
                  if (_activeGrid[x] == 1 || _activeGrid[x] == 2) {
                    _activeGrid[x] = 0;
                  } else {
                    if (_gameConfig.vibration) {
                      if (Platform.isIOS) {
                        Vibrate.feedback(FeedbackType.error);
                      } else {
                        Vibrate.vibrate();
                      }
                    }
                  }
                });
              });
            },
          ),
          color: _activeGrid[i] == 0 ? Colors.grey : Colors.green));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Grid Game'),
      ),
//        backgroundColor: _missed ? Color(0xFFFFCDD2) : Colors.white,
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          LinearProgressIndicator(
            value: (_misses * 1.0) / 15.0,
            backgroundColor: Colors.white30,
            valueColor: AlwaysStoppedAnimation<Color>(_misses <= 5
                ? Colors.green
                : _misses <= 10 ? Colors.orange : Colors.red),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(left: 20.0, top: 15.0),
                      child: const Text("Missed : ",
                          style: const TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold))),
                  Padding(
                      padding: EdgeInsets.only(left: 15.0, top: 15.0),
                      child: Text("$_misses",
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: _misses < 10
                                  ? Colors.green
                                  : _misses < 20
                                      ? Colors.orange
                                      : Colors.red))),
                ],
              ),
              Row(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(right: 0.0, top: 15.0),
                      child: const Text("Time : ",
                          style: const TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold))),
                  Padding(
                      padding: EdgeInsets.only(right: 20.0, top: 15.0),
                      child: SizedBox(
                          width: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text("$_secondElapsed" + "s",
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green))
                            ],
                          )))
                ],
              )
            ],
          ),
          GridView.count(
            shrinkWrap: true,
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 3,
            children: gridList,
          ),
          Padding(
              padding: EdgeInsets.only(top: 5, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    width: 118,
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.green,
                      padding: EdgeInsets.only(left: 10, right: 4),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.refresh),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 8, right: 8, top: 10, bottom: 10),
                              child: Text('Restart',
                                  style: const TextStyle(fontSize: 18.0)))
                        ],
                      ),
                      onPressed: () {
                        if (Platform.isIOS) {
                          Vibrate.feedback(FeedbackType.warning);
                        }
                        Timer(Duration(milliseconds: 1000), () {
                          setState(() {
                            _misses = 0;
                            _secondElapsed = 0;
                            _paused = false;
                            _activeGrid = [0, 0, 0, 0, 0, 0, 0, 0, 0];
                          });
                        });
                      },
                    ),
                  ),
                  SizedBox(
                      width: 118,
                      child: RaisedButton(
                        textColor: Colors.white,
                        color: Colors.blue,
                        padding: EdgeInsets.only(left: 8, right: 4),
                        child: Row(
                          children: <Widget>[
                            Icon(_paused ? Icons.play_arrow : Icons.pause),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 8, right: 8, top: 10, bottom: 10),
                                child: Padding(
                                    padding:
                                        EdgeInsets.only(left: _paused ? 0 : 5),
                                    child: Text(_paused ? 'Resume' : 'Pause',
                                        style:
                                            const TextStyle(fontSize: 18.0))))
                          ],
                        ),
                        onPressed: () {
                          if (Platform.isIOS) {
                            Vibrate.feedback(FeedbackType.impact);
                          }
                          setState(() {
                            _paused = !_paused;
                          });
                        },
                      ))
                ],
              ))
        ],
      ),
      floatingActionButton: SpeedDial(
        // both default to 16
        marginRight: 18,
        marginBottom: 20,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        // this is ignored if animatedIcon is non null
        // child: Icon(Icons.add),
        visible: true,
        // If true user is forced to close dial manually
        // by tapping main button and overlay is not rendered.
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        tooltip: 'Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
              child: Icon(Icons.accessibility),
              backgroundColor: Colors.red,
              label: 'First',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => print('FIRST CHILD')),
          SpeedDialChild(
            child: Icon(Icons.brush),
            backgroundColor: Colors.blue,
            label: 'Second',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => print('SECOND CHILD'),
          ),
          SpeedDialChild(
            child: Icon(Icons.keyboard_voice),
            backgroundColor: Colors.green,
            label: 'Third',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => print('THIRD CHILD'),
          ),
        ],
      ),
    );
  }

  GridGameState(this._gameConfig);
}

class GridGame extends StatefulWidget {
  GameConfig _gameConfig;

  GridGame(this._gameConfig);

  @override
  State<StatefulWidget> createState() => GridGameState(_gameConfig);
}
