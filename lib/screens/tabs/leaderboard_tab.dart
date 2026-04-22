import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/team_provider.dart';
import '../../providers/round_provider.dart';

class LeaderboardTab extends ConsumerStatefulWidget {
  const LeaderboardTab({super.key});

  @override
  ConsumerState<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends ConsumerState<LeaderboardTab> {
  String _selectedType = 'singles';

  @override
  Widget build(BuildContext context) {
    final teamState = ref.watch(teamProvider);
    final roundState = ref.watch(roundProvider);

    if (roundState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Calculate stats
    Map<String, Map<String, int>> userStats = {}; // userId -> {hits: x, total: y}

    for (var m in teamState.currentTeamMembers) {
      userStats[m.userId] = {'hits': 0, 'total': 0};
    }

    // Create a map for quick round lookup
    final roundMap = {for (var r in roundState.teamRounds) r.id: r};

    for (var score in roundState.teamRoundScores) {
      final round = roundMap[score.roundId];
      // Only count if round exists and matches selected type
      if (round != null && round.roundType == _selectedType) {
        if (userStats.containsKey(score.userId)) {
          userStats[score.userId]!['hits'] =
              userStats[score.userId]!['hits']! + score.hits;
          userStats[score.userId]!['total'] =
              userStats[score.userId]!['total']! + score.totalShots;
        } else {
          // If member is not in currentTeamMembers (maybe left team?), we can still track them if needed
          // but for leaderboard we usually only show current members.
        }
      }
    }

    List<Map<String, dynamic>> ranks = [];
    for (var m in teamState.currentTeamMembers) {
      final stats = userStats[m.userId]!;
      final hits = stats['hits']!;
      final total = stats['total']!;
      final pct = total > 0 ? (hits / total) * 100 : 0.0;
      ranks.add({
        'name': m.displayName,
        'hits': hits,
        'total': total,
        'pct': pct,
      });
    }

    ranks.sort((a, b) => b['pct'].compareTo(a['pct']));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'singles', label: Text('Singles')),
              ButtonSegment(value: 'doubles', label: Text('Doubles')),
              ButtonSegment(value: 'handicap', label: Text('Handicap')),
            ],
            selected: {_selectedType},
            onSelectionChanged: (set) {
              setState(() => _selectedType = set.first);
            },
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              if (teamState.currentTeam != null) {
                await ref
                    .read(roundProvider.notifier)
                    .loadRounds(teamState.currentTeam!.id, ref.read(authProvider).user!.userId);
              }
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: ranks.length,
              itemBuilder: (context, index) {
                final r = ranks[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: index == 0
                        ? Colors.amber
                        : (index == 1
                            ? Colors.grey[300]
                            : (index == 2
                                ? Colors.brown[300]
                                : Colors.blueGrey)),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  title: Text(
                    r['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${r['hits']} / ${r['total']} hits'),
                  trailing: Text(
                    '${(r['pct'] as double).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

extension on User {
  String get userId => this.$id;
}
