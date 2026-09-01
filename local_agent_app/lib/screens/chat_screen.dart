import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    ref.listen(chatProvider, (prev, next) {
      _scrollToBottom();
    });

    if (chatState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(chatState.error!, style: const TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.errorColor.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
            duration: const Duration(seconds: 6),
          ),
        );
        ref.read(chatProvider.notifier).clearError();
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, chatState.selectedModel),
              Expanded(
                child: chatState.messages.isEmpty
                    ? _buildEmptyState()
                    : _buildMessageList(chatState),
              ),
              ChatInput(
                onSend: (text) => ref.read(chatProvider.notifier).sendMessage(text),
                isLoading: chatState.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String selectedModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.8),
        border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [AppTheme.accentPrimary, AppTheme.accentSecondary],
              ),
              boxShadow: AppTheme.glowShadow,
            ),
            child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Local Agent', style: TextStyle(
                  color: AppTheme.textPrimary, fontSize: 17,
                  fontWeight: FontWeight.w700, letterSpacing: -0.3,
                )),
                Row(children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppTheme.successColor,
                  )),
                  const SizedBox(width: 5),
                  Text(selectedModel, style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w500,
                  )),
                ]),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune_rounded, color: AppTheme.textSecondary, size: 22),
            color: AppTheme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (model) => ref.read(chatProvider.notifier).setModel(model),
            itemBuilder: (_) => ['llama3', 'llama3.2', 'phi3', 'mistral', 'gemma2', 'codellama']
                .map((m) => PopupMenuItem(value: m, child: Row(children: [
                  Icon(m == selectedModel ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: m == selectedModel ? AppTheme.accentPrimary : AppTheme.textMuted, size: 18),
                  const SizedBox(width: 10),
                  Text(m, style: TextStyle(
                    color: m == selectedModel ? AppTheme.textPrimary : AppTheme.textSecondary,
                    fontWeight: m == selectedModel ? FontWeight.w600 : FontWeight.w400,
                  )),
                ]))).toList(),
          ),
          IconButton(
            onPressed: () => ref.read(chatProvider.notifier).clearChat(),
            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.textSecondary, size: 22),
            tooltip: 'Clear chat',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.accentPrimary, AppTheme.accentSecondary],
              ),
              boxShadow: AppTheme.glowShadow,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 24),
          const Text('Start a conversation', style: TextStyle(
            color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 8),
          const Text('Your local AI agent is ready.\nType a message below to begin.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMuted, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 32),
          Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
            _chip('Explain async/await in Dart'),
            _chip('Write a Flutter widget'),
            _chip('What is Riverpod?'),
          ]),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return GestureDetector(
      onTap: () => ref.read(chatProvider.notifier).sendMessage(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppTheme.surfaceDark,
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Text(text, style: const TextStyle(
          color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500,
        )),
      ),
    );
  }

  Widget _buildMessageList(chatState) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      itemCount: chatState.messages.length + (chatState.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == chatState.messages.length && chatState.isLoading) {
          return const TypingIndicator();
        }
        return ChatBubble(message: chatState.messages[index]);
      },
    );
  }
}
