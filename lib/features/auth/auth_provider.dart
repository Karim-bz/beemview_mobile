import 'package:flutter/foundation.dart';

import '../../core/api_exception.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

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
    try {
      final user = await _repo.me();
      _user = user;
      _status = AuthStatus.authenticated;
    } on ApiException {
      // Any failure means we can't trust the stored token.
      await _repo.logout();
      _user = null;
      _status = AuthStatus.unauthenticated;
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
