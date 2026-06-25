import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Custom search bar for the library screen.
///
/// Features:
/// - Debounced — the [onChanged] callback fires after [debounce] ms of
///   inactivity to avoid querying on every keystroke.
/// - Mic icon stub (right side) — wired to [onMicPressed] when provided.
/// - Clear (✕) button appears when the field has text.
class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({
    super.key,
    this.initialValue = '',
    required this.onChanged,
    this.onMicPressed,
    this.debounce = const Duration(milliseconds: 300),
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  /// Called when the mic icon is tapped. Pass null to hide the icon.
  final VoidCallback? onMicPressed;

  /// Debounce duration applied before [onChanged] fires.
  final Duration debounce;

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller;
  _DebounceTimer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    setState(() {}); // Rebuild to show/hide the clear button.
    _debounceTimer?.cancel();
    _debounceTimer = _DebounceTimer(widget.debounce, () {
      widget.onChanged(value);
    });
  }

  void _clear() {
    _controller.clear();
    setState(() {});
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;

    return Container(
      height: AppSpacing.inputHeight,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search icon
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Icon(
              Icons.search_rounded,
              color: AppColors.textHint,
              size: AppSpacing.iconMd,
            ),
          ),

          // Text field
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: _handleChanged,
              style: AppTextStyles.bodyMedium,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search books, authors...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textHint,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),

          // Clear or mic icon
          if (hasText)
            GestureDetector(
              onTap: _clear,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.textHint,
                  size: AppSpacing.iconSm,
                ),
              ),
            )
          else if (widget.onMicPressed != null)
            GestureDetector(
              onTap: widget.onMicPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Icon(
                  Icons.mic_none_rounded,
                  color: AppColors.textHint,
                  size: AppSpacing.iconSm,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tiny debounce helper (uses dart:async Timer)
// ---------------------------------------------------------------------------

class _DebounceTimer {
  _DebounceTimer(Duration delay, VoidCallback callback) {
    _timer = Timer(delay, callback);
  }

  late final Timer _timer;

  void cancel() => _timer.cancel();
}
