import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/team_provider.dart';

class MembersTab extends ConsumerWidget {
  const MembersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teamProvider);
    final team = state.currentTeam;
    final members = state.currentTeamMembers;

    if (team == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Join Code: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(team.teamCode, style: const TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900)),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: team.teamCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied to clipboard')),
                    );
                  },
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final m = members[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.primaries[index % Colors.primaries.length],
                    child: Text(m.displayName.isNotEmpty ? m.displayName[0].toUpperCase() : '?'),
                  ),
                  title: Text(m.displayName),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
