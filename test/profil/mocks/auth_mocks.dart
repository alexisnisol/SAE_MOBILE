import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mocks pour les classes externes et les helpers
class MockUser extends Mock implements User {
  @override
  final String id = 'test-user-id';

  @override
  Map<String, dynamic>? userMetadata = {
    'displayName': 'Test User',
    'avatar_url': 'test-avatar.jpg'
  };
}

class MockSupabaseClient extends Mock implements SupabaseClient {
  @override
  final GoTrueClient auth = MockGoTrueClient();
}

class MockGoTrueClient extends Mock implements GoTrueClient {
  @override
  User? get currentUser => MockUser();
}
