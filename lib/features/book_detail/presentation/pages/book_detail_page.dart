import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/mq_primary_button.dart';
import '../../../../shared/widgets/cards/achievement_badge.dart';
import '../../../../shared/widgets/cards/book_card.dart';
import '../../../../shared/widgets/cards/lesson_node_card.dart';
import '../../../../shared/widgets/feedback/mq_fullpage_loading.dart';
import '../../data/models/book_detail_model.dart';
import '../providers/book_detail_notifier.dart';

class BookDetailPage extends ConsumerWidget {
  const BookDetailPage({super.key, required this.bookId});

  final String bookId;

  static const double _headerHeight = 300.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookDetailProvider(bookId));

    return state.when(
      loading: () => const Scaffold(
        body: MqFullPageLoading(),
      ),
      error: (error, _) => Scaffold(
        body: MqSimpleError(
          message: error.toString(),
          onRetry: () => ref.invalidate(bookDetailProvider(bookId)),
        ),
      ),
      data: (detail) => _BookDetailContent(
        bookId: bookId,
        detail: detail,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main content scaffold
// ---------------------------------------------------------------------------

class _BookDetailContent extends ConsumerWidget {
  const _BookDetailContent({
    required this.bookId,
    required this.detail,
  });

  final String bookId;
  final BookDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Parallax header ──────────────────────────────────────────────
          _ParallaxHeroSliver(book: detail.book),

          // ── Body content ─────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.lg, AppSpacing.md, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _MetaRow(book: detail.book),
                const SizedBox(height: AppSpacing.md),
                _ProgressSection(detail: detail),
                const SizedBox(height: AppSpacing.lg),
                _KeyConceptsRow(book: detail.book),
                const SizedBox(height: AppSpacing.lg),
                _LearningPathsAccordion(detail: detail),
                const SizedBox(height: AppSpacing.lg),
                _AchievementsSection(achievements: detail.availableAchievements),
              ]),
            ),
          ),
        ],
      ),

      // ── Floating CTA ──────────────────────────────────────────────────────
      bottomNavigationBar: _CtaBar(detail: detail),
    );
  }
}

// ---------------------------------------------------------------------------
// Parallax Hero Sliver
// ---------------------------------------------------------------------------

class _ParallaxHeroSliver extends StatelessWidget {
  const _ParallaxHeroSliver({required this.book});

  final Book book;

  static const double _height = 300.0;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: _height,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.darkBackground,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black45,
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.fadeTitle,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover image
            Hero(
              tag: 'book-${book.id}',
              child: CachedNetworkImage(
                imageUrl: book.coverUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => _CoverFallback(title: book.title),
                errorWidget: (_, __, ___) =>
                    _CoverFallback(title: book.title),
              ),
            ),
            // Bottom gradient
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.5, 1.0],
                    colors: [Colors.transparent, AppColors.background],
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

class _CoverFallback extends StatelessWidget {
  const _CoverFallback({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: Text(
        title,
        style: AppTextStyles.titleLarge.copyWith(color: AppColors.textSecondary),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Meta row — title, author, badges
// ---------------------------------------------------------------------------

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final difficultyColor = switch (book.difficulty) {
      BookDifficulty.beginner => AppColors.success,
      BookDifficulty.intermediate => AppColors.warning,
      BookDifficulty.advanced => AppColors.error,
    };
    final difficultyLabel = switch (book.difficulty) {
      BookDifficulty.beginner => 'Beginner',
      BookDifficulty.intermediate => 'Intermediate',
      BookDifficulty.advanced => 'Advanced',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(book.title,
            style: AppTextStyles.headlineSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: AppSpacing.xs),
        Text(book.author,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _Badge(label: difficultyLabel, color: difficultyColor),
            const SizedBox(width: AppSpacing.sm),
            _Badge(
              label: '~45 min',
              color: AppColors.info,
              icon: Icons.access_time_rounded,
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppSpacing.borderRadiusFull,
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress section
// ---------------------------------------------------------------------------

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.detail});

  final BookDetail detail;

  @override
  Widget build(BuildContext context) {
    if (detail.totalLessons == 0) return const SizedBox.shrink();

    final progress = detail.totalLessons > 0
        ? detail.completedLessons / detail.totalLessons
        : 0.0;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Progress',
                  style: AppTextStyles.titleSmall),
              Text(
                '${detail.completedLessons} of ${detail.totalLessons} lessons',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppSpacing.borderRadiusFull,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.surfaceVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }
}

// ---------------------------------------------------------------------------
// Key concepts chip row
// ---------------------------------------------------------------------------

class _KeyConceptsRow extends StatelessWidget {
  const _KeyConceptsRow({required this.book});

  final Book book;

  // Hard-coded sample concepts — real data comes from books.key_concepts JSONB.
  static const List<String> _concepts = [
    'Wealth Mindset',
    'Compounding',
    'Risk Tolerance',
    'Behavioral Finance',
    'Long-term Thinking',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Key Concepts', style: AppTextStyles.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _concepts
              .map((c) => Chip(
                    label: Text(c,
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.primary)),
                    backgroundColor: AppColors.surfaceVariant,
                    side: const BorderSide(color: AppColors.accent, width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  ))
              .toList(),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }
}

// ---------------------------------------------------------------------------
// Learning paths accordion
// ---------------------------------------------------------------------------

class _LearningPathsAccordion extends StatelessWidget {
  const _LearningPathsAccordion({required this.detail});

  final BookDetail detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Learning Paths', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        ...detail.paths.asMap().entries.map((entry) {
          final i = entry.key;
          final path = entry.value;
          return _PathAccordionTile(path: path, bookId: detail.book.id)
              .animate()
              .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 200 + i * 60))
              .slideX(begin: 0.05);
        }),
      ],
    );
  }
}

class _PathAccordionTile extends ConsumerStatefulWidget {
  const _PathAccordionTile({required this.path, required this.bookId});

  final LearningPath path;
  final String bookId;

  @override
  ConsumerState<_PathAccordionTile> createState() =>
      _PathAccordionTileState();
}

class _PathAccordionTileState extends ConsumerState<_PathAccordionTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            borderRadius: AppSpacing.borderRadiusLg,
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.path.displayOrder}',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.path.title,
                            style: AppTextStyles.titleSmall),
                        Text('${widget.path.lessons.length} lessons',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),

          // Expanded lesson list
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _LessonList(
              lessons: widget.path.lessons,
              pathId: widget.path.id,
              bookId: widget.bookId,
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

class _LessonList extends StatelessWidget {
  const _LessonList({
    required this.lessons,
    required this.pathId,
    required this.bookId,
  });

  final List<Lesson> lessons;
  final String pathId;
  final String bookId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1, color: AppColors.divider),
        ...lessons.asMap().entries.map((entry) {
          final i = entry.key;
          final lesson = entry.value;
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('${i + 1}',
                    style: AppTextStyles.labelSmall
                        .copyWith(fontWeight: FontWeight.w600)),
              ),
            ),
            title:
                Text(lesson.title, style: AppTextStyles.bodyMedium),
            subtitle: Text(
              _lessonTypeLabel(lesson.type),
              style: AppTextStyles.bodySmall,
            ),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textHint, size: 20),
            onTap: () => context.push(
              RouteNames.lessonPath(bookId, pathId, lesson.id),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  String _lessonTypeLabel(LessonType type) => switch (type) {
        LessonType.quiz => 'Quiz',
        LessonType.flashcard => 'Flashcards',
        LessonType.challenge => 'Challenge',
        LessonType.summary => 'Summary',
        LessonType.reading => 'Reading',
      };
}

// ---------------------------------------------------------------------------
// Achievements section
// ---------------------------------------------------------------------------

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection({required this.achievements});

  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Achievements to Unlock', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, i) => AchievementBadgeTile(
              achievement: achievements[i],
              isEarned: false,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 250.ms);
  }
}

// ---------------------------------------------------------------------------
// CTA bar
// ---------------------------------------------------------------------------

class _CtaBar extends ConsumerWidget {
  const _CtaBar({required this.detail});

  final BookDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasProgress = (detail.userProgress?.completedLessons ?? 0) > 0;
    final label = hasProgress ? 'Continue Learning' : 'Start Learning';

    // Find first available lesson to navigate to.
    String? firstPathId;
    String? firstLessonId;
    if (detail.paths.isNotEmpty && detail.paths.first.lessons.isNotEmpty) {
      firstPathId = detail.paths.first.id;
      firstLessonId = detail.paths.first.lessons.first.id;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
        child: MqPrimaryButton(
          label: label,
          width: double.infinity,
          icon: hasProgress ? Icons.play_arrow_rounded : Icons.rocket_launch_rounded,
          onPressed: firstPathId != null && firstLessonId != null
              ? () => context.push(
                    RouteNames.lessonPath(
                        detail.book.id, firstPathId!, firstLessonId!),
                  )
              : null,
        ),
      ),
    );
  }
}
