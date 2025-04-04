import 'package:flutter/material.dart';

import '../../repository/settings_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  //Liste toutes les données qui sont susceptibles de faire changer l'état de l'application
  //ChangeNotifier est une classe qui permet de notifier les widgets qui l'écoute

  late bool _isDark;
  late bool _isGeolocationDisabled;

  late SettingsRepository _settingsRepository;
  bool get isDark => _isDark;
  bool get isGeolocationDisabled => _isGeolocationDisabled;

  SettingsViewModel() {
    _settingsRepository = SettingsRepository();
    _isDark = false;
    _isGeolocationDisabled = true;
    getSettings();
  }

  /*
   * Permet de changer le repository utilisé par le ViewModel pour les tests
   */
  void setRepository(SettingsRepository settingsRepository) {
    _settingsRepository = settingsRepository;
  }

  Future<void> getSettings() async {
    _isDark = await _settingsRepository.getSettingsTheme();
    _isGeolocationDisabled = await _settingsRepository.getSettingsGeolocation();
    notifyListeners();
  }

  set isDark(bool value) {
    _isDark = value;
    _settingsRepository.saveSettingsTheme(value);
    notifyListeners();
  }

  set isGeolocationDisabled(bool value) {
    _isGeolocationDisabled = value;
    _settingsRepository.saveSettingsGeolocation(value);
    notifyListeners();
  }
}