import 'package:flutter/foundation.dart';

import '../../core/api_exception.dart';
import '../../data/models/comment.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';

enum DetailsStatus { idle, loading, loaded, error }

enum SubmitOutcome {
  /// Nothing was attempted (already submitting, or invalid input).
  ignored,

  /// Status saved and, if a note was given, comment saved too.
  /// Also used when a standalone `addComment` succeeds.
  fullSuccess,

  /// Status saved, comment failed. Preserve the note so the user can retry.
  partialSuccess,

  /// Status failed. Nothing was saved.
  failure,
}

class TaskDetailsProvider extends ChangeNotifier {
  TaskDetailsProvider(this._repo);

  final TaskRepository _repo;

  // ---- Load state ----
  DetailsStatus _status = DetailsStatus.idle;
  Task? _task;
  String? _error;
  int? _taskId;

  /// Bumped by every load and by [clear]. A response that comes back with
  /// an old token belongs to a replaced request and is dropped.
  int _loadToken = 0;

  // ---- Submit state ----
  bool _submitting = false;
  SubmitOutcome? _lastOutcome;
  String? _lastSubmitError;

  /// If a note failed to post after a successful status update, we keep
  /// it here so the UI can offer a retry. Cleared on successful retry.
  String? _pendingNote;

  /// True when the pending note failed with a network/timeout error: the
  /// server may have received it, so the UI warns before a manual retry.
  bool _pendingNoteMaybeSent = false;

  /// Locally-posted comments that the server hasn't yet reflected.
  /// Cleared whenever the task is re-fetched.
  final List<Comment> _localComments = [];

  // ---- Reads ----
  DetailsStatus get status => _status;
  Task? get task => _task;
  String? get error => _error;

  // ---- Submit getters ----
  bool get isSubmitting => _submitting;
  SubmitOutcome? get lastOutcome => _lastOutcome;
  String? get lastSubmitError => _lastSubmitError;
  String? get pendingNote => _pendingNote;
  bool get pendingNoteMaybeSent => _pendingNoteMaybeSent;

  /// All comments (server + local echo), newest-first.
  List<Comment> get comments {
    final list = [...?_task?.comments, ..._localComments];
    list.sort((a, b) {
      final at = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bt = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bt.compareTo(at);
    });
    return list;
  }

  /// Latest comment, or null if there are none.
  Comment? get latestComment {
    final list = comments;
    return list.isEmpty ? null : list.first;
  }

  // ---- Load ----

  /// Forgets everything (used when the session ends).
  void clear() {
    _loadToken++;
    _status = DetailsStatus.idle;
    _task = null;
    _taskId = null;
    _error = null;
    _submitting = false;
    _lastOutcome = null;
    _lastSubmitError = null;
    _pendingNote = null;
    _pendingNoteMaybeSent = false;
    _localComments.clear();
    notifyListeners();
  }

  Future<void> load(int taskId) async {
    final token = ++_loadToken;

    if (_taskId != taskId) {
      // Switching tasks: nothing from the previous one may leak into this
      // screen (task body, comment bar, local comments, retry note...).
      _task = null;
      _pendingNote = null;
      _pendingNoteMaybeSent = false;
      _lastOutcome = null;
      _lastSubmitError = null;
    }
    _taskId = taskId;
    _status = DetailsStatus.loading;
    _error = null;
    _localComments.clear();
    notifyListeners();

    try {
      final task = await _repo.fetchTask(taskId);
      if (token != _loadToken) return;
      _task = task;
      _status = DetailsStatus.loaded;
    } on ApiException catch (e) {
      if (token != _loadToken) return;
      _error = e.message;
      _status = DetailsStatus.error;
    }
    notifyListeners();
  }

  Future<void> reload() async {
    if (_taskId == null) return;
    await load(_taskId!);
  }

  // ---- Action: update status (with optional note) ----

  /// Saves [status]. If [note] is non-empty, posts it as a comment
  /// *after* the status update succeeds (spec §11).
  ///
  /// [authorName] is only used to attribute the local echo of the
  /// comment until the server's list replaces it.
  Future<SubmitOutcome> updateStatus({
    required String status,
    String? note,
    String? authorName,
  }) async {
    if (_submitting) return SubmitOutcome.ignored;
    final taskId = _taskId;
    if (taskId == null) return SubmitOutcome.ignored;

    _submitting = true;
    _lastOutcome = null;
    _lastSubmitError = null;
    _pendingNote = null;
    _pendingNoteMaybeSent = false;
    notifyListeners();

    // --- Step A: status update ---
    try {
      await _repo.updateStatus(taskId: taskId, status: status);
    } on ApiException catch (e) {
      _submitting = false;
      _lastOutcome = SubmitOutcome.failure;
      _lastSubmitError = e.message;
      notifyListeners();
      return SubmitOutcome.failure;
    }

    // --- Step B: optional comment ---
    final trimmed = note?.trim() ?? '';
    if (trimmed.isNotEmpty) {
      try {
        await _repo.addComment(taskId: taskId, content: trimmed);
        _echoComment(taskId, trimmed, authorName);
      } on ApiException catch (e) {
        // Status saved, comment failed. Preserve the note for retry.
        if (_taskId == taskId) {
          _pendingNote = trimmed;
          _pendingNoteMaybeSent = e.isNetworkError;
        }
        _submitting = false;
        _lastOutcome = SubmitOutcome.partialSuccess;
        _lastSubmitError = e.message;
        await _refreshQuietly();
        notifyListeners();
        return SubmitOutcome.partialSuccess;
      }
    }

    // --- Step C: full success ---
    _submitting = false;
    _lastOutcome = SubmitOutcome.fullSuccess;
    await _refreshQuietly();
    notifyListeners();
    return SubmitOutcome.fullSuccess;
  }

  // ---- Action: standalone comment ----

  /// Posts a comment without touching the status. Used by the
  /// "Add comment" button on the task details screen.
  Future<SubmitOutcome> addComment({
    required String content,
    String? authorName,
  }) async {
    if (_submitting) return SubmitOutcome.ignored;
    final taskId = _taskId;
    if (taskId == null) return SubmitOutcome.ignored;

    final trimmed = content.trim();
    if (trimmed.isEmpty) return SubmitOutcome.ignored;

    _submitting = true;
    _lastOutcome = null;
    _lastSubmitError = null;
    notifyListeners();

    try {
      await _repo.addComment(taskId: taskId, content: trimmed);
      _echoComment(taskId, trimmed, authorName);
      _submitting = false;
      _lastOutcome = SubmitOutcome.fullSuccess;
      notifyListeners();
      return SubmitOutcome.fullSuccess;
    } on ApiException catch (e) {
      _submitting = false;
      _lastOutcome = SubmitOutcome.failure;
      _lastSubmitError = e.message;
      notifyListeners();
      return SubmitOutcome.failure;
    }
  }

  // ---- Retry pending comment ----
  /// Retries only the pending comment from a previous partial success.
  /// Does not touch status.
  Future<SubmitOutcome> retryPendingComment({String? authorName}) async {
    final note = _pendingNote;
    if (note == null || note.isEmpty) return SubmitOutcome.ignored;
    final taskId = _taskId;
    if (_submitting || taskId == null) return SubmitOutcome.ignored;

    _submitting = true;
    _lastSubmitError = null;
    notifyListeners();

    try {
      await _repo.addComment(taskId: taskId, content: note);
      _echoComment(taskId, note, authorName);
      _pendingNote = null;
      _pendingNoteMaybeSent = false;
      _submitting = false;
      _lastOutcome = SubmitOutcome.fullSuccess;
      await _refreshQuietly();
      notifyListeners();
      return SubmitOutcome.fullSuccess;
    } on ApiException catch (e) {
      _submitting = false;
      _pendingNoteMaybeSent = e.isNetworkError;
      _lastOutcome = SubmitOutcome.partialSuccess;
      _lastSubmitError = e.message;
      notifyListeners();
      return SubmitOutcome.partialSuccess;
    }
  }

  /// Drops the note that failed to post (the user chose not to retry it).
  void discardPendingNote() {
    if (_pendingNote == null) return;
    _pendingNote = null;
    _pendingNoteMaybeSent = false;
    notifyListeners();
  }

  // ---- Helpers ----
  void clearOutcome() {
    _lastOutcome = null;
    _lastSubmitError = null;
    notifyListeners();
  }

  /// Shows a just-posted comment right away, but only if the screen is still
  /// on the task it was posted to.
  void _echoComment(int taskId, String content, String? authorName) {
    if (_taskId != taskId) return;
    _localComments.add(
      Comment(
        id: -1,
        content: content,
        authorName: authorName ?? 'You',
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Re-fetches the task without toggling loading/error state.
  Future<void> _refreshQuietly() async {
    final id = _taskId;
    if (id == null) return;
    final token = _loadToken;
    try {
      final task = await _repo.fetchTask(id);
      if (token != _loadToken) return;
      _task = task;
      _localComments.clear();
      _status = DetailsStatus.loaded;
    } on ApiException {
      // Silently ignore.
    }
  }
}
