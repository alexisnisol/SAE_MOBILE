import 'package:go_router/go_router.dart';
import 'package:sae_mobile/widgets/home.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase> [
    GoRoute(path: '/', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/register', builder: (context, state) => HomeScreen()),

  ],
);