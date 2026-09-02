import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';

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

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: Stack(
        children: [
          // Ambient Top-Center Silver Glow
          Positioned(
            top: -150, left: 0, right: 0,
            child: Center(
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.white.withOpacity(0.04), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(color: Colors.transparent),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, chatState.selectedModel),
                Expanded(
                  child: chatState.messages.isEmpty
                      ? _buildEmptyState()
                      : _buildMessageList(chatState),
                ),
              ],
            ),
          ),
          
          // Floating Input Bar
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ChatInput(
                onSend: (text) => ref.read(chatProvider.notifier).sendMessage(text),
                isLoading: chatState.isLoading,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String selectedModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('Neural Core', style: TextStyle(
                color: AppTheme.textPrimary, fontSize: 16,
                fontWeight: FontWeight.w600, letterSpacing: -0.2,
              )),
              const SizedBox(width: 8),
              // Pulsing Green Status Dot
              Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .fade(begin: 0.4, end: 1.0, duration: 1.seconds),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded, color: AppTheme.textSecondary, size: 24),
            color: AppTheme.surfaceDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppTheme.border),
            ),
            onSelected: (model) => ref.read(chatProvider.notifier).setModel(model),
            itemBuilder: (_) => ['llama3', 'llama3.2', 'phi3', 'mistral', 'gemma2', 'qwen']
                .map((m) => PopupMenuItem(value: m, child: Text(m, style: const TextStyle(color: AppTheme.textPrimary)))).toList(),
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
          // Glowing Monogram
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.03),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.02),
                  blurRadius: 30,
                  spreadRadius: 5,
                )
              ],
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Icon(Icons.blur_on_rounded, color: Colors.white70, size: 32),
          ).animate().fade(duration: 800.ms).scale(begin: const Offset(0.9, 0.9)),
          
          const SizedBox(height: 24),
          
          const Text(
            'How can I assist you?',
            style: TextStyle(
              color: Color(0xFFEDEDED), 
              fontSize: 22, 
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ).animate().fade(delay: 200.ms, duration: 800.ms),
          
          const SizedBox(height: 32),
          
          // Starter Chips
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildChip('Explain a concept'),
              _buildChip('Analyze snippet'),
              _buildChip('Brainstorm ideas'),
            ],
          ).animate().fade(delay: 400.ms, duration: 800.ms),
        ],
      ),
    );
  }

  Widget _buildChip(String text) {
    return GestureDetector(
      onTap: () => ref.read(chatProvider.notifier).sendMessage(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF141416).withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFA0A0A5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList(chatState) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 16, bottom: 120), // Padding for floating input
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        return ChatBubble(message: chatState.messages[index]);
      },
    );
  }
}
