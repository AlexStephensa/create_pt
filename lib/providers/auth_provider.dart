import 'package:appwrite/models.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/appwrite_service.dart';
import 'appwrite_provider.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final appwriteService = ref.watch(appwriteServiceProvider);
  return AuthNotifier(appwriteService);
});

class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;

  AuthState({this.isLoading = false, this.user, this.error});

  AuthState copyWith({bool? isLoading, User? user, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AppwriteService _appwriteService;

  AuthNotifier(this._appwriteService) : super(AuthState()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _appwriteService.getCurrentUser();
      state = state.copyWith(isLoading: false, user: user, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, user: null, error: e.toString());
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (email.isEmpty || password.isEmpty) throw Exception('Email and password cannot be empty');
      await _appwriteService.login(email, password);
      final user = await _appwriteService.getCurrentUser();
      state = state.copyWith(isLoading: false, user: user, error: null);
      return true;
    } on AppwriteException catch (e) {
      if (e.message != null && e.message!.contains('creation of a session is prohibited when a session is active')) {
         try {
           final user = await _appwriteService.getCurrentUser();
           state = state.copyWith(isLoading: false, user: user, error: null);
           return true;
         } catch (_) {}
      }
      state = state.copyWith(isLoading: false, error: e.message ?? e.toString());
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (name.isEmpty || email.isEmpty || password.isEmpty) throw Exception('All fields are required');
      if (password.length < 8) throw Exception('Password must be at least 8 characters');
      final user = await _appwriteService.register(name, email, password);
      state = state.copyWith(isLoading: false, user: user, error: null);
      return true;
    } on AppwriteException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message ?? e.toString());
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _appwriteService.logout();
      state = AuthState(); 
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
