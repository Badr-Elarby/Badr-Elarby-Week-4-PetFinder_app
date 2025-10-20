import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyService {
  final SharedPreferences sharedPreferences;

  static const String _apiKeyKey = 'cat_api_key';
  static const String _defaultApiKey =
      'live_nS9y9yaa4R7WtFvL7aDZ0v4P5u2GWTDAr0IXYbyLw5BXhJYgy4htZK3TvhmeIwaU';

  ApiKeyService({required this.sharedPreferences});

  Future<void> initializeApiKey() async {
    // Store API key in SharedPreferences for future use
    if (!sharedPreferences.containsKey(_apiKeyKey)) {
      await sharedPreferences.setString(_apiKeyKey, _defaultApiKey);
    }
  }

  String getApiKey() {
    return sharedPreferences.getString(_apiKeyKey) ?? _defaultApiKey;
  }

  Future<void> updateApiKey(String newApiKey) async {
    await sharedPreferences.setString(_apiKeyKey, newApiKey);
  }
}
