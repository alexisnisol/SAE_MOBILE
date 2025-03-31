import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class AuthScreen extends StatefulWidget {

  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  
  //https://supabase.com/docs/guides/auth/auth-helpers/flutter-auth-ui
  //https://supabase.com/docs/guides/auth/managing-user-data?queryGroups=language&language=dart
  //https://www.freecodecamp.org/news/add-auth-to-flutter-apps-with-supabase-auth-ui/
  @override
  Widget build(BuildContext context) {
    return SupaEmailAuth(
      redirectTo: kIsWeb ? null : 'io.mydomain.myapp://callback',
      onSignInComplete: (response) {
        GoRouter.of(context).go('/profil');
      },
      onSignUpComplete: (response) {},
      metadataFields: [
        MetaDataField(
          prefixIcon: const Icon(Icons.person),
          label: 'Username',
          key: 'username',
          validator: (val) {
            if (val == null || val.isEmpty) {
              return 'Please enter something';
            }
            return null;
          },
        ),
      ],
    );
  }
}