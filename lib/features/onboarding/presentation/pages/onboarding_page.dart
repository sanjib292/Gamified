import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/mq_primary_button.dart';
import '../providers/onboarding_notifier.dart';

// ---------------------------------------------------------------------------
// Goals + daily options
// ---------------------------------------------------------------------------

const _kGoals = [
  'Career growth',
  'Financial literacy',
  'Personal development',
  'Leadership',
  'Creativity',
  'General knowledge',
];

const _kDailyMinutes = [5, 10, 15, 20, 30, 45, 60];

// ---------------------------------------------------------------------------
// OnboardingPage
// ---------------------------------------------------------------------------

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late final PageController _pageController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _animateToPage(int page) async {
    ref.read(onboardingProvider.notifier).setPage(page);
    await _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _finish() async {
    final data = ref.read(onboardingProvider);
    setState(() => _isSaving = true);

    try {
      final supabase = ref.read(supabaseClientProvider);
      final userId = ref.read(authClientProvider).currentUser?.id;
      if (userId == null) {
        context.go(RouteNames.auth);
        return;
      }

      await supabase.from('profiles').update({
        'is_onboarded': true,
        'learning_goals': data.selectedGoal != null ? [data.selectedGoal] : [],
        'daily_goal_minutes': data.dailyGoalMinutes,
      }).eq('id', userId);

      if (!mounted) return;
      context.go(RouteNames.home);
    } catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save preferences. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(onboardingProvider);
    final page = data.currentPage;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar: Skip + progress dots ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip (only visible on page 0)
                  AnimatedOpacity(
                    opacity: page == 0 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: page == 0 ? _finish : null,
                      child: Text(
                        'Skip',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  // Progress dots
                  _ProgressDots(currentPage: page, total: 3),

                  // Spacer to balance Skip
                  const SizedBox(width: 60),
                ],
              ),
            ),

            // ── Page content ─────────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  _WelcomePage(),
                  _GoalSelectionPage(),
                  _DailyGoalPage(),
                ],
              ),
            ),

            // ── Bottom navigation ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  // Back button (hidden on first page)
                  if (page > 0) ...[
                    _BackButton(
                      onPressed: () => _animateToPage(page - 1),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],

                  // Next / Get Started
                  Expanded(
                    child: MqPrimaryButton(
                      label: page == 2 ? 'Get Started' : 'Continue',
                      isLoading: _isSaving,
                      width: double.infinity,
                      onPressed: () {
                        if (page < 2) {
                          _animateToPage(page + 1);
                        } else {
                          _finish();
                        }
                      },
                    ),
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

// ---------------------------------------------------------------------------
// Page 0 — Welcome
// ---------------------------------------------------------------------------

class _WelcomePage extends ConsumerWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration placeholder
          _IllustrationPlaceholder(
            size: 220,
            emoji: '📚',
            color: AppColors.primary,
          ),

          const SizedBox(height: AppSpacing.xl),

          Text(
            'Transform how\nyou learn',
            style: AppTextStyles.displaySmall.copyWith(
              height: 1.18,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 500.ms)
              .slideY(begin: 0.15, end: 0, delay: 100.ms, duration: 450.ms),

          const SizedBox(height: AppSpacing.md),

          Text(
            'Absorb the world\'s best ideas from\nnonfiction books — in minutes, not hours.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 500.ms),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 1 — Goal selection
// ---------------------------------------------------------------------------

class _GoalSelectionPage extends ConsumerWidget {
  const _GoalSelectionPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingProvider).selectedGoal;
    final notifier = ref.read(onboardingProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),

          Text(
            'What do you want\nto achieve?',
            style: AppTextStyles.headlineMedium,
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0, duration: 380.ms),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'Pick one goal — we\'ll personalise your\nlearning path around it.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

          const SizedBox(height: AppSpacing.lg),

          // Goal chip grid
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: 2.4,
              ),
              itemCount: _kGoals.length,
              itemBuilder: (context, i) {
                final goal = _kGoals[i];
                final isSelected = goal == selected;
                return _GoalChip(
                  label: goal,
                  isSelected: isSelected,
                  onTap: () => notifier.selectGoal(goal),
                ).animate().fadeIn(
                      delay: Duration(milliseconds: 60 * i),
                      duration: 350.ms,
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 2 — Daily goal
// ---------------------------------------------------------------------------

class _DailyGoalPage extends ConsumerWidget {
  const _DailyGoalPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingProvider).dailyGoalMinutes;
    final notifier = ref.read(onboardingProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),

          Text(
            'How much time can\nyou commit?',
            style: AppTextStyles.headlineMedium,
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0, duration: 380.ms),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'Set a daily goal. Short, consistent sessions\nbuild lasting habits.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

          const SizedBox(height: AppSpacing.xl),

          // Illustration
          Center(
            child: _IllustrationPlaceholder(
              size: 160,
              emoji: '⏱️',
              color: AppColors.secondary,
            ).animate().scaleXY(
                  begin: 0.8,
                  end: 1.0,
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Segmented daily goal options
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _kDailyMinutes.map((minutes) {
              final isSelected = minutes == selected;
              return _DailyGoalChip(
                minutes: minutes,
                isSelected: isSelected,
                onTap: () => notifier.setDailyGoal(minutes),
              );
            }).toList(),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

          const SizedBox(height: AppSpacing.lg),

          // Selected commitment summary
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _CommitmentSummary(
              key: ValueKey(selected),
              minutes: selected,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Supporting widgets
// ---------------------------------------------------------------------------

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.currentPage, required this.total});

  final int currentPage;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isActive = i == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color:
                isActive ? AppColors.primary : AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        );
      }),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: AppSpacing.buttonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(28),
            child: const Center(
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textSecondary,
                size: AppSpacing.iconMd,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  const _GoalChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyGoalChip extends StatelessWidget {
  const _DailyGoalChip({
    required this.minutes,
    required this.isSelected,
    required this.onTap,
  });

  final int minutes;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          '$minutes min',
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CommitmentSummary extends StatelessWidget {
  const _CommitmentSummary({super.key, required this.minutes});

  final int minutes;

  String get _message {
    if (minutes <= 5) return 'Perfect for building the habit. Small wins every day.';
    if (minutes <= 10) return 'A focused 10 minutes is more powerful than a lazy hour.';
    if (minutes <= 20) return 'You\'re serious. That\'s the sweet spot for deep learning.';
    if (minutes <= 30) return 'Half an hour a day. You\'ll finish a book in a week.';
    return 'Full commitment. You\'re going to master this quickly.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          const Text('✨', style: TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustrationPlaceholder extends StatelessWidget {
  const _IllustrationPlaceholder({
    required this.size,
    required this.emoji,
    required this.color,
  });

  final double size;
  final String emoji;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * 0.4),
        ),
      ),
    );
  }
}
