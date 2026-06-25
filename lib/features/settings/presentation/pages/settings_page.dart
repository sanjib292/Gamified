import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/settings_notifier.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Settings', style: AppTextStyles.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => context.pop(),
        ),
      ),
      body: _SettingsBody(),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
      children: [
        // ── Profile section ──────────────────────────────────────────────────
        _SectionHeader(title: 'Profile'),
        _SettingsTile(
          icon: Icons.person_outline_rounded,
          title: 'Display Name',
          subtitle: settings.displayName,
          onTap: () => _showEditNameDialog(context, ref),
        ),
        _SettingsTile(
          icon: Icons.image_outlined,
          title: 'Change Avatar',
          onTap: () {
            // Avatar upload stub — requires storage integration.
            _showComingSoonSnack(context);
          },
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Preferences ──────────────────────────────────────────────────────
        _SectionHeader(title: 'Preferences'),
        _ToggleTile(
          icon: Icons.dark_mode_outlined,
          title: 'Dark Mode',
          value: settings.darkMode,
          onChanged: notifier.setDarkMode,
        ),
        _ToggleTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          value: settings.notificationsEnabled,
          onChanged: notifier.setNotifications,
        ),
        _ToggleTile(
          icon: Icons.volume_up_outlined,
          title: 'Sound Effects',
          value: settings.soundEnabled,
          onChanged: notifier.setSoundEnabled,
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Learning ─────────────────────────────────────────────────────────
        _SectionHeader(title: 'Learning'),
        _SliderTile(
          icon: Icons.flag_outlined,
          title: 'Daily Goal',
          value: settings.dailyGoalLessons.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: '${settings.dailyGoalLessons} lesson${settings.dailyGoalLessons > 1 ? 's' : ''}',
          onChanged: (v) => notifier.setDailyGoal(v.round()),
        ),
        _SettingsTile(
          icon: Icons.alarm_outlined,
          title: 'Reminder Time',
          subtitle: _formatTime(settings.reminderHour, settings.reminderMinute),
          onTap: () => _showTimePicker(context, ref, settings),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Subscription ─────────────────────────────────────────────────────
        _SectionHeader(title: 'Subscription'),
        _SettingsTile(
          icon: Icons.workspace_premium_outlined,
          title: 'Current Plan',
          subtitle: settings.isPremium ? 'Premium' : 'Free',
          trailing: settings.isPremium
              ? null
              : _UpgradeBadge(),
          onTap: settings.isPremium
              ? null
              : () => _showComingSoonSnack(context),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Account ──────────────────────────────────────────────────────────
        _SectionHeader(title: 'Account'),
        _SettingsTile(
          icon: Icons.logout_rounded,
          title: 'Sign Out',
          titleColor: AppColors.error,
          onTap: () => _confirmSignOut(context, ref),
        ),
        _SettingsTile(
          icon: Icons.delete_outline_rounded,
          title: 'Delete Account',
          titleColor: AppColors.error,
          onTap: () => _confirmDeleteAccount(context, ref),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── About ────────────────────────────────────────────────────────────
        _SectionHeader(title: 'About'),
        _SettingsTile(
          icon: Icons.info_outline_rounded,
          title: 'Version',
          subtitle: '1.0.0+1',
        ),
        _SettingsTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          onTap: () => _showComingSoonSnack(context),
        ),
        _SettingsTile(
          icon: Icons.article_outlined,
          title: 'Terms of Service',
          onTap: () => _showComingSoonSnack(context),
        ),
      ],
    );
  }

  String _formatTime(int hour, int minute) {
    final period = hour < 12 ? 'AM' : 'PM';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  Future<void> _showEditNameDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(
        text: ref.read(settingsProvider).displayName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Display Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Your name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () =>
                  Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      ref.read(settingsProvider.notifier).setDisplayName(result);
    }
  }

  Future<void> _showTimePicker(
      BuildContext context, WidgetRef ref, AppSettings settings) async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
          hour: settings.reminderHour,
          minute: settings.reminderMinute),
    );
    if (result != null) {
      ref.read(settingsProvider.notifier).setReminderTime(
            result.hour,
            result.minute,
          );
    }
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('You will need to sign in again to access your progress.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Sign Out')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(supabaseClientProvider).auth.signOut();
      if (context.mounted) context.go('/auth');
    }
  }

  Future<void> _confirmDeleteAccount(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This will permanently delete all your progress, achievements, and data. This cannot be undone.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      // Account deletion requires a server-side call; stub here.
      _showComingSoonSnack(context);
    }
  }

  void _showComingSoonSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon!')),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings notifier (simple SharedPreferences-backed state)
// ---------------------------------------------------------------------------

// Re-export so the page file compiles standalone.

// ---------------------------------------------------------------------------
// Supporting widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: AppSpacing.sm, bottom: AppSpacing.xs),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textHint,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: ListTile(
        leading: Icon(icon,
            color: titleColor ?? AppColors.textSecondary, size: 22),
        title: Text(title,
            style: AppTextStyles.bodyMedium
                .copyWith(color: titleColor ?? AppColors.textPrimary)),
        subtitle: subtitle != null
            ? Text(subtitle!, style: AppTextStyles.bodySmall)
            : null,
        trailing: trailing ??
            (onTap != null
                ? const Icon(Icons.chevron_right,
                    color: AppColors.textHint, size: 20)
                : null),
        onTap: onTap,
        shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textSecondary, size: 22),
        title: Text(title, style: AppTextStyles.bodyMedium),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
        shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd),
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.label,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String label;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 22),
              const SizedBox(width: AppSpacing.md),
              Text(title, style: AppTextStyles.bodyMedium),
              const Spacer(),
              Text(label,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.primary)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.surfaceVariant,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _UpgradeBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Text('Upgrade',
          style: AppTextStyles.labelSmall
              .copyWith(color: Colors.white)),
    );
  }
}
