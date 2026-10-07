import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'config.dart';
import 'connectivity_service.dart';
import 'secure_storage.dart';

/// Thin wrapper around Dio.
///
/// - Attaches the auth token to every request.
/// - Turns any error into [ApiException].
/// - Notifies [onUnauthorized] when the API returns 401.
class ApiClient {
  ApiClient({
    required SecureStorageService storage,
    required ConnectivityService connectivity,
    Dio? dio,
  }) : _storage = storage,
       _connectivity = connectivity,
       _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = AppConfig.apiBaseUrl
      ..connectTimeout = const Duration(
        milliseconds: AppConfig.connectTimeoutMs,
      )
      ..receiveTimeout = const Duration(
        milliseconds: AppConfig.receiveTimeoutMs,
      )
      ..sendTimeout = const Duration(milliseconds: AppConfig.sendTimeoutMs)
      ..contentType = Headers.jsonContentType
      ..headers = {'Accept': 'application/json', 'Accept-Language': 'en'}
      ..validateStatus = (status) =>
          status != null && status >= 200 && status < 300;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final SecureStorageService _storage;
  final ConnectivityService _connectivity;

  /// Called when a request returns 401. The auth layer sets this so it
  /// can clear the session and send the user back to login.
  void Function()? onUnauthorized;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get<T>(path, queryParameters: query));

  Future<Response<T>> post<T>(String path, {Object? data}) =>
      _send(() => _dio.post<T>(path, data: data));

  Future<Response<T>> put<T>(String path, {Object? data}) =>
      _send(() => _dio.put<T>(path, data: data));

  Future<Response<T>> _send<T>(Future<Response<T>> Function() request) async {
    // Fail fast if there's no network interface at all.
    if (!await _connectivity.isOnline()) {
      throw ApiException(
        'You appear to be offline. Check your connection and try again.',
        isNetworkError: true,
      );
    }

    try {
      return await request();
    } on DioException catch (e) {
      final apiError = _toApiException(e);
      if (apiError.isUnauthorized) onUnauthorized?.call();
      throw apiError;
    }
  }

  ApiException _toApiException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        'Request timed out. Please try again.',
        isNetworkError: true,
      );
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return ApiException(
        'Could not reach the server. Check your connection and try again.',
        isNetworkError: true,
      );
    }

    final status = e.response?.statusCode;
    final message = _messageFrom(e.response?.data) ?? _defaultMessage(status);
    return ApiException(message, statusCode: status);
  }

  String? _messageFrom(Object? data) {
    if (data is Map) {
      final err = data['error'];
      if (err is String && err.isNotEmpty) return err;
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return null;
  }

  String _defaultMessage(int? status) {
    switch (status) {
      case 400:
        return 'The request was invalid.';
      case 401:
        return 'Session expired. Please sign in again.';
      case 403:
        return 'You do not have access to this resource.';
      case 404:
        return 'The requested resource was not found.';
      case 429:
        return 'Too many requests. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
