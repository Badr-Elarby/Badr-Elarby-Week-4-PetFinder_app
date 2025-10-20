import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences sharedPreferences;

  LocalStorageService({required this.sharedPreferences});

  // Generic methods for storing and retrieving data
  Future<bool> setString(String key, String value) async {
    return await sharedPreferences.setString(key, value);
  }

  String? getString(String key) {
    return sharedPreferences.getString(key);
  }

  Future<bool> setInt(String key, int value) async {
    return await sharedPreferences.setInt(key, value);
  }

  int? getInt(String key) {
    return sharedPreferences.getInt(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return await sharedPreferences.setBool(key, value);
  }

  bool? getBool(String key) {
    return sharedPreferences.getBool(key);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    return await sharedPreferences.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return sharedPreferences.getStringList(key);
  }

  Future<bool> remove(String key) async {
    return await sharedPreferences.remove(key);
  }

  Future<bool> clear() async {
    return await sharedPreferences.clear();
  }

  bool containsKey(String key) {
    return sharedPreferences.containsKey(key);
  }

  Set<String> getKeys() {
    return sharedPreferences.getKeys();
  }
}
