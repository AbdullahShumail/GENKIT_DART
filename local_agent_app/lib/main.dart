import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/landing_screen.dart';
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
      theme: AppTheme.oledTheme,
      home: const LandingScreen(),
    );
  }
}
