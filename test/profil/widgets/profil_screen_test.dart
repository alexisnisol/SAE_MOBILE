import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sae_mobile/models/helper/auth_helper.dart';
import 'package:sae_mobile/widgets/profil/profil_screen.dart';

import '../mocks/auth_mocks.dart';

void main() {
  setUp(() {
    AuthHelper.setup(client: MockSupabaseClient());
  });
  
  testWidgets("Vérifie la présence de tous les composants dans le widget Profil, incluant le nom de l'utilisateur connecté, et les boutons de gestion", (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProfilScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Test User'), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);

    expect(find.text('Modifier le profil'), findsOneWidget);
    expect(find.text('Gérer les préférences'), findsOneWidget);
    expect(find.text('Se déconnecter'), findsOneWidget);
  });
}
