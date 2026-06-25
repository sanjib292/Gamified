import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.g.dart';
part 'chat_message.freezed.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,

    /// 'user' | 'assistant' | 'system'
    required String role,
    required String content,
    required DateTime createdAt,

    /// True while the assistant is still streaming tokens.
    @Default(false) bool isStreaming,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
