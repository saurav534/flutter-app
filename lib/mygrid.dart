import 'dart:async';
import 'dart:math';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/repo.dart';
import 'package:flutter_app/stats.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:synchronized/synchronized.dart';
import 'package:vibration/vibration.dart';

import 'common.dart';

class GridGameState extends State<GridGame> {
  GameConfig _gameConfig;
  var _activeGrid = [0, 0, 0, 0, 0, 0, 0, 0, 0];
  var _random = Random();
  var _misses = 0;
  var _secondElapsed = 0;
  var _paused = false;
  var _clicked = false;
  Lock _lock = new Lock();
  BuildContext _gameContext;
  Timer _timer;

  int _allowedTime;
  int _actualTime;
  bool _isCorrect;
  bool _pointLost;
  int _indexGreen;
  int _greenValue;
  int _redValue;

  int _startTime;
  List<SingleClick> _allClick = List<SingleClick>();

  @override
  initState() {
    switch (_gameConfig.level) {
      case ToughnessLevel.Easy:
        _greenValue = 1;
        _redValue = 0;
        break;
      case ToughnessLevel.Medium:
        _greenValue = 1;
        _redValue = 10;
        break;
      case ToughnessLevel.Hard:
        _greenValue = 2;
        _redValue = 11;
        break;
    }
    _timer = Timer.periodic(Duration(seconds: 1), _gameTicker);
    super.initState();
  }

  _persistScore(MatchScore ms) {
    Score gameScore = getGameScore(ms);
    gameScore.insertScore();
  }

  Score getGameScore(MatchScore ms) {
    List<SingleClick> allClick = ms.allClick;
    int addedResponseTime = 0;
    int delayedCount = 0;
    int correctCount = 0;
    int wrongCount = 0;
    int missedCount = 0;
    int survivalTime = allClick.length;
    for (int i = 0; i < survivalTime; i++) {
      addedResponseTime += allClick[i].actualTime;
      if (!allClick[i].clickMissed &&
          allClick[i].actualTime > allClick[i].allowedTime) {
        delayedCount++;
      }
      if (allClick[i].clickMissed) {
        missedCount++;
      } else {
        if (allClick[i].isCorrect) {
          correctCount++;
        } else {
          wrongCount++;
        }
      }
    }
    return Score(
      survivalTime: allClick.length,
      avgTime: (addedResponseTime.toDouble() / survivalTime).round(),
      correctPercent: ((correctCount.toDouble() * 100.0) / survivalTime),
      delayedPercent: ((delayedCount.toDouble() * 100.0) / survivalTime),
      wrongPercent: ((wrongCount.toDouble() * 100.0) / survivalTime),
      missedPercent: ((missedCount.toDouble() * 100.0) / survivalTime),
      gameType: ms.gameType.toString().split(".")[1],
      allClick: ms.allClick
    );

  }

  bool _checkGameEnd() {
    if (_misses == 5) {
      _recordScore();
      _persistScore(
          MatchScore(gameType: _gameConfig.level, allClick: _allClick));
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
                    while (_allClick.length != 0) {
                      _allClick.removeLast();
                    }
                    _paused = false;
                  });
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Analysis'),
                onPressed: () {
                  setState(() {
                    _misses = 0;
                    _secondElapsed = 0;
                    _activeGrid = [0, 0, 0, 0, 0, 0, 0, 0, 0];
                  });
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PerGameScore(getGameScore(MatchScore(
                              gameType: _gameConfig.level,
                              allClick: _allClick)))));
                },
              )
            ],
          );
        },
      );
      return true;
    }
    return false;
  }

  _recordScore() {
    if (_secondElapsed > 0) {
      _allClick.add(SingleClick(
          allowedTime: _allowedTime,
          clickMissed: !_clicked,
          isCorrect: _isCorrect,
          actualTime: !_clicked ? 1000 : _actualTime,
          pointLost: _pointLost));
    }
  }

  _gameTicker(Timer t) {
    if (!_paused) {
      if(_checkGameEnd())
        return;
      _startTime = new DateTime.now().millisecondsSinceEpoch;
      _recordScore();
      setState(() {
        _clicked = false;
        _isCorrect = false;
        _pointLost = false;

        _indexGreen = _random.nextInt(9);
        var indexRed = _random.nextInt(9);

        _activeGrid[indexRed] = _redValue;
        _activeGrid[_indexGreen] = _greenValue;

        _allowedTime = 650 - _secondElapsed > 200 ? 650 - _secondElapsed : 200;
        _secondElapsed++;
        Timer(Duration(milliseconds: _allowedTime), () {
          if (mounted) {
            _lock.synchronized(() {
              setState(() {
                if (_activeGrid[_indexGreen] == _greenValue) {
                  _misses++;
                  _pointLost = true;
                  _activeGrid[_indexGreen] = 0;
                }
                _activeGrid[indexRed] = 0;
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
              if (Platform.isIOS) {
                HapticFeedback.lightImpact();
              }
              if (_clicked) return;
              var x = i;
              _lock.synchronized(() {
                setState(() {
                  _actualTime =
                      new DateTime.now().millisecondsSinceEpoch - _startTime;
                  _clicked = true;
                  _isCorrect = x == _indexGreen;
                  if (_activeGrid[x] == 1 || _activeGrid[x] == 2) {
                    _activeGrid[x] = 0;
                  } else {
                    if (_gameConfig.vibration) {
                      if (Platform.isIOS) {
                        HapticFeedback.vibrate();
                      } else {
                        Vibration.vibrate(duration: 100);
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
            value: (_misses * 1.0) / 5.0,
            backgroundColor: Colors.white30,
            valueColor: AlwaysStoppedAnimation<Color>(_misses <= 2
                ? Colors.green
                : _misses <= 3 ? Colors.orange : Colors.red),
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
                          HapticFeedback.heavyImpact();
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
                                    left: 8, right: 7, top: 10, bottom: 10),
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
                            HapticFeedback.heavyImpact();
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
