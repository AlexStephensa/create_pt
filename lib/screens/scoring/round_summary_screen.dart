import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/scoring_provider.dart';
import '../../providers/round_provider.dart';
import '../../providers/auth_provider.dart';

class RoundSummaryScreen extends ConsumerStatefulWidget {
  final String teamId;
  const RoundSummaryScreen({super.key, required this.teamId});

  @override
  ConsumerState<RoundSummaryScreen> createState() => _RoundSummaryScreenState();
}

class _RoundSummaryScreenState extends ConsumerState<RoundSummaryScreen> {
  bool _isSaving = false;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final scoringNotifier = ref.read(scoringProvider.notifier);
    final type = ref.read(scoringProvider).roundType;
    final userId = ref.read(authProvider).user!.$id;

    final finalScores = scoringNotifier.generateFinalScores('temp_id');

    final success = await ref.read(roundProvider.notifier).saveRoundSettingsAndScores(
      teamId: widget.teamId,
      scoredBy: userId,
      roundType: type,
      scores: finalScores,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        context.go('/dashboard/${widget.teamId}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save round')));
      }
    }
  }

  void _discard() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Discard Round?'),
        content: const Text('This will delete all scores from this session.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              context.go('/dashboard/${widget.teamId}');
            },
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final finalScores = ref.read(scoringProvider.notifier).generateFinalScores('temp_id');

    return Scaffold(
      appBar: AppBar(title: const Text('Round Summary'), automaticallyImplyLeading: false),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: finalScores.length,
              itemBuilder: (context, index) {
                final s = finalScores[index];
                double pct = s.totalShots > 0 ? (s.hits / s.totalShots) * 100 : 0;
                return Card(
                  child: ListTile(
                    title: Text(s.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text('${s.hits} Hits / ${s.misses} Misses'),
                    trailing: Text('${pct.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 20, color: Colors.orange)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Round', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : _discard,
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                    child: const Text('Discard', style: TextStyle(fontSize: 18)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
