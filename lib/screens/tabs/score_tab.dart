import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/team_provider.dart';
import '../../providers/scoring_provider.dart';

class ScoreTab extends ConsumerWidget {
  const ScoreTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.read(teamProvider).currentTeam!;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What are you scoring?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _TypeCard(
            title: 'Singles',
            icon: Icons.filter_1,
            onTap: () => _selectType(context, ref, team.id, 'singles'),
          ),
          const SizedBox(height: 16),
          _TypeCard(
            title: 'Doubles',
            icon: Icons.filter_2,
            onTap: () => _selectType(context, ref, team.id, 'doubles'),
          ),
          const SizedBox(height: 16),
          _TypeCard(
            title: 'Handicap',
            icon: Icons.social_distance,
            onTap: () => _selectType(context, ref, team.id, 'handicap'),
          ),
        ],
      ),
    );
  }

  void _selectType(BuildContext context, WidgetRef ref, String teamId, String type) {
    ref.read(scoringProvider.notifier).setupRound(type, []);
    context.push('/dashboard/$teamId/score/type');
  }
}

class _TypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _TypeCard({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.orange),
            const SizedBox(width: 24),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Spacer(),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
