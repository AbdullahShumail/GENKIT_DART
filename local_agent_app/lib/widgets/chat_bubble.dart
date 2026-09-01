import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/chat_message.dart';
import '../theme/app_theme.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 64 : 16,
        right: isUser ? 16 : 64,
        top: 6,
        bottom: 6,
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isUser) ...[
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppTheme.accentSecondary, AppTheme.accentPrimary],
                      ),
                    ),
                    child: const Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  isUser ? 'You' : 'Agent',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isUser ? AppTheme.accentPrimary : AppTheme.accentSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: message.text));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Copied to clipboard', style: TextStyle(color: Colors.white)),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                gradient: isUser ? AppTheme.userBubbleGradient : null,
                color: isUser ? null : AppTheme.aiBubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppTheme.radiusMd),
                  topRight: const Radius.circular(AppTheme.radiusMd),
                  bottomLeft: Radius.circular(isUser ? AppTheme.radiusMd : AppTheme.radiusSm),
                  bottomRight: Radius.circular(isUser ? AppTheme.radiusSm : AppTheme.radiusMd),
                ),
                border: isUser ? null : Border.all(color: Colors.black.withOpacity(0.05), width: 1),
                boxShadow: isUser 
                    ? [BoxShadow(color: AppTheme.accentPrimary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] 
                    : AppTheme.cardShadow,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SelectableText(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : AppTheme.textPrimary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Text(
              _formatTime(message.timestamp),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
