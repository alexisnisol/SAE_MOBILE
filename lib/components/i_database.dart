import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import 'restaurant.dart';

abstract class IDatabase {

  Future<void> initialize();
  Future<List<Restaurant>> getRestaurants();
  bool isConnected();
  GoTrueClient getAuth();
}
