import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../models/round.dart';
import '../models/round_score.dart';
import '../services/appwrite_service.dart';
import 'appwrite_provider.dart';

final roundProvider = StateNotifierProvider<RoundNotifier, RoundState>((ref) {
  final appwriteService = ref.watch(appwriteServiceProvider);
  return RoundNotifier(appwriteService);
});

class RoundState {
  final bool isLoading;
  final List<Round> teamRounds;
  final List<RoundScore> teamRoundScores;
  final String? error;

  RoundState({
    this.isLoading = false,
    this.teamRounds = const [],
    this.teamRoundScores = const [],
    this.error,
  });

  RoundState copyWith({
    bool? isLoading,
    List<Round>? teamRounds,
    List<RoundScore>? teamRoundScores,
    String? error,
  }) {
    return RoundState(
      isLoading: isLoading ?? this.isLoading,
      teamRounds: teamRounds ?? this.teamRounds,
      teamRoundScores: teamRoundScores ?? this.teamRoundScores,
      error: error ?? this.error,
    );
  }
}

class RoundNotifier extends StateNotifier<RoundState> {
  final AppwriteService _appwriteService;

  RoundNotifier(this._appwriteService) : super(RoundState());

  Future<void> loadRounds(String teamId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final roundsResult = await _appwriteService.listDocuments(
        collectionId: AppwriteConstants.roundsCollection,
        queries: [
          Query.equal('team_id', teamId),
          Query.orderDesc('created_at'),
        ],
      );

      final rounds = roundsResult.documents.map((d) => Round.fromMap(d.data)).toList();

      final roundsIds = rounds.map((e) => e.id).toList();
      
      List<RoundScore> allScores = [];
      if (roundsIds.isNotEmpty) {
        // Appwrite limit is usually 100 per query, maybe we do batches for a real app.
        // For simplicity, we just fetch scores for these rounds.
        final scoresResult = await _appwriteService.listDocuments(
          collectionId: AppwriteConstants.roundScoresCollection,
          queries: [Query.equal('round_id', roundsIds)],
        );
        allScores = scoresResult.documents.map((d) => RoundScore.fromMap(d.data)).toList();
      }

      state = state.copyWith(
        isLoading: false,
        teamRounds: rounds,
        teamRoundScores: allScores,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> saveRoundSettingsAndScores({
    required String teamId,
    required String scoredBy,
    required String roundType,
    required List<RoundScore> scores,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final roundId = ID.unique();
      await _appwriteService.createDocument(
        collectionId: AppwriteConstants.roundsCollection,
        documentId: roundId,
        data: {
          'team_id': teamId,
          'scored_by': scoredBy,
          'round_type': roundType,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      for (var score in scores) {
        await _appwriteService.createDocument(
          collectionId: AppwriteConstants.roundScoresCollection,
          documentId: ID.unique(),
          data: {
            'round_id': roundId,
            'user_id': score.userId,
            'display_name': score.displayName,
            'shots': score.shots,
            'total_shots': score.totalShots,
            'hits': score.hits,
            'misses': score.misses,
          },
        );
      }

      // Reload
      await loadRounds(teamId);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
