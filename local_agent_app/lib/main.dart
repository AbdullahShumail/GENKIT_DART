import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/chat_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: LocalAgentApp(),
    ),
  );
}

class LocalAgentApp extends StatelessWidget {
  const LocalAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Agent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Switched to the new Light Theme
      home: const ChatScreen(),
    );
  }
}
