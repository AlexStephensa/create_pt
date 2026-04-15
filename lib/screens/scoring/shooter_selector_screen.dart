import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/team_provider.dart';
import '../../providers/scoring_provider.dart';
import '../../models/team_member.dart';

class ShooterSelectorScreen extends ConsumerStatefulWidget {
  final String teamId;
  const ShooterSelectorScreen({super.key, required this.teamId});

  @override
  ConsumerState<ShooterSelectorScreen> createState() =>
      _ShooterSelectorScreenState();
}

class _ShooterSelectorScreenState extends ConsumerState<ShooterSelectorScreen> {
  List<TeamMember?> selectedShooters = List.filled(5, null);

  @override
  Widget build(BuildContext context) {
    final members = ref.read(teamProvider).currentTeamMembers;
    int selectedCount = selectedShooters.where((s) => s != null).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Select Shooters')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Assign shooters to stations (Max 5). Shooter 1 is required.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: DropdownButtonFormField<TeamMember>(
                      decoration: InputDecoration(
                        labelText: 'Shooter \${index + 1}',
                        border: const OutlineInputBorder(),
                      ),
                      value: selectedShooters[index],
                      items: [
                        const DropdownMenuItem<TeamMember>(
                          value: null,
                          child: Text('None'),
                        ),
                        ...members.map((m) {
                          // Prevent selecting same person twice
                          bool isSelectedElsewhere =
                              selectedShooters.any((s) => s?.id == m.id) &&
                              selectedShooters[index]?.id != m.id;
                          return DropdownMenuItem(
                            value: m,
                            enabled: !isSelectedElsewhere,
                            child: Text(
                              m.displayName +
                                  (isSelectedElsewhere ? ' (Selected)' : ''),
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setState(() {
                          selectedShooters[index] = val;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (selectedCount >= 1 && selectedShooters[0] != null)
                    ? () {
                        final finalShooters = selectedShooters
                            .where((s) => s != null)
                            .cast<TeamMember>()
                            .toList();
                        final type = ref.read(scoringProvider).roundType;
                        ref
                            .read(scoringProvider.notifier)
                            .setupRound(type, finalShooters);
                        context.push(
                          '/dashboard/\${widget.teamId}/score/round',
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Start Round',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
