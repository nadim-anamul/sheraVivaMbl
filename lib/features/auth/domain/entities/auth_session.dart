import 'package:equatable/equatable.dart';

class AuthSession extends Equatable {
  const AuthSession({
    required this.userId,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
  });

  final String userId;
  final String email;
  final String accessToken;
  final String refreshToken;

  @override
  List<Object> get props => <Object>[userId, email, accessToken, refreshToken];
}
