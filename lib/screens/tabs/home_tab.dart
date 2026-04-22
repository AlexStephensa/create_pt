import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/round_provider.dart';
import 'package:intl/intl.dart';

class HomeTab extends ConsumerWidget {
  final String teamId;

  const HomeTab({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final roundState = ref.watch(roundProvider);

    if (user == null || roundState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    int sHits = 0, sMiss = 0;
    int dHits = 0, dMiss = 0;
    int hHits = 0, hMiss = 0;

    // Create a map for quick round lookup to avoid O(n^2) and potential crashes
    final roundMap = {for (var r in roundState.teamRounds) r.id: r};

    for (var score in roundState.teamRoundScores) {
      if (score.userId == user.$id) {
        final round = roundMap[score.roundId];
        if (round != null) {
          if (round.roundType == 'singles') {
            sHits += score.hits;
            sMiss += score.misses;
          } else if (round.roundType == 'doubles') {
            dHits += score.hits;
            dMiss += score.misses;
          } else if (round.roundType == 'handicap') {
            hHits += score.hits;
            hMiss += score.misses;
          }
        }
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(roundProvider.notifier).loadRounds(teamId);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lifetime Stats',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _StatRow('Singles', sHits, sMiss),
                  _StatRow('Doubles', dHits, dMiss),
                  _StatRow('Handicap', hHits, hMiss),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Rounds',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (roundState.teamRounds.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No rounds yet.'),
              ),
            )
          else
            ...roundState.teamRounds.map((r) {
              final myScore = roundState.teamRoundScores
                  .where((s) => s.roundId == r.id && s.userId == user.$id)
                  .firstOrNull;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.withOpacity(0.2),
                    child: Icon(Icons.sports_score, color: Colors.orange[400]),
                  ),
                  title: Text(r.roundType.toUpperCase()),
                  subtitle: Text(DateFormat.yMMMd().format(r.createdAt)),
                  trailing: myScore != null
                      ? Text(
                          '${myScore.hits} / ${myScore.totalShots}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Text('-', style: TextStyle(fontSize: 18)),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int hits;
  final int misses;
  const _StatRow(this.label, this.hits, this.misses);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            '$hits hit / $misses missed',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
