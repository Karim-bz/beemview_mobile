import '../../core/api_client.dart';
import '../../core/api_exception.dart';
import '../../core/api_paths.dart';
import '../../core/secure_storage.dart';
import '../models/user.dart';

/// Handles login, current user lookup, and session persistence.
class AuthRepository {
  AuthRepository({required this._api, required this._storage});

  final ApiClient _api;
  final SecureStorageService _storage;

  /// Logs in and stores the returned token. Throws [ApiException] on failure.
  Future<User> login({
    required String email,
    required String password,
    required String subdomain,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      ApiPaths.login,
      data: {'email': email, 'password': password, 'subdomain': subdomain},
    );

    final body = res.data ?? {};
    final token = body['token'] as String?;
    if (token == null || token.isEmpty) {
      throw ApiException(_api.strings.loginNoToken);
    }
    await _storage.saveToken(token);

    final userJson = (body['user'] as Map?)?.cast<String, dynamic>() ?? {};
    return User.fromJson(userJson);
  }

  /// Fetches the current user using the stored token.
  /// Throws [ApiException] on failure.
  Future<User> me() async {
    final res = await _api.get<Map<String, dynamic>>(ApiPaths.connectedUser);
    final userJson = (res.data?['user'] as Map?)?.cast<String, dynamic>() ?? {};
    return User.fromJson(userJson);
  }

  /// Clears the local token. No server call (spec: no logout route).
  Future<void> logout() => _storage.clearToken();

  Future<bool> hasToken() async {
    final t = await _storage.readToken();
    return t != null && t.isNotEmpty;
  }
}
