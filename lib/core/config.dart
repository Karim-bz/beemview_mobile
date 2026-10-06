import 'config.local.dart';

class AppConfig {
  const AppConfig._();
  static const String apiOrigin = AppConfigLocal.apiOrigin;

  /// Tenant subdomain used at login (required).
  static const String tenantSubdomain = AppConfigLocal.tenantSubdomain;

  /// Full API base URL
  static String get apiBaseUrl => '$apiOrigin/api';

  /// Network timeouts (milliseconds)
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 20000;
  static const int sendTimeoutMs = 20000;
}
