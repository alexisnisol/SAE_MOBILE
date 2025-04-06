import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sae_mobile/models/viewmodels/settings_viewmodel.dart';
import 'package:sae_mobile/repository/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([SettingsRepository])
import 'settings_viewmodel_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SettingsViewModel viewModel;
  late MockSettingsRepository mockRepository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});

    mockRepository = MockSettingsRepository();

    viewModel = SettingsViewModel();
    viewModel.setRepository(mockRepository);
  });

  test("L'état initial doit être les valeurs par défaut", () {
    when(mockRepository.getSettingsTheme()).thenAnswer((_) async => false);
    when(mockRepository.getSettingsGeolocation()).thenAnswer((_) async => true);

    viewModel.getSettings();

    expect(viewModel.isDark, false);
    expect(viewModel.isGeolocationDisabled, true);
  });

  test(
      'Changer la valeur du thème doit mettre à jour le repository et notifier ceux qui écoutent',
      () async {
    when(mockRepository.saveSettingsTheme(any)).thenAnswer((_) async {});
    when(mockRepository.getSettingsTheme()).thenAnswer((_) async => false);
    when(mockRepository.getSettingsGeolocation()).thenAnswer((_) async => true);

    // Créer un écouteur pour vérifier que notifyListeners est appelé
    bool listenerCalled = false;
    viewModel.addListener(() {
      listenerCalled = true;
    });

    viewModel.isDark = true;

    expect(viewModel.isDark, true);
    verify(mockRepository.saveSettingsTheme(true)).called(1);
    expect(listenerCalled, true);
  });

  test(
      'Changer la valeur de géolocalisation doit mettre à jour le repository et notifier ceux qui écoutent',
      () async {
    when(mockRepository.saveSettingsGeolocation(any)).thenAnswer((_) async {});
    when(mockRepository.getSettingsTheme()).thenAnswer((_) async => false);
    when(mockRepository.getSettingsGeolocation()).thenAnswer((_) async => true);

    bool listenerCalled = false;
    viewModel.addListener(() {
      listenerCalled = true;
    });

    viewModel.isGeolocationDisabled = false;

    // Vérifications
    expect(viewModel.isGeolocationDisabled, false);
    verify(mockRepository.saveSettingsGeolocation(false)).called(1);
    expect(listenerCalled, true);
  });

  test(
      'getSettings doit récupérer les valeurs du repository et notifier ceux qui écoutent',
      () async {
    when(mockRepository.getSettingsTheme()).thenAnswer((_) async => true);
    when(mockRepository.getSettingsGeolocation())
        .thenAnswer((_) async => false);

    bool listenerCalled = false;
    viewModel.addListener(() {
      listenerCalled = true;
    });

    await viewModel.getSettings(); //notifyListeners est appelé dans getSettings

    expect(viewModel.isDark, true);
    expect(viewModel.isGeolocationDisabled, false);

    expect(listenerCalled, true); // Vérifier que notifyListeners a été appelé
  });
}
