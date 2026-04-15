import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/landing_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/team_selector_screen.dart';
import 'screens/team_gate_screen.dart';
import 'screens/join_team_screen.dart';
import 'screens/create_team_screen.dart';
import 'screens/team_dashboard_screen.dart';
import 'screens/scoring/shooter_selector_screen.dart';
import 'screens/scoring/scoring_screen.dart';
import 'screens/scoring/round_summary_screen.dart';

import 'providers/auth_provider.dart';

/// A simple [ChangeNotifier] that the router uses as its [refreshListenable].
/// Calling [notify] tells the router to re-evaluate its redirect logic
/// without being destroyed and recreated.
class RouterNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

final _routerNotifierProvider = Provider<RouterNotifier>((ref) {
  final notifier = RouterNotifier();

  // Listen to auth state changes and tell the router to re-evaluate redirects.
  // Using ref.listen (not ref.watch) so the provider itself isn't invalidated.
  ref.listen<AuthState>(authProvider, (_, __) {
    notifier.notify();
  });

  return notifier;
});

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(_routerNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      // Read (not watch) the current auth state inside the redirect callback.
      final authState = ref.read(authProvider);
      final isAuthRoute = state.matchedLocation == '/auth' || state.matchedLocation == '/';
      final isAuth = authState.user != null;

      // Still loading the initial auth check — don't redirect yet.
      if (authState.isLoading) return null;

      if (!isAuth && !isAuthRoute) {
        return '/';
      }
      if (isAuth && isAuthRoute) {
        return '/teams'; 
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/teams',
        builder: (context, state) => const TeamSelectorScreen(),
      ),
      GoRoute(
        path: '/team-gate',
        builder: (context, state) => const TeamGateScreen(),
      ),
      GoRoute(
        path: '/join-team',
        builder: (context, state) => const JoinTeamScreen(),
      ),
      GoRoute(
        path: '/create-team',
        builder: (context, state) => const CreateTeamScreen(),
      ),
      GoRoute(
        path: '/dashboard/:teamId',
        builder: (context, state) {
          final teamId = state.pathParameters['teamId']!;
          return TeamDashboardScreen(teamId: teamId);
        },
      ),
      GoRoute(
        path: '/dashboard/:teamId/score/type',
        builder: (context, state) {
          final teamId = state.pathParameters['teamId']!;
          return ShooterSelectorScreen(teamId: teamId);
        },
      ),
      GoRoute(
        path: '/dashboard/:teamId/score/round',
        builder: (context, state) {
          final teamId = state.pathParameters['teamId']!;
          return ScoringScreen(teamId: teamId);
        },
      ),
      GoRoute(
        path: '/dashboard/:teamId/score/summary',
        builder: (context, state) {
          final teamId = state.pathParameters['teamId']!;
          return RoundSummaryScreen(teamId: teamId);
        },
      ),
    ],
  );
});
