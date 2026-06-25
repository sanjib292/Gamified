import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/ai_coach_data_source.dart';
import '../../data/models/chat_message.dart';

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final _aiCoachDataSourceProvider = Provider<AiCoachDataSource>(
  (ref) => AiCoachDataSource(ref.watch(supabaseClientProvider)),
);

final activeConversationIdProvider = StateProvider<String?>((ref) => null);

// ---------------------------------------------------------------------------
// Chat notifier
// ---------------------------------------------------------------------------

/// Manages the message list for the active conversation.
///
/// Handles streaming token accumulation: appends an [isStreaming] message
/// and updates its content incrementally until the stream closes.
class AiCoachNotifier extends AsyncNotifier<List<ChatMessage>> {
  @override
  FutureOr<List<ChatMessage>> build() async {
    final conversationId = ref.watch(activeConversationIdProvider);
    if (conversationId == null) return [];

    final ds = ref.watch(_aiCoachDataSourceProvider);
    return ds.fetchMessages(conversationId);
  }

  // ---------------------------------------------------------------------------
  // Send a user message
  // ---------------------------------------------------------------------------

  Future<void> sendMessage(
    String text, {
    String? lessonContext,
    String? bookContext,
  }) async {
    final ds = ref.read(_aiCoachDataSourceProvider);
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    var conversationId = ref.read(activeConversationIdProvider);
    if (conversationId == null) {
      conversationId = await ds.createConversation(userId, null, null);
      ref.read(activeConversationIdProvider.notifier).state =
          conversationId;
    }

    // Add user message to local list immediately.
    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      role: 'user',
      content: text,
      createdAt: DateTime.now(),
    );
    _appendMessage(userMsg);

    // Add a placeholder streaming message.
    final streamingId = const Uuid().v4();
    final streamingMsg = ChatMessage(
      id: streamingId,
      role: 'assistant',
      content: '',
      createdAt: DateTime.now(),
      isStreaming: true,
    );
    _appendMessage(streamingMsg);

    String accumulated = '';

    try {
      await for (final token in ds.sendMessageStreaming(
        conversationId: conversationId,
        message: text,
        lessonContext: lessonContext,
        bookContext: bookContext,
      )) {
        accumulated += token;
        _updateStreamingMessage(streamingId, accumulated);
      }
    } catch (e) {
      _updateStreamingMessage(
        streamingId,
        'Sorry, I encountered an error. Please try again.',
        isStreaming: false,
      );
      return;
    }

    // Mark streaming done.
    _updateStreamingMessage(streamingId, accumulated, isStreaming: false);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _appendMessage(ChatMessage msg) {
    final current = state.valueOrNull ?? [];
    state = AsyncData([...current, msg]);
  }

  void _updateStreamingMessage(String id, String content,
      {bool isStreaming = true}) {
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.map((m) {
      if (m.id == id) {
        return m.copyWith(content: content, isStreaming: isStreaming);
      }
      return m;
    }).toList());
  }

  void startNewConversation() {
    ref.read(activeConversationIdProvider.notifier).state = null;
    state = const AsyncData([]);
  }
}

final aiCoachProvider =
    AsyncNotifierProvider<AiCoachNotifier, List<ChatMessage>>(
  AiCoachNotifier.new,
  name: 'aiCoachProvider',
);
