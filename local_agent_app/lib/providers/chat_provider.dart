import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/chat_state.dart';
import '../services/ollama_service.dart';

final ollamaServiceProvider = Provider<OllamaService>((ref) {
  final service = OllamaService();
  ref.onDispose(() => service.dispose());
  return service;
});

class ChatNotifier extends Notifier<ChatState> {
  late final OllamaService _ollamaService;

  @override
  ChatState build() {
    _ollamaService = ref.watch(ollamaServiceProvider);
    return const ChatState();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage.user(text.trim());
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true, // Show typing indicator briefly while stream starts
      error: null,
    );

    try {
      final conversationHistory = state.messages.map((msg) {
        return {
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
        };
      }).toList();

      final stream = _ollamaService.sendMessageStream(
        model: state.selectedModel,
        messages: conversationHistory,
      );

      // Create an empty placeholder message for the AI's upcoming response
      final assistantMessageId = DateTime.now().microsecondsSinceEpoch.toString();
      var assistantMessage = ChatMessage(
        id: assistantMessageId,
        text: '',
        isUser: false,
        timestamp: DateTime.now(),
      );

      // Add the empty message and turn off loading so the user can keep typing immediately
      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false, 
      );

      String fullText = '';
      
      // Listen to the stream and update the message chunk by chunk
      await for (final chunk in stream) {
        fullText += chunk;
        
        final messages = List<ChatMessage>.from(state.messages);
        final index = messages.indexWhere((m) => m.id == assistantMessageId);
        
        if (index != -1) {
          messages[index] = ChatMessage(
            id: assistantMessageId,
            text: fullText,
            isUser: false,
            timestamp: assistantMessage.timestamp,
          );
          state = state.copyWith(messages: messages);
        }
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setModel(String model) {
    state = state.copyWith(selectedModel: model);
  }

  void clearChat() {
    state = const ChatState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
