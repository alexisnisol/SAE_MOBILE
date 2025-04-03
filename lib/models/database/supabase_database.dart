import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'i_database.dart';
import '../restaurant.dart';
import '../review.dart';

class SupabaseDatabase implements IDatabase {
  static bool _isInitialized = false;
  late final SupabaseClient _supabase;

  @override
  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        await dotenv.load();

        final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
        final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
        );
        _isInitialized = true;
      } catch (e) {
        print(e);
        _isInitialized = false;
      }
    }
    _supabase = Supabase.instance.client;
  }

  @override
  GoTrueClient getAuth() {
    return _supabase.auth;
  }

  @override
  SupabaseStorageClient getStorage() {
    return _supabase.storage;
  }

  @override
  Future<List<Restaurant>> getRestaurants() async {
    if (!_isInitialized) await initialize();

    try {
      final List<dynamic> response =
          await _supabase.from('RESTAURANT').select();
      return response
          .map((data) => Restaurant.fromMap(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erreur de récupération des restaurants depuis Supabase : $e');
      return [];
    }
  }

  @override
  Future<List<Review>> getReviews(String id) async {
    final List<dynamic> response =
        await _supabase.from('AVIS').select().eq('id_utilisateur', id);
    List<Review> reviews = response.map((data) {
      return Review.fromJson(data as Map<String, dynamic>);
    }).toList();

    return reviews;
  }

  @override
  Future<List<Review>> getReviewsRestau(int restauId) async {
    final List<dynamic> response =
        await _supabase.from('AVIS').select().eq('id_restaurant', restauId);
    List<Review> reviews = response.map((data) {
      return Review.fromJson(data as Map<String, dynamic>);
    }).toList();

    return reviews;
  }

  Future<int> idMaxAvis() async {
    final response = await _supabase
        .from("AVIS")
        .select("id_avis")
        .order("id_avis", ascending: false)
        .limit(1)
        .single();

    return response["id_avis"] ?? 0;
  }

  @override
  Future<void> addReview(String userId, int restauId, String avis, int etoiles,
      DateTime date) async {
    int idAvis = await idMaxAvis();
    idAvis++;
    await _supabase.from("AVIS").insert({
      "id_avis": idAvis,
      "id_utilisateur": userId,
      "id_restaurant": restauId,
      "etoile": etoiles,
      "avis": avis,
      "date_avis": date.toIso8601String()
    });
  }

  @override
  Future<void> deleteReview(int id) async {
    await _supabase.from('AVIS').delete().eq('id_avis', id);
  }

  @override
  Future<Restaurant> getRestaurantById(int id) async {
    final response =
        await _supabase.from('RESTAURANT').select().eq('id_restaurant', id);
    return Restaurant.fromMap(response[0] as Map<String, dynamic>);
  }

  @override
  bool isConnected() {
    return _isInitialized;
  }

  @override
  Future<List<Map<String, dynamic>>> getTypeCuisineRestaurant(int id) async {
    final response = await _supabase
        .from("PROPOSER")
        .select("id_cuisine, TYPE_CUISINE(cuisine)")
        .eq("id_restaurant", id);

    if (response.isEmpty) {
      return []; // Retourne une liste vide si aucun type de cuisine trouvé
    }

    // Transformation des données pour extraire id et cuisine
    return response
        .map<Map<String, dynamic>>((row) => {
              "id": row["id_cuisine"],
              "cuisine": row["TYPE_CUISINE"]["cuisine"]
            })
        .toList();
  }

  @override
  Future<bool> estCuisineLike(String userId, int cuisineId) async {
    final response = await _supabase
        .from("CUISINE_AIME")
        .select()
        .eq("id_utilisateur", userId)
        .eq("id_cuisine", cuisineId);

    if (response.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Future<void> dislikeCuisine(String userId, int cuisineId) async {
    await _supabase
        .from("CUISINE_AIME")
        .delete()
        .eq("id_utilisateur", userId)
        .eq("id_cuisine", cuisineId);
  }

  @override
  Future<void> likeCuisine(String userId, int cuisineId) async {
    print("Début de likeCuisine");
    try {
      final response = await _supabase
          .from("CUISINE_AIME")
          .insert({"id_utilisateur": userId, "id_cuisine": cuisineId});

      // !!! Attention laisser : print("Error: ${response.error}");
      // !!! Sinon insertion non fonctionnel
      print("Error: ${response.error}");
    } catch (e) {
      print("Erreur lors de l'insertion: $e");
      throw e;
    }
  }

  @override
  Future<List<int>> getRestaurantFavoris(String userId) async {
    final response = await _supabase
        .from('RESTAURANT_AIME')
        .select()
        .eq('id_utilisateur', userId);
    // response est une liste de maps
    return (response as List<dynamic>)
        .map((row) => row['id_restaurant'] as int)
        .toList();
  }

  @override
  Future<void> deleteRestaurantFavoris(String userId, int restauId) {
    return _supabase
        .from('RESTAURANT_AIME')
        .delete()
        .eq('id_utilisateur', userId)
        .eq('id_restaurant', restauId);
  }

  @override
  Future<void> addRestaurantFavoris(String userId, int restauId) {
    print("Ajout du restaurant $restauId aux favoris de l'utilisateur $userId");
    return _supabase
        .from('RESTAURANT_AIME')
        .insert({'id_utilisateur': userId, 'id_restaurant': restauId});
  }

  @override
  Future<bool> isRestaurantFavorited(String userId, int restaurantId) async {
    final response = await _supabase
        .from('RESTAURANT_AIME')
        .select()
        .eq('id_utilisateur', userId)
        .eq('id_restaurant', restaurantId);
    return response.isNotEmpty;
  }
}
