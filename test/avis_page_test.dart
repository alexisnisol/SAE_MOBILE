import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sae_mobile/models/restaurant.dart';
import 'package:sae_mobile/models/database/database_helper.dart';
import 'package:sae_mobile/models/database/i_database.dart';
import 'package:sae_mobile/models/restaurant.dart';
import 'package:sae_mobile/models/review.dart';
import 'package:sae_mobile/widgets/avis.dart';
import 'mock.mocks.dart';


void main() {
  late MockIDatabase mockDatabase;
  late List<Review> fakeReviews;

  setUp(() {
    mockDatabase = MockIDatabase();

    // Créer une liste d'avis de test
    fakeReviews = [
      Review(
        id: 1,
        restaurantId: 1,
        userId: 1,
        etoiles: 4,
        avis: "Great food",
        date: DateTime.now(),
      ),
      Review(
        id: 2,
        restaurantId: 1,
        userId: 2,
        etoiles: 5,
        avis: "Excellent service!",
        date: DateTime.now(),
      ),
    ];

    // Configuration du mock pour getRestaurantById
    when(mockDatabase.getRestaurantById(any)).thenAnswer((_) async =>
        Restaurant(
          id_restaurant: 1,
          name: 'Fake Restaurant',
          operator: 'Fake Operator',
          brand: 'Fake Brand',
          opening_hours: '09:00-18:00',
          wheelchair: false,
          vegetarian: false,
          vegan: false,
          delivery: false,
          takeaway: false,
          internet_access: 'Oui',
          stars: 5,
          capacity: 100,
          drive_through: false,
          wikidata: 'fake_wikidata',
          brand_wikidata: 'fake_brand_wikidata',
          siret: '12345678901234',
          phone: '0123456789',
          website: 'https://fakerestaurant.com',
          facebook: 'https://facebook.com/fakerestaurant',
          smoking: false,
          com_insee: 12345,
          com_nom: 'Fake City',
          region: 'Fake Region',
          code_region: 1,
          departement: 'Fake Departement',
          code_departement: 1,
          commune: 'Fake Commune',
          code_commune: 1,
          latitude: 0,
          longitude: 0,
        ));

    // Configuration du mock pour imageLink
    when(mockDatabase.imageLink(any))
        .thenAnswer((_) async => 'https://example.com/default.png');

    // Utilisation de la liste copiée pour éviter des problèmes de référence

    when(mockDatabase.getReviews("1"))
        .thenAnswer((_) async => List<Review>.from(fakeReviews));

    // Comportement personnalisé pour deleteReview
    when(mockDatabase.deleteReview(any)).thenAnswer((invocation) async {
      final int reviewId = invocation.positionalArguments[0];
      print("Avis supprimé ! ID: $reviewId");

      // Supprimer l'avis avec l'ID spécifié
      fakeReviews.removeWhere((review) => review.id == reviewId);

      // Mise à jour du mock pour retourner la liste modifiée

      when(mockDatabase.getReviews("1"))
          .thenAnswer((_) async => List<Review>.from(fakeReviews));
    });

    // Définir la base de données mockée
    DatabaseHelper.setDatabase(mockDatabase as IDatabase);
  });

  testWidgets('Affichage et suppression des avis', (WidgetTester tester) async {
    // Lancer la page des avis
    await tester.pumpWidget(MaterialApp(home: AvisPage()));

    // Attendre que tous les FutureBuilders se résolvent
    // On utilise une boucle de pump pour éviter que pumpAndSettle ne timeout
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Vérification : Les avis sont affichés
    expect(find.text("Great food"), findsOneWidget);
    expect(find.text("Excellent service!"), findsOneWidget);

    // Vérification : Présence des boutons de suppression
    expect(find.byIcon(Icons.delete), findsNWidgets(2));

    // Suppression du premier avis
    await tester.tap(find.byIcon(Icons.delete).first);
    // On attend à nouveau que l'UI se mette à jour
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Vérification : L'avis supprimé ne doit plus être visible
    expect(find.text("Great food"), findsNothing);
    expect(find.text("Excellent service!"), findsOneWidget);
  });
}
