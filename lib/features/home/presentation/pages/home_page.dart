import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../shared/widgets/feedback/mq_error_widget.dart';
import '../../../../shared/widgets/feedback/mq_loading_shimmer.dart';
import '../../../../shared/widgets/streak_counter.dart';
import '../../../../shared/widgets/xp_progress_bar.dart';
import '../providers/home_notifier.dart';
import '../widgets/category_row.dart';
import '../widgets/featured_banner.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: homeAsync.when(
        loading: () => const _HomeLoadingSkeleton(),
        error: (err, _) => MqErrorWidget(
          error: err is AppException
              ? err
              : const UnknownException(message: 'Could not load content.'),
          onRetry: () => ref.invalidate(homeProvider),
        ),
        data: (content) => RefreshIndicator(
          onRefresh: () => ref.read(homeProvider.notifier).refresh(),
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // ── SliverAppBar: XP bar + streak + avatar ──────────────────
              _HomeAppBar(),

              // ── Section padding ──────────────────────────────────────────
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

              // ── Featured banner ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: FeaturedBanner(book: content.featuredBook),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

              // ── Continue Reading ─────────────────────────────────────────
              if (content.continueReading.isNotEmpty)
                SliverToBoxAdapter(
                  child: ContinueReadingRow(books: content.continueReading),
                ),
              if (content.continueReading.isNotEmpty)
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl),
                ),

              // ── Category rows ────────────────────────────────────────────
              SliverList.separated(
                itemCount: content.categories.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.xl),
                itemBuilder: (context, i) =>
                    CategoryRow(category: content.categories[i]),
              ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// App bar
// ---------------------------------------------------------------------------

class _HomeAppBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = ref.watch(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    final metadata = user?.userMetadata;
    final avatarUrl = metadata?['avatar_url'] as String?;
    final displayName = metadata?['full_name'] as String? ?? 'Explorer';
    final firstName = displayName.split(' ').first;

    // TODO: wire to real XP/streak providers when available
    const xp = 1240;
    const level = 4;
    const streak = 7;
    const isStreakActive = true;

    return SliverAppBar(
      backgroundColor: AppColors.background,
      floating: true,
      snap: true,
      elevation: 0,
      toolbarHeight: 72,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Greeting + XP bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hey, $firstName 👋',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    XpProgressBar(currentXp: xp, level: level),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Streak counter
              StreakCounter(
                count: streak,
                isActive: isStreakActive,
              ),

              const SizedBox(width: AppSpacing.md),

              // Avatar
              GestureDetector(
                onTap: () => context.push(RouteNames.profile),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surfaceVariant,
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Text(
                          firstName.isNotEmpty
                              ? firstName[0].toUpperCase()
                              : '?',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading skeleton
// ---------------------------------------------------------------------------

class _HomeLoadingSkeleton extends StatelessWidget {
  const _HomeLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xxl),
            // Banner shimmer
            MqLoadingShimmer.card(
              width: double.infinity,
              height: 280,
              borderRadius: AppSpacing.radiusXl,
            ),
            const SizedBox(height: AppSpacing.xl),
            // Row header shimmer
            MqLoadingShimmer.card(width: 140, height: 20),
            const SizedBox(height: AppSpacing.md),
            // Horizontal cards
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (_, __) => MqLoadingShimmer.card(
                  width: 160,
                  height: 220,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
