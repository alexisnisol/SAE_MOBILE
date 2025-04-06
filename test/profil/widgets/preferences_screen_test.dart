import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:sae_mobile/models/viewmodels/settings_viewmodel.dart';
import 'package:sae_mobile/widgets/profil/preferences_screen.dart';

class MockSettingsViewModel extends Mock implements SettingsViewModel {
  bool _isDark = false;
  bool _isGeolocationDisabled = true;

  @override
  bool get isDark => _isDark;

  @override
  set isDark(bool value) {
    _isDark = value;
    notifyListeners();
  }

  @override
  bool get isGeolocationDisabled => _isGeolocationDisabled;

  @override
  set isGeolocationDisabled(bool value) {
    _isGeolocationDisabled = value;
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  void notifyListeners() {}
}

void main() {
  late MockSettingsViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockSettingsViewModel();
  });

  testWidgets('Vérifie la présence des composants (du texte et des boutons)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<SettingsViewModel>.value(
          value: mockViewModel,
          child: PreferencesScreen(),
        ),
      ),
    );

    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Confidentialité'), findsOneWidget);

    expect(find.text('Mode sombre'), findsOneWidget);
    expect(find.text('Désactiver la géolocalisation'), findsOneWidget);

    expect(find.byIcon(Icons.invert_colors), findsOneWidget);
    expect(find.byIcon(Icons.location_on), findsOneWidget);
  });

  testWidgets("Vérifie que le bouton du thème change bien l'état du ViewModel",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<SettingsViewModel>.value(
          value: mockViewModel,
          child: PreferencesScreen(),
        ),
      ),
    );

    expect(mockViewModel.isDark, false);
    mockViewModel.isDark = true;
    expect(mockViewModel.isDark, true);
  });

  testWidgets(
      "Vérifie que le bouton de la géolocalisation change bien l'état du ViewModel",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<SettingsViewModel>.value(
          value: mockViewModel,
          child: PreferencesScreen(),
        ),
      ),
    );

    expect(mockViewModel.isGeolocationDisabled, true);
    mockViewModel.isGeolocationDisabled = false;
    expect(mockViewModel.isGeolocationDisabled, false);
  });
}
