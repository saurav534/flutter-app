import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

var database;

class Score {
  int id;
  int avgTime;
  int correct;
  int delayed;
  int wrong;
  int survivalTime;

  Score(this.id, this.avgTime, this.correct, this.delayed, this.wrong,
      this.survivalTime);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'avgTime': avgTime,
      'correct': correct,
      'delayed': delayed,
      'wrong': wrong,
      'survivalTime': survivalTime
    };
  }

  Future<void> insertScore(Score score) async {
    // Get a reference to the database.
    final Database db = await database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'score',
      score.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

createDatabase() async {
  database = openDatabase(
    join(await getDatabasesPath(), 'game_database.db'),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE score(id INTEGER PRIMARY KEY, avgTime INTEGER, correct INTEGER, delayed INTEGER, wrong INTEGER, survivalTime INTEGER)",
      );
    },
    version: 1,
  );
}