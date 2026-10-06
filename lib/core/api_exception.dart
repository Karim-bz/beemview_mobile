/// check [statusCode] or [isNetworkError] result.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.isNetworkError = false});

  final String message;
  final int? statusCode;
  final bool isNetworkError;

  /// Return True when the session is invalid/expired and the user must log in again.
  bool get isUnauthorized => statusCode == 401;

  /// True when the user lacks permission (kept distinct from 401 per spec).
  bool get isForbidden => statusCode == 403;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
