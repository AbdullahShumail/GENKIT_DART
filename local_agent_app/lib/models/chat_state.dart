import 'chat_message.dart';

/// Represents the current state of the chat conversation.
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final String selectedModel;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.selectedModel = 'llama3',
  });

  /// Creates a copy of this state with optional overrides.
  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    String? selectedModel,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedModel: selectedModel ?? this.selectedModel,
    );
  }
}
