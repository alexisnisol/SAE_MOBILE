import 'package:supabase/supabase.dart';
import '../database/database_helper.dart';

class AuthHelper {

  static final _auth = DatabaseHelper.getAuth();

  static Future<void> signUp(String name, String email, String password) async {
    try {
      await _auth.signUp(email: email, password: password, data: {"displayName": name});
    } on AuthException catch (e) {
      throw Exception('Failed to sign up: ${e.message}');
    }
  }

  static Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw Exception('Failed to sign in: ${e.message}');
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on AuthException catch (e) {
      throw Exception('Failed to sign out: ${e.message}');
    }
  }

  static User getCurrentUser() {
    return _auth.currentUser;
  }

  static String getCurrentUserName() {
    return _auth.currentUser!.userMetadata?['displayName'] ?? 'Inconnu';
  }
  
  static bool isSignedIn() {
    return _auth.currentUser != null;
  }

}