import 'package:flutter/material.dart';
import 'package:flutter_app/home.dart';
import 'package:flutter_app/mygrid.dart';
import 'package:flutter_app/mywidgets.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to app',
      theme: ThemeData(
        primaryColor: Colors.black
      ),
      home: Home()
    );
  }
}

