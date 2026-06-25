import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/content_block.dart';

/// Renders a [FlashcardBlock] — a swipeable deck of flip cards.
///
/// Tapping flips the card. Swiping left/right advances through the deck.
class FlashcardWidget extends StatefulWidget {
  const FlashcardWidget({
    super.key,
    required this.block,
    required this.onCompleted,
  });

  final FlashcardBlock block;
  final void Function(int xpEarned) onCompleted;

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  int _currentIndex = 0;
  bool _showingBack = false;

  List<Flashcard> get _cards => widget.block.deck.cards;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flip() {
    if (_flipController.isAnimating) return;
    if (_showingBack) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _showingBack = !_showingBack);
  }

  void _nextCard() {
    if (_currentIndex >= _cards.length - 1) {
      widget.onCompleted(_cards.length * 10);
      return;
    }
    setState(() {
      _currentIndex++;
      _showingBack = false;
    });
    _flipController.reset();
  }

  void _prevCard() {
    if (_currentIndex <= 0) return;
    setState(() {
      _currentIndex--;
      _showingBack = false;
    });
    _flipController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final card = _cards[_currentIndex];

    return Padding(
      padding: AppSpacing.paddingMd,
      child: Column(
        children: [
          // Progress indicator
          Text(
            '${_currentIndex + 1} / ${_cards.length}',
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _cards.length,
            backgroundColor: AppColors.surfaceVariant,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
            borderRadius: AppSpacing.borderRadiusFull,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Flip card
          GestureDetector(
            onTap: _flip,
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity == null) return;
              if (details.primaryVelocity! < -200) _nextCard();
              if (details.primaryVelocity! > 200) _prevCard();
            },
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                final isShowingBack =
                    _flipAnimation.value > math.pi / 2;
                final angle = isShowingBack
                    ? _flipAnimation.value - math.pi
                    : _flipAnimation.value;

                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  alignment: Alignment.center,
                  child: _CardFace(
                    isBack: isShowingBack,
                    card: card,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Hint
          Text(
            _showingBack ? 'Swipe to continue' : 'Tap to reveal answer',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textHint),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Navigation row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_currentIndex > 0)
                TextButton.icon(
                  onPressed: _prevCard,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Prev'),
                ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _nextCard,
                icon: Icon(
                  _currentIndex >= _cards.length - 1
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                  size: 18,
                ),
                label: Text(_currentIndex >= _cards.length - 1
                    ? 'Done'
                    : 'Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({required this.isBack, required this.card});

  final bool isBack;
  final Flashcard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isBack
              ? [AppColors.primary, AppColors.secondary]
              : [AppColors.surface, AppColors.surfaceVariant],
        ),
        borderRadius: AppSpacing.borderRadiusXl,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: AppSpacing.paddingLg,
              child: Text(
                isBack ? card.back : card.front,
                style: isBack
                    ? AppTextStyles.titleMedium
                        .copyWith(color: Colors.white)
                    : AppTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.md,
            child: Text(
              isBack ? 'ANSWER' : 'QUESTION',
              style: AppTextStyles.labelSmall.copyWith(
                color: isBack
                    ? Colors.white.withOpacity(0.6)
                    : AppColors.textHint,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
