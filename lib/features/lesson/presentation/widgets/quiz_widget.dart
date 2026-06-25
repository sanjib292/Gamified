import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/content_block.dart';

/// Renders a [QuizBlock] — question, multiple-choice options, correct/wrong
/// animation, and an explanation once the user answers.
class QuizWidget extends StatefulWidget {
  const QuizWidget({
    super.key,
    required this.block,
    required this.onAnswered,
  });

  final QuizBlock block;

  /// Called with (isCorrect, xpEarned) once the user taps an option.
  final void Function(bool isCorrect, int xp) onAnswered;

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  int? _selectedIndex;
  bool _answered = false;

  Quiz get _quiz => widget.block.quiz;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppSpacing.borderRadiusLg,
            ),
            child: Text(
              _quiz.question,
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Options
          ...List.generate(_quiz.options.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _OptionTile(
                label: _quiz.options[i],
                index: i,
                selectedIndex: _selectedIndex,
                correctIndex: _quiz.correctIndex,
                answered: _answered,
                onTap: _answered ? null : () => _handleTap(i),
              ),
            );
          }),

          // Explanation
          if (_answered && _quiz.explanation != null) ...[
            const SizedBox(height: AppSpacing.md),
            _ExplanationCard(text: _quiz.explanation!),
          ],
        ],
      ),
    );
  }

  void _handleTap(int index) {
    setState(() {
      _selectedIndex = index;
      _answered = true;
    });
    final isCorrect = index == _quiz.correctIndex;
    widget.onAnswered(isCorrect, isCorrect ? 20 : 5);
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.correctIndex,
    required this.answered,
    required this.onTap,
  });

  final String label;
  final int index;
  final int? selectedIndex;
  final int correctIndex;
  final bool answered;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.divider;
    Color bgColor = AppColors.surface;
    Color textColor = AppColors.textPrimary;
    Widget? trailingIcon;

    if (answered) {
      if (index == correctIndex) {
        borderColor = AppColors.correct;
        bgColor = AppColors.correct.withOpacity(0.08);
        textColor = AppColors.correct;
        trailingIcon = const Icon(Icons.check_circle_rounded,
            color: AppColors.correct, size: 20);
      } else if (index == selectedIndex) {
        borderColor = AppColors.wrong;
        bgColor = AppColors.wrong.withOpacity(0.08);
        textColor = AppColors.wrong;
        trailingIcon = const Icon(Icons.cancel_rounded,
            color: AppColors.wrong, size: 20);
      }
    } else if (index == selectedIndex) {
      borderColor = AppColors.primary;
      bgColor = AppColors.surfaceVariant;
    }

    Widget tile = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style:
                      AppTextStyles.bodyMedium.copyWith(color: textColor)),
            ),
            if (trailingIcon != null) trailingIcon,
          ],
        ),
      ),
    );

    if (answered && index == correctIndex) {
      tile = tile
          .animate()
          .shake(hz: 4, curve: Curves.easeInOut, duration: 300.ms);
    }

    return tile;
  }
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.08),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded,
              color: AppColors.info, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textPrimary)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }
}
