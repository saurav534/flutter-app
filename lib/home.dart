import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/history.dart';
import 'package:flutter_app/mygrid.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'common.dart';

class HomeState extends State<Home> {
  ToughnessLevel _level = ToughnessLevel.Easy;
  bool _vibration = true;

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
                        if(value == ToughnessLevel.Easy) {
                          HapticFeedback.lightImpact();
                        }
                        if(value == ToughnessLevel.Medium) {
                          HapticFeedback.mediumImpact();
                        }
                        if(value == ToughnessLevel.Hard) {
                          HapticFeedback.heavyImpact();
                        }
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
                        setState(() {
                          _vibration = val;
                          if(val) {
                            HapticFeedback.vibrate();
                          }
                        });
                      },
                    )
                  ],
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
            )),
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
          tooltip: 'Speed Dial',
          heroTag: 'speed-dial-hero-tag',
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 8.0,
          shape: CircleBorder(),
          children: [
            SpeedDialChild(
              child: Icon(Icons.history),
              backgroundColor: Colors.green,
              label: 'History',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) => History()
              )),
            ),
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
          ],
        )
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}
