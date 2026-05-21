import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    // Placeholder contract until real Next.js endpoint schema is provided.
    if (email == 'demo@seraviva.com' && password == '123456') {
      return <String, dynamic>{
        'userId': 'candidate-001',
        'email': email,
        'accessToken': 'mock-access-token',
        'refreshToken': 'mock-refresh-token',
      };
    }

    // Keeps integration boundary explicit for later real API replacement.
    await _apiClient.post(
      ApiConfig.login,
      data: <String, dynamic>{
        'email': email,
        'password': password,
      },
    );

    throw Exception('Invalid credentials in mock mode');
  }
}
