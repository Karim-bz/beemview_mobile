import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../l10n/app_strings.dart';
import '../../shared/widgets/status_picker_sheet.dart' show SheetHandle;
import 'locale_provider.dart';

/// Bottom sheet to choose between system, English and Arabic.
Future<void> showLanguageSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (_) => const _LanguageSheet(),
  );
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet();

  static const _options = <Locale?>[null, Locale('en'), Locale('ar')];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocaleProvider>();
    final s = context.l10n;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHandle(),
          const SizedBox(height: 16),
          Text(
            s.language,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          for (final option in _options)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.language_rounded, color: AppColors.teal),
              title: Text(
                languageLabel(s, option),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: provider.locale?.languageCode == option?.languageCode
                  ? const Icon(Icons.check_rounded, color: AppColors.teal)
                  : null,
              onTap: () {
                provider.setLocale(option);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}
