import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'medicine_provider.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthNotifier(dio);
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;

  AuthState({this.isAuthenticated = false, this.isLoading = false, this.error, this.user});

  AuthState copyWith({bool? isAuthenticated, bool? isLoading, String? error, Map<String, dynamic>? user}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Dio _dio;
  final _storage = const FlutterSecureStorage();

  AuthNotifier(this._dio) : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final token = response.data['access_token'];
        final userData = response.data['user'];

        await _storage.write(key: 'jwt_token', value: token);
        
        state = state.copyWith(
          isAuthenticated: true, 
          isLoading: false,
          user: userData,
        );
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Login failed';
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: message is List ? message.join(', ') : message.toString(),
      );
      throw state.error!;
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      throw 'An unexpected error occurred';
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _storage.delete(key: 'jwt_token');
    state = state.copyWith(isAuthenticated: false, isLoading: false, user: null);
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      try {
        // Optionnel: On pourrait appeler un endpoint /auth/profile pour valider le token
        state = state.copyWith(isAuthenticated: true, isLoading: false);
      } catch (e) {
        await logout();
      }
    } else {
      state = state.copyWith(isAuthenticated: false, isLoading: false);
    }
  }
}
