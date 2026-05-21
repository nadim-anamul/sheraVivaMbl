import '../../../../core/result/result.dart';
import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<Result<AuthSession>> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();
  Future<AuthSession?> restoreSession();
}
