import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/ai_coach_notifier.dart';
import '../widgets/chat_message_bubble.dart';

class AiCoachPage extends ConsumerStatefulWidget {
  const AiCoachPage({super.key, this.lessonContext, this.bookContext});

  /// Optional context chip text (e.g. "Chapter 1").
  final String? lessonContext;

  /// Optional book context.
  final String? bookContext;

  @override
  ConsumerState<AiCoachPage> createState() => _AiCoachPageState();
}

class _AiCoachPageState extends ConsumerState<AiCoachPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  static const List<String> _quickActions = [
    'Explain again',
    'Give me a quiz',
    'Real-world example',
    'Summarize this',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();
    setState(() => _isSending = true);

    await ref.read(aiCoachProvider.notifier).sendMessage(
          text.trim(),
          lessonContext: widget.lessonContext,
          bookContext: widget.bookContext,
        );

    setState(() => _isSending = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(aiCoachProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MindQuest AI', style: AppTextStyles.titleSmall),
                Text('Always here to help',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.textSecondary),
            tooltip: 'New conversation',
            onPressed: () =>
                ref.read(aiCoachProvider.notifier).startNewConversation(),
          ),
        ],
        bottom: widget.lessonContext != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
                  child: Row(
                    children: [
                      _ContextChip(label: widget.lessonContext!),
                    ],
                  ),
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messagesState.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              error: (err, _) => Center(
                child: Text('Error: $err',
                    style: AppTextStyles.bodyMedium),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return _EmptyState(
                    onQuickAction: _send,
                    quickActions: _quickActions,
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md),
                  itemCount: messages.length,
                  itemBuilder: (context, i) => ChatMessageBubble(
                    message: messages[i],
                  ).animate().fadeIn(duration: 200.ms),
                );
              },
            ),
          ),

          // Quick action chips (always visible)
          if (messagesState.valueOrNull?.isEmpty ?? true)
            const SizedBox.shrink()
          else
            _QuickActionRow(
              actions: _quickActions,
              onTap: _send,
            ),

          // Input bar
          _InputBar(
            controller: _textController,
            isSending: _isSending,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onQuickAction,
    required this.quickActions,
  });

  final void Function(String) onQuickAction;
  final List<String> quickActions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: Colors.white, size: 40),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Hi! I\'m your AI Coach.',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Ask me anything about what you\'re learning.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: quickActions
                .map((a) => _QuickChip(label: a, onTap: () => onQuickAction(a)))
                .toList(),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick action row
// ---------------------------------------------------------------------------

class _QuickActionRow extends StatelessWidget {
  const _QuickActionRow({required this.actions, required this.onTap});

  final List<String> actions;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: actions
              .map((a) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: _QuickChip(label: a, onTap: () => onTap(a)),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: AppSpacing.borderRadiusFull,
          border: Border.all(color: AppColors.accent.withOpacity(0.4)),
        ),
        child: Text(label,
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.primary)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Context chip
// ---------------------------------------------------------------------------

class _ContextChip extends StatelessWidget {
  const _ContextChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusFull,
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.menu_book_rounded,
              color: AppColors.primary, size: 14),
          const SizedBox(width: 4),
          Text(label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Input bar
// ---------------------------------------------------------------------------

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final void Function(String) onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.sm, AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text field
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppSpacing.borderRadiusXl,
                  border: Border.all(color: AppColors.divider),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Ask your AI coach...',
                    hintStyle: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textHint),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    // Mic button (stub)
                    prefixIcon: const Icon(Icons.mic_none_rounded,
                        color: AppColors.textHint, size: 20),
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // Send button
            GestureDetector(
              onTap: isSending
                  ? null
                  : () => onSend(controller.text),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: isSending ? null : AppColors.primaryGradient,
                  color: isSending ? AppColors.textHint : null,
                  shape: BoxShape.circle,
                  boxShadow: isSending
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: isSending
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
