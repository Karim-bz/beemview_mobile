import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/initials_avatar.dart';
import '../appearance/appearance_sheet.dart';
import '../appearance/language_sheet.dart';
import '../appearance/locale_provider.dart';
import '../appearance/theme_provider.dart';
import '../auth/auth_provider.dart';
import '../projects/projects_provider.dart';
import '../../l10n/app_strings.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _comingSoon(BuildContext context, String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.comingSoon(what))));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final stats = context.watch<ProjectsProvider>().statsFor(user?.id);

    return Scaffold(
      backgroundColor: context.palette.canvas,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            Text(
              context.l10n.navProfile,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 16),
            _HeroCard(
              name: user?.fullName ?? context.l10n.unknownUser,
              email: user?.email,
              initials: user == null
                  ? '?'
                  : InitialsAvatar.initialsOf(user.fullName),
              stats: stats,
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.notifications_none_rounded,
                    color: AppColors.teal,
                    label: context.l10n.navNotifications,
                    onTap: () => _comingSoon(context, context.l10n.notificationSettings),
                  ),
                  _SettingsRow(
                    icon: Icons.dark_mode_outlined,
                    color: const Color(0xFF7B61FF),
                    label: context.l10n.appearance,
                    value: themeModeLabel(context.l10n, context.watch<ThemeProvider>().mode),
                    onTap: () => showAppearanceSheet(context),
                  ),
                  _SettingsRow(
                    icon: Icons.public_rounded,
                    color: AppColors.green,
                    label: context.l10n.language,
                    value: languageLabel(
                      context.l10n,
                      context.watch<LocaleProvider>().locale,
                    ),
                    onTap: () => showLanguageSheet(context),
                  ),
                  _SettingsRow(
                    icon: Icons.info_outline_rounded,
                    color: AppColors.orange,
                    label: context.l10n.version,
                    value: '1.0.0',
                    onTap: () => {},
                    notClickable: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 54,
              child: TextButton.icon(
                onPressed: () => context.read<AuthProvider>().logout(),
                icon: const Icon(Icons.logout_rounded, size: 19),
                label: Text(
                  context.l10n.signOut,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  backgroundColor: context.palette.dangerTint,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.l),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.name,
    required this.email,
    required this.initials,
    required this.stats,
  });

  final String name;
  final String? email;
  final String initials;
  final TaskStats stats;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          boxShadow: AppShadows.glow(AppColors.teal),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -50,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -60,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
              child: Column(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: AppColors.teal,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (email != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      email!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _StatTile(value: stats.completed, label: context.l10n.statusDone),
                      const SizedBox(width: 10),
                      _StatTile(value: stats.inProgress, label: context.l10n.statusInProgress),
                      const SizedBox(width: 10),
                      _StatTile(value: stats.overdue, label: context.l10n.overdue),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(AppRadius.m),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.value,
    this.notClickable = false,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String? value;
  final bool? notClickable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.m),
      onTap: notClickable! ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (value != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 6),
                child: Text(
                  value!,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.palette.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (!notClickable!)
              Icon(
                Icons.chevron_right_rounded,
                color: context.palette.hint,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
