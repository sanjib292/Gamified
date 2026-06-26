import 'package:flutter/material.dart' hide Simulation;
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/content_block.dart';

/// Renders a [SimulationBlock] — multi-step exercise with state display,
/// option buttons, and a running score total.
class SimulationWidget extends StatefulWidget {
  const SimulationWidget({
    super.key,
    required this.block,
    required this.onCompleted,
  });

  final SimulationBlock block;
  final void Function(int score, int xpEarned) onCompleted;

  @override
  State<SimulationWidget> createState() => _SimulationWidgetState();
}

class _SimulationWidgetState extends State<SimulationWidget> {
  int _stepIndex = 0;
  int _totalScore = 0;
  String? _selectedOptionId;
  bool _stepAnswered = false;

  Simulation get _sim => widget.block.simulation;
  SimulationStep get _step => _sim.steps[_stepIndex];
  bool get _isLastStep => _stepIndex >= _sim.steps.length - 1;

  void _selectOption(SimulationOption option) {
    if (_stepAnswered) return;
    final isCorrect = option.id == _step.correctOptionId;
    setState(() {
      _selectedOptionId = option.id;
      _stepAnswered = true;
      if (isCorrect) _totalScore += option.xpReward + 10;
    });
  }

  void _advance() {
    if (_isLastStep) {
      widget.onCompleted(_totalScore, _totalScore);
      return;
    }
    setState(() {
      _stepIndex++;
      _selectedOptionId = null;
      _stepAnswered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_stepIndex + 1} of ${_sim.steps.length}',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.xpGold, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$_totalScore pts',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.xpGold, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: (_stepIndex + 1) / _sim.steps.length,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.xpGold),
            minHeight: 6,
            borderRadius: AppSpacing.borderRadiusFull,
          ),
          const SizedBox(height: AppSpacing.lg),

          // State display
          if (_step.stateDisplay != null)
            Container(
              padding: AppSpacing.cardPadding,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              child: Text(
                _step.stateDisplay!,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.darkTextPrimary,
                        fontFamily: 'monospace'),
              ),
            ),

          // Prompt
          Text(_step.prompt, style: AppTextStyles.titleSmall),
          const SizedBox(height: AppSpacing.md),

          // Options
          ...List.generate(_step.options.length, (i) {
            final option = _step.options[i];
            final isSelected = _selectedOptionId == option.id;
            final isCorrect = option.id == _step.correctOptionId;

            Color borderColor = AppColors.divider;
            Color bgColor = AppColors.surface;

            if (_stepAnswered) {
              if (isCorrect) {
                borderColor = AppColors.correct;
                bgColor = AppColors.correct.withOpacity(0.08);
              } else if (isSelected) {
                borderColor = AppColors.wrong;
                bgColor = AppColors.wrong.withOpacity(0.08);
              }
            } else if (isSelected) {
              borderColor = AppColors.primary;
              bgColor = AppColors.surfaceVariant;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GestureDetector(
                onTap: () => _selectOption(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: AppSpacing.borderRadiusMd,
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Text(option.label, style: AppTextStyles.bodyMedium),
                ),
              ).animate().fadeIn(
                  duration: 200.ms,
                  delay: Duration(milliseconds: i * 60)),
            );
          }),

          const SizedBox(height: AppSpacing.md),

          // Continue button
          if (_stepAnswered)
            ElevatedButton(
              onPressed: _advance,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusFull),
                minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
              ),
              child: Text(_isLastStep ? 'Finish Simulation' : 'Next Step'),
            ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }
}
