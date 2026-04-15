import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/team_provider.dart';

class TeamSelectorScreen extends ConsumerStatefulWidget {
  const TeamSelectorScreen({super.key});

  @override
  ConsumerState<TeamSelectorScreen> createState() => _TeamSelectorScreenState();
}

class _TeamSelectorScreenState extends ConsumerState<TeamSelectorScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teamProvider.notifier).loadMyTeams();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamProvider);

    ref.listen(teamProvider, (previous, next) {
      if (!next.isLoading && previous?.isLoading == true) {
        if (next.myTeams.isEmpty) {
          context.go('/team-gate');
        } else if (next.myTeams.length == 1) {
          ref.read(teamProvider.notifier).selectTeam(next.myTeams.first);
          context.go('/dashboard/${next.myTeams.first.id}');
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Your Teams')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.myTeams.isEmpty
              ? const Center(child: Text('No teams found.'))
              : ListView.builder(
                  itemCount: state.myTeams.length,
                  itemBuilder: (context, index) {
                    final team = state.myTeams[index];
                    return ListTile(
                      title: Text(team.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(team.description),
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Text(team.name[0].toUpperCase()),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        ref.read(teamProvider.notifier).selectTeam(team);
                        context.go('/dashboard/${team.id}');
                      },
                    );
                  },
                ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => context.push('/team-gate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text('Join or Create Team'),
          ),
        ),
      ),
    );
  }
}
