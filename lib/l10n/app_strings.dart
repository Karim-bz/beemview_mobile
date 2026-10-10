import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/widgets.dart';

/// All the texts of the app, in English and Arabic.
///
/// Use `context.l10n.retry` in widgets. Outside widgets, ask the
/// `LocaleProvider` (or `ApiClient`) for the current [AppStrings].
/// Adding a text: add it to the abstract class below and to BOTH languages,
/// the compiler will complain if one language is missing.
abstract class AppStrings {
  const AppStrings();

  static const supportedLocales = [Locale('en'), Locale('ar')];
  static const LocalizationsDelegate<AppStrings> delegate =
      _AppStringsDelegate();

  static AppStrings forLocale(Locale locale) => locale.languageCode == 'ar'
      ? const AppStringsAr()
      : const AppStringsEn();

  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings) ??
      const AppStringsEn();

  /// `en` or `ar`.
  String get languageCode;

  // ---- Texts (implemented by each language) ----
  String get retry;
  String get cancel;
  String get send;
  String get signOut;
  String get signIn;
  String get all;
  String get today;
  String get tomorrow;
  String get yesterday;
  String get notSet;
  String get unknown;
  String get you;
  String get status;
  String get priority;
  String get start;
  String get end;
  String get due;
  String get project;
  String get assignees;
  String get timeline;
  String get descriptionOptional;
  String get somethingWentWrong;
  String get noInternet;
  String comingSoon(String what);
  String get navProjects;
  String get navTasks;
  String get navNotifications;
  String get navProfile;
  String get justNow;
  String minutesAgo(int n);
  String hoursAgo(int n);
  String daysAgo(int n);
  String daysShort(int n);
  String daysOverdue(int n);
  String daysLeft(int n);
  String get dueToday;
  String taskCount(int n);
  String dueTodayCount(int n);
  String openCount(int n);
  String doneOfTasks(int done, int total);
  String doneSelected(int n);
  String dateLong(DateTime d);
  String dateShort(DateTime d);
  String get goodMorning;
  String get goodAfternoon;
  String get goodEvening;
  String greetingNamed(int hour, String name);
  String get statusPlanning;
  String get statusToDo;
  String get statusInProgress;
  String get statusReview;
  String get statusOnHold;
  String get statusDone;
  String get statusBlocked;
  String get statusChangesRequested;
  String get statusChangesShort;
  String get statusCanceled;
  String get priorityUrgent;
  String get priorityHigh;
  String get priorityMedium;
  String get priorityLow;
  String get overdue;
  String get thisWeek;
  String get later;
  String get earlier;
  String get noDueDate;
  String get upcoming;
  String get emailRequired;
  String get emailInvalid;
  String get passwordRequired;
  String get passwordTooShort;
  String get loginFailed;
  String get signingIn;
  String get loginTagline;
  String get emailHint;
  String get passwordHint;
  String get forgotPassword;
  String get passwordReset;
  String get sessionVerifyFailed;
  String get loginNoToken;
  String get errOffline;
  String get errTimeout;
  String get errUnreachable;
  String get errBadRequest;
  String get errSessionExpired;
  String get errForbidden;
  String get errNotFound;
  String get errTooMany;
  String get errGeneric;
  String get allCaughtUp;
  String get notificationsHint;
  String get viewMyTasks;
  String get unknownUser;
  String get appearance;
  String get language;
  String get version;
  String get notificationSettings;
  String get advancedFilters;
  String get assigningPeople;
  String get themeSystem;
  String get themeLight;
  String get themeDark;
  String get searchProjects;
  String get loadingProjects;
  String get failedLoadProjects;
  String get noProjects;
  String get noProjectsMatch;
  String get loadMore;
  String get projectCreated;
  String get noTasksYet;
  String get newProject;
  String get projectName;
  String get projectNameHint;
  String get organizationalUnit;
  String get endAfterStart;
  String get projectDescriptionHint;
  String get createProject;
  String get unitIdHint;
  String get selectUnit;
  String get selectUnitError;
  String get projectNameRequired;
  String get nameTooShort;
  String get unitIdRequired;
  String get validNumber;
  String get startDate;
  String get endDate;
  String get newTask;
  String get taskName;
  String get taskNameHint;
  String get dueDate;
  String get dueAfterStart;
  String get taskDescriptionHint;
  String get createTask;
  String get privateTask;
  String get assignPeople;
  String get doneButton;
  String get taskNameRequired;
  String get taskCreated;
  String get filterCaption;
  String get filterHint;
  String get loadingTasks;
  String get failedLoadTasks;
  String get projectNoTasks;
  String get noTasksMatch;
  String get projectLabel;
  String get nextDeadline;
  String get nothingOnPlate;
  String get tasksEmptyHint;
  String get browseProjects;
  String get saved;
  String get noteNotSentYet;
  String get statusSavedNoteFailed;
  String get taskDetails;
  String get loadingTask;
  String get failedLoadTask;
  String get taskNotFound;
  String get noDescription;
  String get comments;
  String get noCommentsYet;
  String get assign;
  String get writeComment;
  String get noteNotSentTitle;
  String get noteMaybeDelivered;
  String get discardNote;
  String get retryNote;
  String get updateStatus;
  String get addNoteHint;
  String get saveStatus;
  String get changeStatus;
  String get addComment;
  String get writeCommentHint;

  // ---- Shared helpers (same logic for every language) ----

  /// Label of a task/project status (raw API value in, text out).
  String statusLabel(String? status) {
    switch (status) {
      case 'planning':
        return statusPlanning;
      case 'to_do':
        return statusToDo;
      case 'in_progress':
        return statusInProgress;
      case 'review':
        return statusReview;
      case 'on_hold':
        return statusOnHold;
      case 'done':
        return statusDone;
      case 'blocked':
        return statusBlocked;
      case 'changes_requested':
        return statusChangesRequested;
      case 'canceled':
        return statusCanceled;
      default:
        if (status == null || status.isEmpty) return '—';
        final spaced = status.replaceAll('_', ' ');
        return spaced[0].toUpperCase() + spaced.substring(1);
    }
  }

  /// Compact label for tight chips.
  String statusShortLabel(String? status) =>
      status == 'changes_requested' ? statusChangesShort : statusLabel(status);

  /// Label of a priority (`low`, `medium`, `high`, `urgent`).
  String priorityLabel(String p) {
    switch (p.toLowerCase()) {
      case 'urgent':
        return priorityUrgent;
      case 'high':
        return priorityHigh;
      case 'medium':
        return priorityMedium;
      case 'low':
        return priorityLow;
      default:
        return p.isEmpty ? '—' : p[0].toUpperCase() + p.substring(1).toLowerCase();
    }
  }

  /// "44m ago", "2h ago", "3d ago", or a short date.
  String relTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return justNow;
    if (diff.inHours < 1) return minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return hoursAgo(diff.inHours);
    if (diff.inDays < 7) return daysAgo(diff.inDays);
    return dateShort(dt);
  }

  /// "Good morning" / "Good afternoon" / "Good evening".
  String greeting(int hour) {
    if (hour < 12) return goodMorning;
    if (hour < 18) return goodAfternoon;
    return goodEvening;
  }
}

const _enMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

const _arMonths = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

/// Arabic counting: 1 and 2 have their own words, 3-10 use the plural,
/// and 11+ use the singular after the number.
String _arCount(
  int n, {
  required String one,
  required String two,
  required String few,
  required String many,
}) {
  if (n == 1) return one;
  if (n == 2) return two;
  if (n >= 3 && n <= 10) return '$n $few';
  return '$n $many';
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'ar';

  @override
  Future<AppStrings> load(Locale locale) =>
      SynchronousFuture<AppStrings>(AppStrings.forLocale(locale));

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}

/// Short access: `context.l10n.retry`.
extension AppStringsContext on BuildContext {
  AppStrings get l10n => AppStrings.of(this);
}

class AppStringsEn extends AppStrings {
  const AppStringsEn();

  @override
  String get languageCode => 'en';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get send => 'Send';

  @override
  String get signOut => 'Sign out';

  @override
  String get signIn => 'Sign in';

  @override
  String get all => 'All';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get notSet => 'Not set';

  @override
  String get unknown => 'Unknown';

  @override
  String get you => 'You';

  @override
  String get status => 'Status';

  @override
  String get priority => 'Priority';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get due => 'Due';

  @override
  String get project => 'Project';

  @override
  String get assignees => 'Assignees';

  @override
  String get timeline => 'Timeline';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get somethingWentWrong => 'Something went wrong.';

  @override
  String get noInternet => 'No internet connection';

  @override
  String comingSoon(String what) => '$what — coming soon';

  @override
  String get navProjects => 'Projects';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navProfile => 'Profile';

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(int n) => '${n}m ago';

  @override
  String hoursAgo(int n) => '${n}h ago';

  @override
  String daysAgo(int n) => '${n}d ago';

  @override
  String daysShort(int n) => '${n}d';

  @override
  String daysOverdue(int n) => '$n day${n == 1 ? '' : 's'} overdue';

  @override
  String daysLeft(int n) => '$n day${n == 1 ? '' : 's'} left';

  @override
  String get dueToday => 'Due today';

  @override
  String taskCount(int n) => '$n task${n == 1 ? '' : 's'}';

  @override
  String dueTodayCount(int n) => '$n due today';

  @override
  String openCount(int n) => '$n open';

  @override
  String doneOfTasks(int done, int total) => '$done of $total tasks done';

  @override
  String doneSelected(int n) => 'Done ($n selected)';

  @override
  String dateLong(DateTime d) => '${_enMonths[d.month - 1]} ${d.day}, ${d.year}';

  @override
  String dateShort(DateTime d) => '${_enMonths[d.month - 1]} ${d.day}';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String greetingNamed(int hour, String name) => '${greeting(hour)}, $name 👋';

  @override
  String get statusPlanning => 'Planning';

  @override
  String get statusToDo => 'To do';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusReview => 'Review';

  @override
  String get statusOnHold => 'Paused';

  @override
  String get statusDone => 'Completed';

  @override
  String get statusBlocked => 'Blocked';

  @override
  String get statusChangesRequested => 'Changes requested';

  @override
  String get statusChangesShort => 'Changes';

  @override
  String get statusCanceled => 'Canceled';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get overdue => 'Overdue';

  @override
  String get thisWeek => 'This week';

  @override
  String get later => 'Later';

  @override
  String get earlier => 'Earlier';

  @override
  String get noDueDate => 'No due date';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get loginFailed => 'Login failed. Please try again.';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get loginTagline => 'Manage your projects,\nget things done.';

  @override
  String get emailHint => 'Email address';

  @override
  String get passwordHint => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get passwordReset => 'Password reset';

  @override
  String get sessionVerifyFailed => 'Could not verify your session.';

  @override
  String get loginNoToken => 'Login response did not include a token.';

  @override
  String get errOffline => 'You appear to be offline. Check your connection and try again.';

  @override
  String get errTimeout => 'Request timed out. Please try again.';

  @override
  String get errUnreachable => 'Could not reach the server. Check your connection and try again.';

  @override
  String get errBadRequest => 'The request was invalid.';

  @override
  String get errSessionExpired => 'Session expired. Please sign in again.';

  @override
  String get errForbidden => 'You do not have access to this resource.';

  @override
  String get errNotFound => 'The requested resource was not found.';

  @override
  String get errTooMany => 'Too many requests. Please try again later.';

  @override
  String get errGeneric => 'Something went wrong. Please try again.';

  @override
  String get allCaughtUp => 'You\'re all caught up';

  @override
  String get notificationsHint => 'Comments, status changes and new\nassignments will show up here.';

  @override
  String get viewMyTasks => 'View my tasks';

  @override
  String get unknownUser => 'Unknown user';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get version => 'Version';

  @override
  String get notificationSettings => 'Notification settings';

  @override
  String get advancedFilters => 'Advanced filters';

  @override
  String get assigningPeople => 'Assigning people';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get searchProjects => 'Search projects...';

  @override
  String get loadingProjects => 'Loading projects...';

  @override
  String get failedLoadProjects => 'Failed to load projects.';

  @override
  String get noProjects => 'No projects available yet.';

  @override
  String get noProjectsMatch => 'No projects match your filters.';

  @override
  String get loadMore => 'Load more';

  @override
  String get projectCreated => 'Project created';

  @override
  String get noTasksYet => 'No tasks yet';

  @override
  String get newProject => 'New project';

  @override
  String get projectName => 'Project name';

  @override
  String get projectNameHint => 'e.g. Website redesign';

  @override
  String get organizationalUnit => 'Organizational unit';

  @override
  String get endAfterStart => 'End date must be after start';

  @override
  String get projectDescriptionHint => 'What is this project about?';

  @override
  String get createProject => 'Create project';

  @override
  String get unitIdHint => 'Unit ID (e.g. 71)';

  @override
  String get selectUnit => 'Select a unit';

  @override
  String get selectUnitError => 'Select an organizational unit';

  @override
  String get projectNameRequired => 'Project name is required';

  @override
  String get nameTooShort => 'Name must be at least 3 characters';

  @override
  String get unitIdRequired => 'Organizational unit ID is required';

  @override
  String get validNumber => 'Enter a valid number';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get newTask => 'New task';

  @override
  String get taskName => 'Task name';

  @override
  String get taskNameHint => 'e.g. Create employee module';

  @override
  String get dueDate => 'Due date';

  @override
  String get dueAfterStart => 'Due date must be after start';

  @override
  String get taskDescriptionHint => 'What needs to be done?';

  @override
  String get createTask => 'Create task';

  @override
  String get privateTask => 'Private task';

  @override
  String get assignPeople => 'Assign people';

  @override
  String get doneButton => 'Done';

  @override
  String get taskNameRequired => 'Task name is required';

  @override
  String get taskCreated => 'Task created';

  @override
  String get filterCaption => 'Filtering the tasks already loaded for this project';

  @override
  String get filterHint => 'Filter loaded tasks by name...';

  @override
  String get loadingTasks => 'Loading tasks...';

  @override
  String get failedLoadTasks => 'Failed to load tasks.';

  @override
  String get projectNoTasks => 'This project has no tasks yet.';

  @override
  String get noTasksMatch => 'No tasks match your filters.';

  @override
  String get projectLabel => 'PROJECT';

  @override
  String get nextDeadline => 'Next deadline';

  @override
  String get nothingOnPlate => 'Nothing on your plate';

  @override
  String get tasksEmptyHint => 'Tasks assigned to you will show up here.\nPick a project to get started.';

  @override
  String get browseProjects => 'Browse projects';

  @override
  String get saved => 'Saved';

  @override
  String get noteNotSentYet => 'The note could not be sent yet.';

  @override
  String get statusSavedNoteFailed => 'Status saved, but the note failed to send.';

  @override
  String get taskDetails => 'Task details';

  @override
  String get loadingTask => 'Loading task...';

  @override
  String get failedLoadTask => 'Failed to load task.';

  @override
  String get taskNotFound => 'Task not found.';

  @override
  String get noDescription => 'No description provided.';

  @override
  String get comments => 'Comments';

  @override
  String get noCommentsYet => 'No comments yet.';

  @override
  String get assign => 'Assign';

  @override
  String get writeComment => 'Write a comment...';

  @override
  String get noteNotSentTitle => 'Status saved, but your note was not sent';

  @override
  String get noteMaybeDelivered => 'The connection dropped, so the note may have been delivered. Pull to refresh and check the comments before retrying.';

  @override
  String get discardNote => 'Discard note';

  @override
  String get retryNote => 'Retry note';

  @override
  String get updateStatus => 'Update status';

  @override
  String get addNoteHint => 'Add a note (optional). Posted as a comment.';

  @override
  String get saveStatus => 'Save status';

  @override
  String get changeStatus => 'Change status';

  @override
  String get addComment => 'Add a comment';

  @override
  String get writeCommentHint => 'Write your comment...';
}

class AppStringsAr extends AppStrings {
  const AppStringsAr();

  @override
  String get languageCode => 'ar';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get send => 'إرسال';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get all => 'الكل';

  @override
  String get today => 'اليوم';

  @override
  String get tomorrow => 'غدًا';

  @override
  String get yesterday => 'أمس';

  @override
  String get notSet => 'غير محدد';

  @override
  String get unknown => 'غير معروف';

  @override
  String get you => 'أنت';

  @override
  String get status => 'الحالة';

  @override
  String get priority => 'الأولوية';

  @override
  String get start => 'البداية';

  @override
  String get end => 'النهاية';

  @override
  String get due => 'الاستحقاق';

  @override
  String get project => 'المشروع';

  @override
  String get assignees => 'المكلّفون';

  @override
  String get timeline => 'الجدول الزمني';

  @override
  String get descriptionOptional => 'الوصف (اختياري)';

  @override
  String get somethingWentWrong => 'حدث خطأ ما.';

  @override
  String get noInternet => 'لا يوجد اتصال بالإنترنت';

  @override
  String comingSoon(String what) => '$what — قريبًا';

  @override
  String get navProjects => 'المشاريع';

  @override
  String get navTasks => 'المهام';

  @override
  String get navNotifications => 'الإشعارات';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(int n) => 'منذ ' + _arCount(n, one: 'دقيقة', two: 'دقيقتين', few: 'دقائق', many: 'دقيقة');

  @override
  String hoursAgo(int n) => 'منذ ' + _arCount(n, one: 'ساعة', two: 'ساعتين', few: 'ساعات', many: 'ساعة');

  @override
  String daysAgo(int n) => 'منذ ' + _arCount(n, one: 'يوم', two: 'يومين', few: 'أيام', many: 'يومًا');

  @override
  String daysShort(int n) => '$n يوم';

  @override
  String daysOverdue(int n) => 'متأخرة ' + _arCount(n, one: 'يوم واحد', two: 'يومان', few: 'أيام', many: 'يومًا');

  @override
  String daysLeft(int n) => 'متبقٍ ' + _arCount(n, one: 'يوم واحد', two: 'يومان', few: 'أيام', many: 'يومًا');

  @override
  String get dueToday => 'مستحقة اليوم';

  @override
  String taskCount(int n) => _arCount(n, one: 'مهمة واحدة', two: 'مهمتان', few: 'مهام', many: 'مهمة');

  @override
  String dueTodayCount(int n) => '$n مستحقة اليوم';

  @override
  String openCount(int n) => '$n مفتوحة';

  @override
  String doneOfTasks(int done, int total) => '$done من $total مهمة مكتملة';

  @override
  String doneSelected(int n) => 'تم ($n محدد)';

  @override
  String dateLong(DateTime d) => '${d.day} ${_arMonths[d.month - 1]} ${d.year}';

  @override
  String dateShort(DateTime d) => '${d.day} ${_arMonths[d.month - 1]}';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String greetingNamed(int hour, String name) => '${greeting(hour)}، $name 👋';

  @override
  String get statusPlanning => 'التخطيط';

  @override
  String get statusToDo => 'للتنفيذ';

  @override
  String get statusInProgress => 'قيد التنفيذ';

  @override
  String get statusReview => 'قيد المراجعة';

  @override
  String get statusOnHold => 'متوقفة';

  @override
  String get statusDone => 'مكتملة';

  @override
  String get statusBlocked => 'معطّلة';

  @override
  String get statusChangesRequested => 'مطلوب تعديلات';

  @override
  String get statusChangesShort => 'تعديلات';

  @override
  String get statusCanceled => 'ملغاة';

  @override
  String get priorityUrgent => 'عاجلة';

  @override
  String get priorityHigh => 'عالية';

  @override
  String get priorityMedium => 'متوسطة';

  @override
  String get priorityLow => 'منخفضة';

  @override
  String get overdue => 'متأخرة';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get later => 'لاحقًا';

  @override
  String get earlier => 'سابقًا';

  @override
  String get noDueDate => 'بلا موعد';

  @override
  String get upcoming => 'القادمة';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get emailInvalid => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get passwordTooShort => 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';

  @override
  String get loginFailed => 'فشل تسجيل الدخول. حاول مرة أخرى.';

  @override
  String get signingIn => 'جارٍ تسجيل الدخول...';

  @override
  String get loginTagline => 'أدِر مشاريعك،\nوأنجز مهامك.';

  @override
  String get emailHint => 'البريد الإلكتروني';

  @override
  String get passwordHint => 'كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get passwordReset => 'استعادة كلمة المرور';

  @override
  String get sessionVerifyFailed => 'تعذّر التحقق من جلستك.';

  @override
  String get loginNoToken => 'لم يتضمن ردّ تسجيل الدخول رمزًا.';

  @override
  String get errOffline => 'يبدو أنك غير متصل. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get errTimeout => 'انتهت مهلة الطلب. حاول مرة أخرى.';

  @override
  String get errUnreachable => 'تعذّر الوصول إلى الخادم. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get errBadRequest => 'الطلب غير صالح.';

  @override
  String get errSessionExpired => 'انتهت الجلسة. سجّل الدخول مرة أخرى.';

  @override
  String get errForbidden => 'ليست لديك صلاحية الوصول إلى هذا المورد.';

  @override
  String get errNotFound => 'المورد المطلوب غير موجود.';

  @override
  String get errTooMany => 'طلبات كثيرة جدًا. حاول لاحقًا.';

  @override
  String get errGeneric => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get allCaughtUp => 'لا جديد لديك';

  @override
  String get notificationsHint => 'ستظهر هنا التعليقات وتغييرات الحالة\nوالمهام الجديدة.';

  @override
  String get viewMyTasks => 'عرض مهامي';

  @override
  String get unknownUser => 'مستخدم غير معروف';

  @override
  String get appearance => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get version => 'الإصدار';

  @override
  String get notificationSettings => 'إعدادات الإشعارات';

  @override
  String get advancedFilters => 'عوامل تصفية متقدمة';

  @override
  String get assigningPeople => 'تعيين الأشخاص';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get searchProjects => 'ابحث في المشاريع...';

  @override
  String get loadingProjects => 'جارٍ تحميل المشاريع...';

  @override
  String get failedLoadProjects => 'تعذّر تحميل المشاريع.';

  @override
  String get noProjects => 'لا توجد مشاريع بعد.';

  @override
  String get noProjectsMatch => 'لا توجد مشاريع تطابق عوامل التصفية.';

  @override
  String get loadMore => 'تحميل المزيد';

  @override
  String get projectCreated => 'تم إنشاء المشروع';

  @override
  String get noTasksYet => 'لا توجد مهام بعد';

  @override
  String get newProject => 'مشروع جديد';

  @override
  String get projectName => 'اسم المشروع';

  @override
  String get projectNameHint => 'مثال: إعادة تصميم الموقع';

  @override
  String get organizationalUnit => 'الوحدة التنظيمية';

  @override
  String get endAfterStart => 'يجب أن يكون تاريخ النهاية بعد البداية';

  @override
  String get projectDescriptionHint => 'ما موضوع هذا المشروع؟';

  @override
  String get createProject => 'إنشاء المشروع';

  @override
  String get unitIdHint => 'معرّف الوحدة (مثال: 71)';

  @override
  String get selectUnit => 'اختر وحدة';

  @override
  String get selectUnitError => 'اختر وحدة تنظيمية';

  @override
  String get projectNameRequired => 'اسم المشروع مطلوب';

  @override
  String get nameTooShort => 'يجب أن يتكون الاسم من 3 أحرف على الأقل';

  @override
  String get unitIdRequired => 'معرّف الوحدة التنظيمية مطلوب';

  @override
  String get validNumber => 'أدخل رقمًا صالحًا';

  @override
  String get startDate => 'تاريخ البداية';

  @override
  String get endDate => 'تاريخ النهاية';

  @override
  String get newTask => 'مهمة جديدة';

  @override
  String get taskName => 'اسم المهمة';

  @override
  String get taskNameHint => 'مثال: إنشاء وحدة الموظفين';

  @override
  String get dueDate => 'تاريخ الاستحقاق';

  @override
  String get dueAfterStart => 'يجب أن يكون تاريخ الاستحقاق بعد البداية';

  @override
  String get taskDescriptionHint => 'ما المطلوب إنجازه؟';

  @override
  String get createTask => 'إنشاء المهمة';

  @override
  String get privateTask => 'مهمة خاصة';

  @override
  String get assignPeople => 'تعيين الأشخاص';

  @override
  String get doneButton => 'تم';

  @override
  String get taskNameRequired => 'اسم المهمة مطلوب';

  @override
  String get taskCreated => 'تم إنشاء المهمة';

  @override
  String get filterCaption => 'تصفية المهام المحمّلة لهذا المشروع فقط';

  @override
  String get filterHint => 'صفِّ المهام المحمّلة بالاسم...';

  @override
  String get loadingTasks => 'جارٍ تحميل المهام...';

  @override
  String get failedLoadTasks => 'تعذّر تحميل المهام.';

  @override
  String get projectNoTasks => 'لا توجد مهام في هذا المشروع بعد.';

  @override
  String get noTasksMatch => 'لا توجد مهام تطابق عوامل التصفية.';

  @override
  String get projectLabel => 'المشروع';

  @override
  String get nextDeadline => 'الموعد القادم';

  @override
  String get nothingOnPlate => 'لا شيء في قائمتك';

  @override
  String get tasksEmptyHint => 'ستظهر هنا المهام المسندة إليك.\nاختر مشروعًا للبدء.';

  @override
  String get browseProjects => 'تصفّح المشاريع';

  @override
  String get saved => 'تم الحفظ';

  @override
  String get noteNotSentYet => 'تعذّر إرسال الملاحظة بعد.';

  @override
  String get statusSavedNoteFailed => 'تم حفظ الحالة، لكن تعذّر إرسال الملاحظة.';

  @override
  String get taskDetails => 'تفاصيل المهمة';

  @override
  String get loadingTask => 'جارٍ تحميل المهمة...';

  @override
  String get failedLoadTask => 'تعذّر تحميل المهمة.';

  @override
  String get taskNotFound => 'المهمة غير موجودة.';

  @override
  String get noDescription => 'لا يوجد وصف.';

  @override
  String get comments => 'التعليقات';

  @override
  String get noCommentsYet => 'لا توجد تعليقات بعد.';

  @override
  String get assign => 'تعيين';

  @override
  String get writeComment => 'اكتب تعليقًا...';

  @override
  String get noteNotSentTitle => 'تم حفظ الحالة، لكن لم يتم إرسال ملاحظتك';

  @override
  String get noteMaybeDelivered => 'انقطع الاتصال، وقد تكون الملاحظة وصلت. اسحب للتحديث وتحقق من التعليقات قبل إعادة المحاولة.';

  @override
  String get discardNote => 'تجاهل الملاحظة';

  @override
  String get retryNote => 'إعادة إرسال الملاحظة';

  @override
  String get updateStatus => 'تحديث الحالة';

  @override
  String get addNoteHint => 'أضف ملاحظة (اختياري). تُنشر كتعليق.';

  @override
  String get saveStatus => 'حفظ الحالة';

  @override
  String get changeStatus => 'تغيير الحالة';

  @override
  String get addComment => 'إضافة تعليق';

  @override
  String get writeCommentHint => 'اكتب تعليقك...';
}
