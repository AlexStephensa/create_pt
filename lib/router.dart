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

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == '/auth' || state.matchedLocation == '/';
      final isAuth = authState.user != null;

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
