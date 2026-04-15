import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/scoring_provider.dart';

class ScoringScreen extends ConsumerWidget {
  final String teamId;
  const ScoringScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scoringProvider);

    // Auto-navigate when complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.isComplete) {
        context.go('/dashboard/$teamId/score/summary');
      }
    });

    if (state.shooters.isEmpty || state.isComplete)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final currentShooter = state.currentShooter!;
    final shooterIndex = state.currentShooterIndex;
    final currentShots = state.shots[shooterIndex];
    int shotNumber = currentShots.length + 1;
    bool isDoubles = state.roundType == 'doubles';

    final List<dynamic> stationShooters = List.filled(5, null);
    final List<int?> stationShooterIndex = List.filled(5, null);
    for (int i = 0; i < state.shooters.length; i++) {
      int shotsTaken = state.shots[i].length;
      int rotationPhase = (shotsTaken >= 25 ? 24 : shotsTaken) ~/ 5;
      int currentStation = (i + rotationPhase) % 5;
      stationShooters[currentStation] = state.shooters[i];
      stationShooterIndex[currentStation] = i;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Scoring: ${state.roundType.toUpperCase()}')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 16,
              bottom: 16,
              left: 8,
              right: 8,
            ),
            width: double.infinity,
            color: Colors.orange.withOpacity(0.1),
            child: Column(
              children: [
                Row(
                  children: List.generate(5, (index) {
                    final shooter = stationShooters[index];
                    final isCurrent =
                        shooter != null &&
                        stationShooterIndex[index] == state.currentShooterIndex;

                    List<String> currentPhaseShots = [];
                    if (shooter != null) {
                      final sIdx = stationShooterIndex[index]!;
                      final sShots = state.shots[sIdx];
                      int phase =
                          (sShots.length >= 25 ? 24 : sShots.length) ~/ 5;
                      int startIndex = phase * 5;
                      if (sShots.length > startIndex) {
                        currentPhaseShots = sShots.sublist(startIndex);
                      }
                    }

                    return Expanded(
                      child: Card(
                        color: isCurrent ? Colors.orange : null,
                        elevation: isCurrent ? 4 : 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 4.0,
                          ),
                          child: Column(
                            children: [
                              Text(
                                'ST ${index + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent
                                      ? Colors.white
                                      : Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                shooter?.displayName.split(' ').first ?? '--',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent ? Colors.white : Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(5, (shotIndex) {
                                  Color c = isCurrent
                                      ? Colors.white30
                                      : Colors.grey[800]!;
                                  if (shooter != null &&
                                      currentPhaseShots.length > shotIndex) {
                                    final s = currentPhaseShots[shotIndex];
                                    if (s == 'hit' || s == 'dead_pair')
                                      c = Colors.green;
                                    else if (s == 'miss' || s == 'dead_loss')
                                      c = Colors.red;
                                    else if (s == 'loss_pair')
                                      c = Colors.yellow;
                                  }
                                  return Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 1.0,
                                      ),
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: c,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Text(
                  '${currentShooter.displayName} - Shot $shotNumber of 25',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: LinearProgressIndicator(
                    value: currentShots.length / 25,
                    backgroundColor: Colors.grey[800],
                    color: Colors.orange,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: currentShots.length,
              itemBuilder: (context, index) {
                final s = currentShots[index];
                Color c = Colors.grey;
                if (s == 'hit' || s == 'dead_pair') c = Colors.green;
                if (s == 'miss' || s == 'dead_loss') c = Colors.red;
                if (s == 'loss_pair') c = Colors.orange;

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: c, radius: 10),
                    title: Text('Shot ${index + 1}'),
                    trailing: Text(
                      s.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(color: c, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (!isDoubles)
                  Row(
                    children: [
                      Expanded(
                        child: _ScoreBtn(
                          'HIT',
                          Colors.green,
                          () => ref
                              .read(scoringProvider.notifier)
                              .recordShot('hit'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ScoreBtn(
                          'MISS',
                          Colors.red,
                          () => ref
                              .read(scoringProvider.notifier)
                              .recordShot('miss'),
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _ScoreBtn(
                              'DEAD PAIR',
                              Colors.green,
                              () => ref
                                  .read(scoringProvider.notifier)
                                  .recordShot('dead_pair'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _ScoreBtn(
                              'DEAD LOSS',
                              Colors.red,
                              () => ref
                                  .read(scoringProvider.notifier)
                                  .recordShot('dead_loss'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: _ScoreBtn(
                          'LOSS PAIR',
                          Colors.orange,
                          () => ref
                              .read(scoringProvider.notifier)
                              .recordShot('loss_pair'),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        ref.read(scoringProvider.notifier).undoLastShot(),
                    icon: const Icon(Icons.undo),
                    label: const Text('UNDO LIST SHOT'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBtn extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _ScoreBtn(this.text, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
