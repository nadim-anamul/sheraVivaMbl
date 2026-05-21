import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';

final authRepositoryProvider = Provider<AuthRepository>((Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(
    remote: AuthRemoteDataSource(apiClient),
    local: AuthLocalDataSource(),
  );
});

final signInUseCaseProvider = Provider<SignInUseCase>((Ref ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

enum AuthStatus {
  unauthenticated,
  loading,
  authenticated,
  failure,
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.session,
    this.errorMessage,
  });

  final AuthStatus status;
  final AuthSession? session;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      errorMessage: errorMessage,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required SignInUseCase signInUseCase,
    required AuthRepository repository,
  })  : _signInUseCase = signInUseCase,
        _repository = repository,
        super(const AuthState());

  final SignInUseCase _signInUseCase;
  final AuthRepository _repository;

  Future<void> restore() async {
    final session = await _repository.restoreSession();
    if (session == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    state = state.copyWith(
      status: AuthStatus.authenticated,
      session: session,
      errorMessage: null,
    );
  }

  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _signInUseCase(email: email, password: password);
    return result.when(
      success: (session) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          session: session,
          errorMessage: null,
        );
        return true;
      },
      failure: (message) {
        state = state.copyWith(
          status: AuthStatus.failure,
          errorMessage: message,
        );
        return false;
      },
    );
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((Ref ref) {
  return AuthController(
    signInUseCase: ref.watch(signInUseCaseProvider),
    repository: ref.watch(authRepositoryProvider),
  );
});
