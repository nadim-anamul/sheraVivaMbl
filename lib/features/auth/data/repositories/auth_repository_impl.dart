import '../../../../core/result/result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<Result<AuthSession>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final payload = await _remote.signIn(email: email, password: password);
      final session = AuthSession(
        userId: payload['userId'] as String,
        email: payload['email'] as String,
        accessToken: payload['accessToken'] as String,
        refreshToken: payload['refreshToken'] as String,
      );
      await _local.saveSession(
        userId: session.userId,
        email: session.email,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
      return Success<AuthSession>(session);
    } catch (_) {
      return const FailureResult<AuthSession>(
        'ইমেইল বা পাসওয়ার্ড সঠিক নয়',
      );
    }
  }

  @override
  Future<void> signOut() {
    return _local.clearSession();
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final payload = await _local.readSession();
    final userId = payload['user_id'];
    final email = payload['user_email'];
    final accessToken = payload['access_token'];
    final refreshToken = payload['refresh_token'];

    if (userId == null ||
        email == null ||
        accessToken == null ||
        refreshToken == null) {
      return null;
    }

    return AuthSession(
      userId: userId,
      email: email,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
