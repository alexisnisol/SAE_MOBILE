import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sae_mobile/models/helper/auth_helper.dart';
import 'package:sae_mobile/widgets/profil/edit_profil_screen.dart';

import '../mocks/auth_mocks.dart';

void main() {
  setUp(() {
    AuthHelper.setup(client: MockSupabaseClient());
  });

  testWidgets("Vérifie la présence des composants d'édition",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EditProfilScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Test User'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.byType(FormBuilderTextField), findsOneWidget);
    expect(find.text("Nom d'utilisateur"), findsOneWidget);
    expect(find.text('Enregistrer'), findsOneWidget);
  });

  testWidgets("Vérifie que les champs sont obligatoires",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EditProfilScreen(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.byType(FormBuilderTextField), '');

    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.text('Champ requis'), findsOneWidget);
  });
}
