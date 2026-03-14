import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import 'token_provider.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthNotifier(apiService, ref);
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final String? token;
  final UserRole? role;

  AuthState({
    this.isAuthenticated = false, 
    this.isLoading = false, 
    this.error,
    this.token,
    this.role,
  });

  AuthState copyWith({
    bool? isAuthenticated, 
    bool? isLoading, 
    String? error,
    String? token,
    UserRole? role,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      token: token ?? this.token,
      role: role ?? this.role,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final Ref _ref;
  final _storage = const FlutterSecureStorage();

  AuthNotifier(this._apiService, this._ref) : super(AuthState(isLoading: true)) {
    checkAuthStatus();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.login(email, password);
      print('DEBUG: Login response: $response');
      final token = response['access_token'];
      final userRoleStr = response['user']?['role'] ?? response['role']; 
      print('DEBUG: Extracted role string: $userRoleStr');
      
      if (token != null) {
        await _storage.write(key: 'access_token', value: token);
        if (userRoleStr != null) {
          await _storage.write(key: 'user_role', value: userRoleStr);
        }
        
        final role = userRoleStr != null ? UserRole.fromString(userRoleStr) : null;
        print('DEBUG: Assigned UserRole: $role');

        state = state.copyWith(
          isAuthenticated: true, 
          isLoading: false,
          token: token,
          role: role,
        );
        _ref.read(tokenProvider.notifier).state = token;
      } else {
        throw 'Invalid response from server';
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'user_role');
    _ref.read(tokenProvider.notifier).state = null;
    state = state.copyWith(isAuthenticated: false, isLoading: false, token: null, role: null);
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    final token = await _storage.read(key: 'access_token');
    final roleStr = await _storage.read(key: 'user_role');
    
    if (token != null) {
      state = state.copyWith(
        isAuthenticated: true, 
        isLoading: false, 
        token: token,
        role: roleStr != null ? UserRole.fromString(roleStr) : null,
      );
      _ref.read(tokenProvider.notifier).state = token;
    } else {
      state = state.copyWith(isAuthenticated: false, isLoading: false);
    }
  }
}
