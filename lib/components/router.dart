import 'package:go_router/go_router.dart';
import 'package:sae_mobile/widgets/auth/login.dart';
import 'package:sae_mobile/widgets/home.dart';

import '../widgets/auth/register.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase> [
    GoRoute(path: '/', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
  ],
);