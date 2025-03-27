import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sae_mobile/components/review.dart';
import 'package:sae_mobile/widgets/avis.dart';
import 'package:sae_mobile/components/database_helper.dart';
import 'mock.mocks.dart';
import 'package:sae_mobile/components/restaurant.dart';

void main() {
  late MockIDatabase mockDatabase;
  late List<Review> fakeReviews;

  setUp(() {
    mockDatabase = MockIDatabase();

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

    // Stub pour getRestaurantById
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

    // Stub pour getReviews
    when(mockDatabase.getReviews(1)).thenAnswer((_) async => fakeReviews);

    // Stub pour deleteReview
    when(mockDatabase.deleteReview(any)).thenAnswer((invocation) async {
      final int idToDelete = invocation.positionalArguments[0];
      fakeReviews.removeWhere((review) => review.id == idToDelete);
      print("Avis supprimé !");
    });

    // Stub pour imageLink
    when(mockDatabase.imageLink(any)).thenAnswer(
            (_) async => 'https://example.com/default.png');

    DatabaseHelper.setDatabase(mockDatabase);
  });
  testWidgets('Affichage et suppression des avis', (WidgetTester tester) async {
    // Simuler `getReviews`
    when(mockDatabase.getReviews(1)).thenAnswer((_) async => fakeReviews);

    // Simuler `deleteReview`
    when(mockDatabase.deleteReview(any)).thenAnswer((_) async {
      fakeReviews.removeAt(0); // Supprime l'avis de la liste simulée
    });

    // Démarrer l'application avec AvisPage
    await tester.pumpWidget(MaterialApp(home: AvisPage()));

    // Attendre que tout soit chargé
    await tester.pump(Duration(seconds: 1));

    // Vérification : Les avis fictifs sont affichés
    expect(find.text("Great food"), findsOneWidget);
    expect(find.text("Excellent service!"), findsOneWidget);

    // Vérification : Suppression d'un avis
    final deleteButton = find.byIcon(Icons.delete).first;
    await tester.tap(deleteButton);
    await tester.pump(); // Première mise à jour de l'UI

    // Attendre et vérifier que l'UI se met bien à jour
    await tester.pump(const Duration(seconds: 1));

    // Vérification : L'avis supprimé ne doit plus être visible
    expect(find.text("Great food"), findsNothing);
    expect(find.text("Excellent service!"), findsOneWidget);
  });
}
