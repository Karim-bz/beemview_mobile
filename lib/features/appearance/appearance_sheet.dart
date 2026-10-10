import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../shared/widgets/status_picker_sheet.dart' show SheetHandle;
import 'theme_provider.dart';
import '../../l10n/app_strings.dart';

/// Bottom sheet to choose between system, light and dark theme.
Future<void> showAppearanceSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (_) => const _AppearanceSheet(),
  );
}

class _AppearanceSheet extends StatelessWidget {
  const _AppearanceSheet();

  static IconData _iconFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHandle(),
          const SizedBox(height: 16),
          Text(
            context.l10n.appearance,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          for (final mode in ThemeMode.values)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(_iconFor(mode), color: AppColors.teal),
              title: Text(
                themeModeLabel(context.l10n, mode),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: provider.mode == mode
                  ? const Icon(Icons.check_rounded, color: AppColors.teal)
                  : null,
              onTap: () {
                provider.setMode(mode);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}
