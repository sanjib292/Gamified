import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/chat_message.dart';
import 'typing_indicator.dart';

/// A single message bubble in the AI Coach chat.
///
/// User messages are right-aligned with the primary gradient.
/// Assistant messages are left-aligned on the surface colour.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message});

  final ChatMessage message;

  bool get _isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!_isUser) ...[
            _Avatar(isUser: false),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: _isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _Bubble(message: message),
                const SizedBox(height: 4),
                _Timestamp(createdAt: message.createdAt),
              ],
            ),
          ),
          if (_isUser) ...[
            const SizedBox(width: AppSpacing.sm),
            _Avatar(isUser: true),
          ],
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final ChatMessage message;

  bool get _isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: _isUser ? AppColors.primaryGradient : null,
        color: _isUser ? null : AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppSpacing.radiusLg),
          topRight: const Radius.circular(AppSpacing.radiusLg),
          bottomLeft: Radius.circular(
              _isUser ? AppSpacing.radiusLg : AppSpacing.radiusSm),
          bottomRight: Radius.circular(
              _isUser ? AppSpacing.radiusSm : AppSpacing.radiusLg),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: _isUser
            ? null
            : Border.all(color: AppColors.divider, width: 1),
      ),
      child: message.isStreaming && message.content.isEmpty
          ? const TypingIndicator()
          : Text(
              message.content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: _isUser ? Colors.white : AppColors.textPrimary,
                height: 1.5,
              ),
            ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.isUser});
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser
            ? AppColors.primary.withOpacity(0.15)
            : AppColors.surfaceVariant,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: Icon(
          isUser ? Icons.person_rounded : Icons.smart_toy_rounded,
          size: 18,
          color: isUser ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _Timestamp extends StatelessWidget {
  const _Timestamp({required this.createdAt});
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    final h = createdAt.hour.toString().padLeft(2, '0');
    final m = createdAt.minute.toString().padLeft(2, '0');
    return Text(
      '$h:$m',
      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textHint),
    );
  }
}
