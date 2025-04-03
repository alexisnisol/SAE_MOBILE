import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sae_mobile/models/database/database_helper.dart';
import 'package:sae_mobile/models/database/sqlite_database.dart';
import 'package:sae_mobile/models/restaurant.dart';
import 'package:sae_mobile/widgets/restaurant_detail_screen.dart';

import 'mock.mocks.dart';

void main() {
  late MockIDatabase mockDatabase;
  late Restaurant restaurant;

  setUp(() {
    mockDatabase = MockIDatabase();

    restaurant = Restaurant(
      id_restaurant: 145,
      name: "McDonald's",
      operator: '',
      brand: "McDonald's",
      opening_hours: "Mo-Th 08:00-23:00; Fr-Sa 08:00-24:00; Su 08:00-23:00",
      wheelchair: true,
      vegetarian: false,
      vegan: false,
      delivery: false,
      takeaway: true,
      internet_access: 'wlan',
      stars: 0,
      capacity: 0,
      drive_through: false,
      wikidata: '',
      brand_wikidata: 'Q38076',
      siret: '',
      phone: '+33 2 38 81 05 98',
      website: '',
      facebook: '',
      smoking: false,
      com_insee: 45234,
      com_nom: 'Orléans',
      region: "Centre-Val de Loire",
      code_region: 24,
      departement: 'Loiret',
      code_departement: 45,
      commune: 'Orléans',
      code_commune: 45234,
      latitude: 47.90636889996,
      longitude: 1.9042957,
    );
  });

  testWidgets("Affichage du nom du restaurant", (WidgetTester tester) async {

    // await DatabaseHelper.initialize();
    // print(DatabaseHelper.getRestaurantById(145));


    // final SQLiteDatabase db = SQLiteDatabase as SQLiteDatabase;
    // await db.initialize();
    // print(db.getRestaurants());

    RestaurantDetailPage.CURRENT_USER_ID = "1";

    when(mockDatabase.getRestaurantById(restaurant.id_restaurant)).thenAnswer(
          (invocation) async => restaurant,
    );

    when(mockDatabase.imageLink(restaurant.name)).thenAnswer(
          (invocation) async => "https://example.com/image.jpg",
    );

    when(mockDatabase.isConnected()).thenReturn(true);

    when(DatabaseHelper.isRestaurantFavorited('1', restaurant.id_restaurant))
        .thenAnswer((_) async => false);

    when(DatabaseHelper.getTypeCuisineRestaurant(restaurant.id_restaurant))
        .thenAnswer((_) async => []);

    when(DatabaseHelper.estCuisineLike("1", restaurant.id_restaurant))
        .thenAnswer((_) async => false);

    when(DatabaseHelper.getReviewsRestau(restaurant.id_restaurant))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(
      MaterialApp(
        home: RestaurantDetailPage(restaurantId: restaurant.id_restaurant),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("McDonald's"), findsOneWidget);
  });
}


