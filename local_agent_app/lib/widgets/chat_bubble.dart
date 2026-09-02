import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/chat_message.dart';
import '../theme/app_theme.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    // AI "Thinking" Indicator (Sine wave dots)
    if (!isUser && message.text.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(left: 24, top: 24, bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AvatarIcon(),
            SizedBox(width: 16),
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: ThinkingWave(),
            ),
          ],
        ),
      );
    }

    if (isUser) {
      // USER BUBBLE: Right-aligned, pill shape, subtle #1E1E22 background, razor-thin border
      return Padding(
        padding: const EdgeInsets.only(left: 64, right: 24, top: 12, bottom: 12),
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: message.text));
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E22),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: SelectableText(
                message.text,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ).animate().fade(duration: 400.ms, curve: Curves.easeOut);
    } else {
      // AI BUBBLE: Left-aligned, no wrapper, pure text with avatar
      return Padding(
        padding: const EdgeInsets.only(left: 24, right: 48, top: 12, bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AvatarIcon(),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: GestureDetector(
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: message.text));
                  },
                  child: SelectableText(
                    message.text,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate().fade(duration: 400.ms, curve: Curves.easeOut);
    }
  }
}

class AvatarIcon extends StatelessWidget {
  const AvatarIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: const Icon(Icons.blur_on_rounded, color: Colors.white70, size: 18),
    );
  }
}

class ThinkingWave extends StatelessWidget {
  const ThinkingWave({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        // Continuous scale & opacity phase shift via flutter_animate
        return Container(
          width: 6, height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
        ).animate(onPlay: (c) => c.repeat())
         .scale(
           begin: const Offset(0.6, 0.6), 
           end: const Offset(1.2, 1.2), 
           duration: 600.ms, 
           curve: Curves.easeInOutSine, 
           delay: (index * 200).ms
         )
         .then()
         .scale(
           begin: const Offset(1.2, 1.2), 
           end: const Offset(0.6, 0.6), 
           duration: 600.ms, 
           curve: Curves.easeInOutSine
         );
      }),
    );
  }
}
