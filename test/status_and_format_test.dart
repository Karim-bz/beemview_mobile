import 'package:beemview_mobile/core/format.dart';
import 'package:beemview_mobile/core/status_labels.dart';
import 'package:beemview_mobile/l10n/app_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const en = AppStringsEn();

  group('StatusLabels.label', () {
    test('every API status value has a readable label', () {
      const apiValues = [
        'to_do',
        'in_progress',
        'on_hold',
        'review',
        'changes_requested',
        'blocked',
        'done',
        'canceled',
      ];

      for (final value in apiValues) {
        final label = StatusLabels.label(en, value);
        expect(label, isNotEmpty, reason: value);
        expect(label, isNot(value), reason: '$value must not show raw');
      }
    });

    test('maps the multi-word statuses', () {
      expect(StatusLabels.label(en, 'to_do'), 'To do');
      expect(StatusLabels.label(en, 'in_progress'), 'In progress');
      expect(StatusLabels.label(en, 'changes_requested'), 'Changes requested');
    });

    test('shows a dash for null or empty values', () {
      expect(StatusLabels.label(en, null), '—');
      expect(StatusLabels.label(en, ''), '—');
    });

    test('humanizes an unknown status instead of crashing', () {
      expect(StatusLabels.label(en, 'needs_review'), 'Needs review');
    });
  });

  group('isClosedStatus', () {
    test('only done and canceled are closed', () {
      expect(isClosedStatus('done'), isTrue);
      expect(isClosedStatus('canceled'), isTrue);
      expect(isClosedStatus('in_progress'), isFalse);
      expect(isClosedStatus('blocked'), isFalse);
      expect(isClosedStatus(null), isFalse);
    });
  });

  group('daysUntil', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    test('returns null when there is no due date', () {
      expect(daysUntil(null), isNull);
    });

    test('is 0 today, positive in the future, negative when overdue', () {
      expect(daysUntil(today), 0);
      expect(daysUntil(DateTime(today.year, today.month, today.day + 3)), 3);
      expect(daysUntil(DateTime(today.year, today.month, today.day - 2)), -2);
    });
  });
}
