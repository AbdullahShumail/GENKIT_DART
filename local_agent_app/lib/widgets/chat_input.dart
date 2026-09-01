import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isLoading;

  const ChatInput({
    super.key,
    required this.onSend,
    required this.isLoading,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;
  late final AnimationController _sendBtnAnim;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
    _sendBtnAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _sendBtnAnim.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;

    _sendBtnAnim.reverse().then((_) => _sendBtnAnim.forward());
    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus(); // Force focus back to text field immediately
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.scaffoldBg.withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05), width: 1)),
      ),
      padding: EdgeInsets.only(
        left: 16, right: 12, top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(
                  color: _focusNode.hasFocus ? AppTheme.accentPrimary.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: AppTheme.cardShadow,
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                // IMPORTANT: Removed `enabled: !widget.isLoading` here. 
                // Now the user can ALWAYS type in the field, even if the AI is generating.
                decoration: const InputDecoration(
                  hintText: 'Message Local Agent...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ScaleTransition(
            scale: _sendBtnAnim,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46, height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _hasText && !widget.isLoading ? AppTheme.userBubbleGradient : null,
                color: _hasText && !widget.isLoading ? null : AppTheme.surfaceLight,
                boxShadow: _hasText && !widget.isLoading ? AppTheme.glowShadow : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleSend,
                  borderRadius: BorderRadius.circular(23),
                  child: Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentPrimary),
                          )
                        : Icon(
                            Icons.arrow_upward_rounded,
                            color: _hasText ? Colors.white : AppTheme.textMuted,
                            size: 22,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
