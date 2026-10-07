import 'package:flutter/foundation.dart';

import '../../core/api_exception.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { unknown, unauthenticated, authenticated, sessionCheckFailed }

/// Holds the auth state and exposes login/logout/restore actions.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repo);

  final AuthRepository _repo;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  String? _error;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;

  /// Called once at startup. Restores the session if a token exists and
  /// is still valid; otherwise sends the user to login.
  Future<void> restoreSession() async {
    _status = AuthStatus.unknown;
    notifyListeners();

    // No saved token: go straight to login (works offline too).
    if (!await _repo.hasToken()) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      _user = await _repo.me();
      _status = AuthStatus.authenticated;
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        // Token is really invalid or expired: clear it.
        await _repo.logout();
        _user = null;
        _status = AuthStatus.unauthenticated;
      } else {
        // Offline, timeout, 5xx, 429...: keep the token, let the user retry.
        _error = e.message;
        _status = AuthStatus.sessionCheckFailed;
      }
    }
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
    required String subdomain,
  }) async {
    _error = null;
    try {
      _user = await _repo.login(
        email: email,
        password: password,
        subdomain: subdomain,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    _error = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Called by `ApiClient.onUnauthorized` when a request returns 401.
  Future<void> handleUnauthorized() async {
    if (_status == AuthStatus.unauthenticated) return;
    await logout();
  }
}
