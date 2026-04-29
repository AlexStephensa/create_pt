import 'dart:math';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../models/team.dart';
import '../models/team_member.dart';
import '../services/appwrite_service.dart';
import 'appwrite_provider.dart';
import 'auth_provider.dart';

final teamProvider = StateNotifierProvider<TeamNotifier, TeamState>((ref) {
  final appwriteService = ref.watch(appwriteServiceProvider);
  final authNotifier = ref.watch(authProvider.notifier);
  return TeamNotifier(appwriteService, ref);
});

class TeamState {
  final bool isLoading;
  final List<Team> myTeams;
  final Team? currentTeam;
  final List<TeamMember> currentTeamMembers;
  final String? error;

  TeamState({
    this.isLoading = false,
    this.myTeams = const [],
    this.currentTeam,
    this.currentTeamMembers = const [],
    this.error,
  });

  TeamState copyWith({
    bool? isLoading,
    List<Team>? myTeams,
    Team? currentTeam,
    List<TeamMember>? currentTeamMembers,
    String? error,
  }) {
    return TeamState(
      isLoading: isLoading ?? this.isLoading,
      myTeams: myTeams ?? this.myTeams,
      currentTeam: currentTeam ?? this.currentTeam,
      currentTeamMembers: currentTeamMembers ?? this.currentTeamMembers,
      error: error ?? this.error,
    );
  }
}

class TeamNotifier extends StateNotifier<TeamState> {
  final AppwriteService _appwriteService;
  final Ref _ref;

  TeamNotifier(this._appwriteService, this._ref) : super(TeamState());

  Future<void> loadMyTeams() async {
    final user = _ref.read(authProvider).user;
    if (user == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final membersResult = await _appwriteService.listDocuments(
        collectionId: AppwriteConstants.teamMembersCollection,
        queries: [Query.equal('user_id', user.$id)],
      );

      final teamIds = membersResult.documents
          .map((d) => d.data['team_id'] as String)
          .toList();

      if (teamIds.isEmpty) {
        state = state.copyWith(isLoading: false, myTeams: []);
        return;
      }

      final teamsResult = await _appwriteService.listDocuments(
        collectionId: AppwriteConstants.teamsCollection,
        queries: [Query.equal('\$id', teamIds)],
      );

      final teams = teamsResult.documents
          .map((d) => Team.fromMap(d.data))
          .toList();
      state = state.copyWith(isLoading: false, myTeams: teams);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createTeam(String name, String description) async {
    final user = _ref.read(authProvider).user;
    if (user == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final String code = _generateTeamCode();
      final teamId = ID.unique();

      await _appwriteService.createDocument(
        collectionId: AppwriteConstants.teamsCollection,
        documentId: teamId,
        data: {
          'name': name,
          'description': description,
          'team_code': code,
          'created_by': user.$id,
        },
      );

      // Add user to team members
      await _appwriteService.createDocument(
        collectionId: AppwriteConstants.teamMembersCollection,
        documentId: ID.unique(),
        data: {
          'team_id': teamId,
          'user_id': user.$id,
          'display_name': user.name,
        },
      );

      await loadMyTeams();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> joinTeam(String code) async {
    final user = _ref.read(authProvider).user;
    if (user == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final teamResult = await _appwriteService.listDocuments(
        collectionId: AppwriteConstants.teamsCollection,
        queries: [Query.equal('team_code', code)],
      );

      if (teamResult.documents.isEmpty) {
        throw Exception('Team not found');
      }

      final teamId = teamResult.documents.first.$id;

      // Check if already in
      final membersResult = await _appwriteService.listDocuments(
        collectionId: AppwriteConstants.teamMembersCollection,
        queries: [
          Query.equal('team_id', teamId),
          Query.equal('user_id', user.$id),
        ],
      );

      if (membersResult.documents.isEmpty) {
        await _appwriteService.createDocument(
          collectionId: AppwriteConstants.teamMembersCollection,
          documentId: ID.unique(),
          data: {
            'team_id': teamId,
            'user_id': user.$id,
            'display_name': user.name,
          },
        );
      }

      await loadMyTeams();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void selectTeam(Team team) {
    state = state.copyWith(currentTeam: team);
    loadTeamMembers(team.id);
  }

  Future<void> loadTeamMembers(String teamId) async {
    try {
      final result = await _appwriteService.listDocuments(
        collectionId: AppwriteConstants.teamMembersCollection,
        queries: [Query.equal('team_id', teamId)],
      );

      final members = result.documents
          .map((d) => TeamMember.fromMap(d.data))
          .toList();
      state = state.copyWith(currentTeamMembers: members);
    } catch (e) {
      //print(e);
    }
  }

  String _generateTeamCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }
}
