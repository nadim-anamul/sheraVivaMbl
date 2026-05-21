import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalDataSource {
  AuthLocalDataSource({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserId = 'user_id';

  final FlutterSecureStorage _storage;

  Future<void> saveSession({
    required String userId,
    required String email,
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyUserEmail, value: email);
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<Map<String, String?>> readSession() async {
    return <String, String?>{
      _keyUserId: await _storage.read(key: _keyUserId),
      _keyUserEmail: await _storage.read(key: _keyUserEmail),
      _keyAccessToken: await _storage.read(key: _keyAccessToken),
      _keyRefreshToken: await _storage.read(key: _keyRefreshToken),
    };
  }

  Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}
