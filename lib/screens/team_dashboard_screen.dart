import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/team_provider.dart';
import '../providers/round_provider.dart';
import '../providers/auth_provider.dart';
import 'tabs/home_tab.dart';
import 'tabs/score_tab.dart';
import 'tabs/members_tab.dart';
import 'tabs/leaderboard_tab.dart';
import 'package:go_router/go_router.dart';

class TeamDashboardScreen extends ConsumerStatefulWidget {
  final String teamId;
  const TeamDashboardScreen({super.key, required this.teamId});

  @override
  ConsumerState<TeamDashboardScreen> createState() => _TeamDashboardScreenState();
}

class _TeamDashboardScreenState extends ConsumerState<TeamDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(roundProvider.notifier).loadRounds(widget.teamId, ref.read(authProvider).user!.$id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final teamState = ref.watch(teamProvider);
    final team = teamState.currentTeam;

    if (team == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tabs = [
      HomeTab(teamId: widget.teamId),
      const ScoreTab(),
      const MembersTab(),
      const LeaderboardTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (mounted) context.go('/');
            },
          )
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Score'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Members'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Leaderboard'),
        ],
      ),
    );
  }
}
