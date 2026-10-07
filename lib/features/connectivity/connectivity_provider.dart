import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/connectivity_service.dart';

/// Holds the current connectivity state for the whole app.
class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider(this._service);

  final ConnectivityService _service;
  StreamSubscription<bool>? _sub;

  bool _online = true;
  bool get isOnline => _online;
  bool _started = false;

  /// Call once at startup. Listens for changes and updates [isOnline].
  Future<void> initialize() async {
    if (_started) return;
    _started = true;

    try {
      _online = await _service.isOnline();
    } catch (_) {
      _online = true; // don't show a false offline banner if the check fails
    }
    notifyListeners();

    _sub = _service.onStatusChange.listen((online) {
      if (online != _online) {
        _online = online;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
