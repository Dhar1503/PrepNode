import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepnode/core/data/providers/data_providers.dart';
import 'package:prepnode/core/network/providers/network_providers.dart';
import 'package:prepnode/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:prepnode/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:prepnode/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:prepnode/features/auth/data/repositories/profile_repository_impl.dart';
import 'package:prepnode/features/auth/domain/entities/user.dart';
import 'package:prepnode/features/auth/domain/repositories/auth_repository.dart';
import 'package:prepnode/features/auth/domain/repositories/profile_repository.dart';

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AuthLocalDataSource(
    databaseService: databaseService,
    secureStorage: secureStorage,
  );
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AuthRemoteDataSource(
    apiClient: apiClient,
    secureStorage: secureStorage,
  );
});

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  return AuthRepositoryImpl(
    localDataSource: localDataSource,
  );
});

/// Profile Repository Provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  final databaseService = ref.watch(databaseServiceProvider);
  return ProfileRepositoryImpl(
    localDataSource: localDataSource,
    databaseService: databaseService,
  );
});

/// Auth State Provider
/// Manages authentication state across the app
class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? userName;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.userName,
    this.isLoading = false,
    this.errorMessage,
  });

  // Sentinel so copyWith can tell "errorMessage not passed" (keep current
  // value) apart from "errorMessage: null" (explicitly clear it). Without
  // this, `errorMessage ?? this.errorMessage` would make every explicit
  // null a no-op, so clearError() and the errorMessage:null reset at the
  // start of login()/register() would never actually clear a stale error —
  // it would still be sitting in state after a subsequent successful login.
  static const _unset = Object();

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? userName,
    bool? isLoading,
    Object? errorMessage = _unset,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
    );
  }
}

/// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (authResponse) {
        state = state.copyWith(
          isAuthenticated: true,
          userId: authResponse.user.id,
          userName: authResponse.user.name,
          isLoading: false,
        );
      },
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _authRepository.register(
      name: name,
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (authResponse) {
        state = state.copyWith(
          isAuthenticated: true,
          userId: authResponse.user.id,
          userName: authResponse.user.name,
          isLoading: false,
        );
      },
    );
  }

  Future<void> loginWithGoogle({
    required String idToken,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _authRepository.loginWithGoogle(idToken: idToken);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (authResponse) {
        state = state.copyWith(
          isAuthenticated: true,
          userId: authResponse.user.id,
          userName: authResponse.user.name,
          isLoading: false,
        );
      },
    );
  }

  Future<void> logout({required String refreshToken}) async {
    state = state.copyWith(isLoading: true);

    final result = await _authRepository.logout(refreshToken: refreshToken);

    result.fold(
      (failure) {
        // Even if logout fails, clear local state
        state = const AuthState();
      },
      (_) {
        state = const AuthState();
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Hydrates auth state from a session already persisted on disk (secure
  /// storage + local user record), without calling the login/register APIs.
  /// Used by [SplashScreen] to restore a previous login on app launch.
  void restoreSession(User user) {
    state = state.copyWith(
      isAuthenticated: true,
      userId: user.id,
      userName: user.name,
    );
  }
}

/// Auth State Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
