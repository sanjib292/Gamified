import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/content_block.dart';

/// Renders a [StoryMissionBlock] — dialog-style node renderer with choice
/// buttons and optimal path tracking.
class StoryMissionWidget extends StatefulWidget {
  const StoryMissionWidget({
    super.key,
    required this.block,
    required this.onCompleted,
  });

  final StoryMissionBlock block;
  final void Function(int xpEarned) onCompleted;

  @override
  State<StoryMissionWidget> createState() => _StoryMissionWidgetState();
}

class _StoryMissionWidgetState extends State<StoryMissionWidget> {
  late StoryNode _currentNode;
  int _totalXp = 0;
  bool _finished = false;

  StoryMission get _mission => widget.block.mission;

  @override
  void initState() {
    super.initState();
    _currentNode = _mission.nodes.first;
  }

  void _pickChoice(StoryChoice choice) {
    setState(() => _totalXp += choice.xpReward);

    if (choice.nextNodeId.isEmpty) {
      setState(() => _finished = true);
      widget.onCompleted(_totalXp);
      return;
    }

    final next = _mission.nodes.firstWhere(
      (n) => n.id == choice.nextNodeId,
      orElse: () => _mission.nodes.last,
    );
    setState(() => _currentNode = next);
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 64),
            const SizedBox(height: AppSpacing.md),
            Text('Mission Complete!', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text('+$_totalXp XP',
                style: AppTextStyles.xpOverlay),
          ],
        ).animate().fadeIn().scale(),
      );
    }

    return Padding(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Speaker label
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Text(
                  _currentNode.speaker.isNotEmpty
                      ? _currentNode.speaker[0].toUpperCase()
                      : 'N',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(_currentNode.speaker,
                  style: AppTextStyles.titleSmall),
            ],
          ).animate().fadeIn(duration: 200.ms),

          const SizedBox(height: AppSpacing.md),

          // Dialog bubble
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSpacing.borderRadiusLg,
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _currentNode.text,
              style: AppTextStyles.bodyLarge,
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),

          const SizedBox(height: AppSpacing.xl),

          // Choices
          if (_currentNode.choices.isEmpty)
            ElevatedButton(
              onPressed: () {
                setState(() => _finished = true);
                widget.onCompleted(_totalXp);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusFull),
              ),
              child: const Text('Continue'),
            )
          else
            ...List.generate(_currentNode.choices.length, (i) {
              final choice = _currentNode.choices[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _ChoiceButton(
                  choice: choice,
                  onTap: () => _pickChoice(choice),
                ).animate().fadeIn(
                    duration: 250.ms,
                    delay: Duration(milliseconds: 100 + i * 80)),
              );
            }),
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({required this.choice, required this.onTap});

  final StoryChoice choice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.accent.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                choice.label,
                style: AppTextStyles.bodyMedium,
              ),
            ),
            if (choice.xpReward > 0) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.xpGold.withOpacity(0.15),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Text(
                  '+${choice.xpReward}',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.xpGold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
