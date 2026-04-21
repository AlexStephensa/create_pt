import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
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
  static const int _maxEqualValuesPerQuery = 100;

  RoundNotifier(this._appwriteService) : super(RoundState());

  Future<List<Document>> _fetchAllDocuments({
    required String collectionId,
    List<String> queries = const [],
    int batchSize = 100,
  }) async {
    final allDocuments = <Document>[];
    var offset = 0;

    while (true) {
      final result = await _appwriteService.listDocuments(
        collectionId: collectionId,
        queries: [...queries, Query.limit(batchSize), Query.offset(offset)],
      );

      allDocuments.addAll(result.documents);

      if (result.documents.length < batchSize) break;
      offset += batchSize;
    }

    return allDocuments;
  }

  Future<void> loadRounds(String teamId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final roundDocuments = await _fetchAllDocuments(
        collectionId: AppwriteConstants.roundsCollection,
        queries: [
          Query.equal('team_id', teamId),
          Query.orderDesc('created_at'),
        ],
      );

      final rounds = roundDocuments
          .map((d) {
            try {
              return Round.fromMap({...d.data, '\$id': d.$id});
            } catch (_) {
              return null;
            }
          })
          .whereType<Round>()
          .toList();

      // Use raw document IDs so score loading doesn't depend on Round parsing.
      final roundIds = roundDocuments.map((d) => d.$id).toList();

      List<RoundScore> allScores = [];
      if (roundIds.isNotEmpty) {
        final scoreDocuments = <Document>[];

        for (var i = 0; i < roundIds.length; i += _maxEqualValuesPerQuery) {
          final end = (i + _maxEqualValuesPerQuery < roundIds.length)
              ? i + _maxEqualValuesPerQuery
              : roundIds.length;
          final roundIdsChunk = roundIds.sublist(i, end);

          final chunkDocuments = await _fetchAllDocuments(
            collectionId: AppwriteConstants.roundScoresCollection,
            queries: [Query.equal('round_id', roundIdsChunk)],
          );

          scoreDocuments.addAll(chunkDocuments);
        }

        allScores = scoreDocuments
            .map((d) {
              try {
                return RoundScore.fromMap({...d.data, '\$id': d.$id});
              } catch (_) {
                return null;
              }
            })
            .whereType<RoundScore>()
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
