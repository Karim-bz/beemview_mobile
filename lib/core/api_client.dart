import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'config.dart';
import 'connectivity_service.dart';
import 'secure_storage.dart';
import '../l10n/app_strings.dart';

/// Thin wrapper around Dio.
///
/// - Attaches the auth token to every request.
/// - Turns any error into [ApiException].
/// - Notifies [onUnauthorized] when the API returns 401.
class ApiClient {
  ApiClient({
    required this._storage,
    required this._connectivity,
    Dio? dio,
    AppStrings Function()? strings,
  }) : _dio = dio ?? Dio(),
       _strings = strings ?? (() => const AppStringsEn()) {
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
      ..headers = {'Accept': 'application/json'}
      ..validateStatus = (status) =>
          status != null && status >= 200 && status < 300;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept-Language'] = _acceptLanguage;
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final SecureStorageService _storage;
  final ConnectivityService _connectivity;
  final AppStrings Function() _strings;

  /// Texts in the current app language, for messages made in this layer.
  AppStrings get strings => _strings();

  /// Asks the server for messages in the app language (English as fallback).
  /// The app never depends on the wording of server messages.
  String get _acceptLanguage => _strings().languageCode == 'ar' ? 'ar' : 'en';

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
      throw ApiException(_strings().errOffline, isNetworkError: true);
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
      return ApiException(_strings().errTimeout, isNetworkError: true);
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return ApiException(_strings().errUnreachable, isNetworkError: true);
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
    final s = _strings();
    switch (status) {
      case 400:
        return s.errBadRequest;
      case 401:
        return s.errSessionExpired;
      case 403:
        return s.errForbidden;
      case 404:
        return s.errNotFound;
      case 429:
        return s.errTooMany;
      default:
        return s.errGeneric;
    }
  }
}
