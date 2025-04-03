import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const THEME_KEY = "darkMode";
  static const GEOLOCATOR_KEY = "geolocationEnabled";

  saveSettingsTheme(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(THEME_KEY, value);
  }

  Future<bool> getSettingsTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(THEME_KEY) ?? false;
  }

  saveSettingsGeolocation(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(GEOLOCATOR_KEY, value);
  }

  Future<bool> getSettingsGeolocation() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(GEOLOCATOR_KEY) ?? false;
  }
}