import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _keyPassengerId = 'selected_passenger_id';
  static const _keyOnboardingSeen = 'onboarding_seen';
  static const _keyWalkthroughCompleted = 'walkthrough_completed';
  static const _keyWalkthroughVoiceMuted = 'walkthrough_voice_muted';

  final SharedPreferences _prefs;

  SessionStore(this._prefs);

  static Future<SessionStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SessionStore(prefs);
  }

  String? getPassengerId() {
    return _prefs.getString(_keyPassengerId);
  }

  Future<void> setPassengerId(String id) async {
    await _prefs.setString(_keyPassengerId, id);
  }

  Future<void> clear() async {
    await _prefs.remove(_keyPassengerId);
  }

  bool isOnboardingSeen() {
    return _prefs.getBool(_keyOnboardingSeen) ?? false;
  }

  Future<void> setOnboardingSeen(bool seen) async {
    await _prefs.setBool(_keyOnboardingSeen, seen);
  }

  bool isWalkthroughCompleted() {
    return _prefs.getBool(_keyWalkthroughCompleted) ?? false;
  }

  Future<void> setWalkthroughCompleted(bool completed) async {
    await _prefs.setBool(_keyWalkthroughCompleted, completed);
  }

  bool isWalkthroughVoiceMuted() {
    return _prefs.getBool(_keyWalkthroughVoiceMuted) ?? false;
  }

  Future<void> setWalkthroughVoiceMuted(bool muted) async {
    await _prefs.setBool(_keyWalkthroughVoiceMuted, muted);
  }
}
