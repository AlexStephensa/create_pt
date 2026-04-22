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

  Future<void> loadRounds(String teamId, String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Step 1: Fetch this user's scores directly
      final scoresResult = await _appwriteService.listDocuments(
        collectionId: AppwriteConstants.roundScoresCollection,
        queries: [
          Query.equal('user_id', userId),
          Query.limit(500),
        ],
      );

      final allScores = scoresResult.documents
          .map((d) {
        try {
          final map = Map<String, dynamic>.from(d.data);
          map['\$id'] = d.$id;
          return RoundScore.fromMap(map);
        } catch (e) {
          return null;
        }
      })
          .whereType<RoundScore>()
          .toList();

      // Step 2: Fetch rounds by the round IDs that appear in the user's scores
      final roundIds = allScores
          .map((s) => s.roundId)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      List<Round> rounds = [];
      if (roundIds.isNotEmpty) {
        final roundsResult = await _appwriteService.listDocuments(
          collectionId: AppwriteConstants.roundsCollection,
          queries: [
            Query.equal('\$id', roundIds),
            Query.orderDesc('created_at'),
            Query.limit(500),
          ],
        );

        rounds = roundsResult.documents
            .map((d) {
          try {
            final map = Map<String, dynamic>.from(d.data);
            map['\$id'] = d.$id;
            map['\$createdAt'] = d.$createdAt;
            return Round.fromMap(map);
          } catch (e) {
            return null;
          }
        })
            .whereType<Round>()
            .toList();
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
        final scoreData = score.toMap();
        scoreData['round_id'] = roundId;
        
        await _appwriteService.createDocument(
          collectionId: AppwriteConstants.roundScoresCollection,
          documentId: ID.unique(),
          data: scoreData,
        );
      }

      await loadRounds(teamId, scoredBy);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
