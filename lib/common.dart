enum ToughnessLevel {
  Easy, Medium, Hard
}

class GameConfig {
  bool _vibration;
  ToughnessLevel _level;

  GameConfig(this._vibration, this._level);

  bool get vibration => _vibration;

  ToughnessLevel get level => _level;
}

class SingleClick {
  int allowedTime;
  int actualTime;
  bool isCorrect;
  bool clickMissed;
  bool pointLost;

  SingleClick({this.allowedTime, this.actualTime, this.isCorrect, this.clickMissed, this.pointLost});
}

class MatchScore {
  List<SingleClick> allClick;
  ToughnessLevel gameType;

  MatchScore({this.allClick, this.gameType});
}