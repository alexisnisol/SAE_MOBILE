import 'package:sae_mobile/models/database/database_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'i_database.dart';
import '../restaurant.dart';
import 'sqlite_database.dart';
import '../review.dart';

class SupabaseDatabase implements IDatabase {
  static bool _isInitialized = false;
  late final SupabaseClient _supabase;

  static String _supabaseUrl = 'https://rwvhbldaozvrcotlajbs.supabase.co';
  static String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3dmhibGRhb3p2cmNvdGxhamJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzczODgwMTUsImV4cCI6MjA1Mjk2NDAxNX0.ouVnoV0SrQsPGNpFqe2wzOXwgZbCUi9IEXsoidca5aE';

  @override
  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        await Supabase.initialize(
          url: _supabaseUrl,
          anonKey: _supabaseAnonKey,
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
  Future<List<Restaurant>> getRestaurants() async {
    if (!_isInitialized) await initialize();

    try {
      final List<dynamic> response = await _supabase.from('RESTAURANT').select();
      return response.map((data) => 
        Restaurant.fromMap(data as Map<String, dynamic>)
      ).toList();
    } catch (e) {
      print('Erreur de récupération des restaurants depuis Supabase : $e');
      return [];
    }
  }
  @override
  Future<List<Review>> getReviews(id) async {

    final List<dynamic> response = await _supabase.from('AVIS').select().eq('id_utilisateur', id);
    List<Review> reviews = response.map((data) {
      return Review.fromJson(data as Map<String, dynamic>);
    }).toList();

    return reviews;
  }
  @override
  Future<void> deleteReview(int id) async {
    await _supabase.from('AVIS').delete().eq('id_avis', id);
  }

  @override
  Future<Restaurant> getRestaurantById(int id) async {
    final response = await _supabase.from('RESTAURANT').select().eq('id_restaurant', id);
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
    return response.map<Map<String, dynamic>>((row) => {
      "id": row["id_cuisine"],
      "cuisine": row["TYPE_CUISINE"]["cuisine"]
    }).toList();
  }

  @override
  Future<bool> estCuisineLike(int userId, int cuisineId) async {
    final response = await _supabase.from("CUISINE_AIME").select().eq("id_utilisateur", userId).eq("id_cuisine", cuisineId);

    if (response.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Future<void> dislikeCuisine(int userId, int cuisineId) async {
    await _supabase.from("CUISINE_AIME").delete().eq("id_utilisateur", userId).eq("id_cuisine", cuisineId);
  }

  @override
  Future<void> likeCuisine(int userId, int cuisineId) async {
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
}
