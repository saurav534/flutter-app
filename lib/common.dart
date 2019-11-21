enum ToughnessLevel { Easy, Medium, Hard }

class GameConfig {
  bool _vibration;
  ToughnessLevel _level;

  GameConfig(this._vibration, this._level);

  bool get vibration => _vibration;

  ToughnessLevel get level => _level;
}