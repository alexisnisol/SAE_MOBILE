import 'package:flutter_test/flutter_test.dart';
import 'package:sae_mobile/repository/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SettingsRepository repository;

  setUp(() {
    repository = SettingsRepository();
  });

  group('Theme settings', () {
    test('getSettingsTheme doit renvoyer false par défaut', () async {
      // Configurer SharedPreferences mock
      SharedPreferences.setMockInitialValues({});

      final result = await repository.getSettingsTheme();

      expect(result, false);
    });

    test('getSettingsTheme doit renvoyer la valeur stocké dans les SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'darkMode': true,
      });

      final result = await repository.getSettingsTheme();

      expect(result, true);
    });

    test('saveSettingsTheme doit stocker la valeur dans les SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      await repository.saveSettingsTheme(true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('darkMode'), true);
    });
  });

  group('Geolocation settings', () {
    test("getSettingsGeolocation doit renvoyer false par défaut", () async {
      SharedPreferences.setMockInitialValues({});

      final result = await repository.getSettingsGeolocation();

      expect(result, false);
    });

    test('getSettingsGeolocation doit renvoyer la valeur stocké dans les SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'geolocationEnabled': true,
      });

      final result = await repository.getSettingsGeolocation();

      expect(result, true);
    });

    test('saveSettingsGeolocation doit stocker la valeur dans les SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      await repository.saveSettingsGeolocation(true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('geolocationEnabled'), true);

      await repository.saveSettingsGeolocation(false);

      expect(prefs.getBool('geolocationEnabled'), false);
    });
  });
}
