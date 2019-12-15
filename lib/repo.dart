import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'common.dart';

var database;

class Score {
  int id;
  int avgTime;
  double correctPercent;
  double delayedPercent;
  double wrongPercent;
  double missedPercent;
  int survivalTime;
  String gameType;
  List<SingleClick> allClick;

  Score({this.id, this.avgTime, this.correctPercent, this.delayedPercent, this.wrongPercent,
    this.missedPercent, this.survivalTime, this.gameType, this.allClick});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'avgTime': avgTime,
      'correctPercent': correctPercent,
      'delayedPercent': delayedPercent,
      'wrongPercent': wrongPercent,
      'missedPercent': missedPercent,
      'survivalTime': survivalTime,
      'gameType': gameType,
    };
  }

  Future<void> insertScore() async {
    // Get a reference to the database.
    if(database == null){
      await createDatabase();
    }
    final Database db = await database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.

    await db.insert(
      'score',
      this.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

Future<List> getAllScores() async {
  if(database == null){
    await createDatabase();
  }
  final Database db = await database;
  var result = await db.query("score");
  return result.toList();
}

createDatabase() async{
  database = openDatabase(
    join(await getDatabasesPath(), 'game_database.db'),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE score(id INTEGER PRIMARY KEY, avgTime INTEGER, correctPercent DOUBLE, delayedPercent DOUBLE, wrongPercent DOUBLE, missedPercent DOUBLE, survivalTime INTEGER, gameType STRING)",
      );
    },
    version: 1,
  );
}