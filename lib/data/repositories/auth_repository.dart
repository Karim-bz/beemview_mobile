import '../../core/api_client.dart';
import '../../core/api_exception.dart';
import '../../core/secure_storage.dart';
import '../models/user.dart';

/// Handles login, current user lookup, and session persistence.
class AuthRepository {
  AuthRepository({
    required ApiClient api,
    required SecureStorageService storage,
  }) : _api = api,
       _storage = storage;

  final ApiClient _api;
  final SecureStorageService _storage;

  /// Logs in and stores the returned token. Throws [ApiException] on failure.
  Future<User> login({
    required String email,
    required String password,
    required String subdomain,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password, 'subdomain': subdomain},
    );

    final body = res.data ?? {};
    final token = body['token'] as String?;
    if (token == null || token.isEmpty) {
      throw ApiException('Login response did not include a token.');
    }
    await _storage.saveToken(token);

    final userJson = (body['user'] as Map?)?.cast<String, dynamic>() ?? {};
    return User.fromJson(userJson);
  }

  /// Fetches the current user using the stored token.
  /// Throws [ApiException] on failure.
  Future<User> me() async {
    final res = await _api.get<Map<String, dynamic>>('/users/me/profile');
    final userJson = (res.data?['user'] as Map?)?.cast<String, dynamic>() ?? {};
    return User.fromJson(userJson);
  }

  /// Clears the local token. No server call (spec: no logout route).
  Future<void> logout() => _storage.clearToken();
}
