import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/round_score.dart';
import '../models/team_member.dart';

final scoringProvider = StateNotifierProvider<ScoringNotifier, ScoringState>((ref) {
  return ScoringNotifier();
});

class ScoringState {
  final String roundType; // 'singles', 'doubles', 'handicap'
  final List<TeamMember> shooters;
  final int currentShooterIndex;
  
  // Store shots per shooter. Index in list matches shooter index
  final List<List<String>> shots;

  ScoringState({
    this.roundType = 'singles',
    this.shooters = const [],
    this.currentShooterIndex = 0,
    this.shots = const [],
  });

  ScoringState copyWith({
    String? roundType,
    List<TeamMember>? shooters,
    int? currentShooterIndex,
    List<List<String>>? shots,
  }) {
    return ScoringState(
      roundType: roundType ?? this.roundType,
      shooters: shooters ?? this.shooters,
      currentShooterIndex: currentShooterIndex ?? this.currentShooterIndex,
      shots: shots ?? this.shots,
    );
  }

  bool get isComplete {
    if (shooters.isEmpty) return false;
    // For singles/handicap, it's 25. For doubles, it's 25 pairs (or 50 shots). 
    // We treat 25 records per shooter as complete. For doubles, 25 pairs = 25 records of 'dead_pair' etc.
    return shots.every((s) => s.length == 25);
  }
  
  TeamMember? get currentShooter {
    if (shooters.isEmpty || currentShooterIndex >= shooters.length) return null;
    return shooters[currentShooterIndex];
  }
}

class ScoringNotifier extends StateNotifier<ScoringState> {
  ScoringNotifier() : super(ScoringState());

  void setupRound(String type, List<TeamMember> selectedShooters) {
    state = state.copyWith(
      roundType: type,
      shooters: selectedShooters,
      shots: List.generate(selectedShooters.length, (_) => []),
      currentShooterIndex: 0,
    );
  }

  void recordShot(String result) {
    if (state.isComplete) return;

    final newShots = List<List<String>>.from(state.shots);
    newShots[state.currentShooterIndex] = List<String>.from(newShots[state.currentShooterIndex])..add(result);

    int nextIndex = state.currentShooterIndex;
    
    // Move to next shooter if round-robin (usually 5 shots per station in real trap, 
    // but the prompt says: "rotsates through shooters round-robin — one shot per turn — until all have taken 25 shots")
    // Wait, prompt: "one shot per turn". Let's do that.
    do {
      nextIndex = (nextIndex + 1) % state.shooters.length;
    } while (newShots[nextIndex].length == 25 && !newShots.every((s) => s.length == 25));

    state = state.copyWith(
      shots: newShots,
      currentShooterIndex: nextIndex,
    );
  }

  void undoLastShot() {
    // Find the previous shooter
    int prevIndex = state.currentShooterIndex;
    bool found = false;
    for(int i = 0; i < state.shooters.length; i++) {
        prevIndex = (prevIndex - 1) % state.shooters.length;
        if (prevIndex < 0) prevIndex += state.shooters.length;
        if (state.shots[prevIndex].isNotEmpty) {
            found = true;
            break;
        }
    }

    if (!found) return; // Nothing to undo

    final newShots = List<List<String>>.from(state.shots);
    newShots[prevIndex] = List<String>.from(newShots[prevIndex])..removeLast();

    state = state.copyWith(
      shots: newShots,
      currentShooterIndex: prevIndex,
    );
  }

  List<RoundScore> generateFinalScores(String roundId) {
    List<RoundScore> finalScores = [];
    for (int i = 0; i < state.shooters.length; i++) {
      int hits = 0;
      int misses = 0;
      int total = state.roundType == 'doubles' ? 50 : 25;
      
      for (var shot in state.shots[i]) {
        if (shot == 'hit') { hits += 1; misses += 0; }
        else if (shot == 'miss') { hits += 0; misses += 1; }
        else if (shot == 'dead_pair') { hits += 2; misses += 0; }
        else if (shot == 'dead_loss') { hits += 0; misses += 2; }
        else if (shot == 'loss_pair') { hits += 1; misses += 1; }
      }

      finalScores.add(RoundScore(
        id: '', // Will be assigned by service
        roundId: roundId,
        userId: state.shooters[i].userId,
        displayName: state.shooters[i].displayName,
        shots: state.shots[i],
        totalShots: total,
        hits: hits,
        misses: misses,
      ));
    }
    return finalScores;
  }
}
