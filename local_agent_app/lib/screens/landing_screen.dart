import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/model_download_service.dart';
import 'chat_screen.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  bool _showInstallState = false;

  void _beginInstallation() {
    setState(() => _showInstallState = true);
    // Trigger the real download pipeline
    ref.read(modelDownloadProvider.notifier).checkExistingOrDownload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: Stack(
        children: [
          // 1. Monochrome Ambient Background Layer
          const AmbientBackground(),
          
          // 2. Foreground Content (Two-Step Flow)
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _showInstallState 
                  ? InstallationState(onComplete: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const ChatScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          transitionDuration: const Duration(milliseconds: 800),
                        ),
                      );
                    })
                  : WelcomeState(onStart: _beginInstallation),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── BACKGROUND LAYER ─────────────────────────────────────────────────────────
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        Positioned(
          top: -100, right: -50,
          child: _buildOrb(size.width * 0.8, Colors.white.withOpacity(0.05))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .move(duration: 6.seconds, begin: const Offset(0, 0), end: const Offset(-40, 50), curve: Curves.easeInOut)
              .scale(duration: 7.seconds, begin: const Offset(1, 1), end: const Offset(1.1, 1.1), curve: Curves.easeInOut),
        ),
        Positioned(
          bottom: -50, left: -100,
          child: _buildOrb(size.width * 0.9, const Color(0xFF2C2C2E).withOpacity(0.3))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .move(duration: 8.seconds, begin: const Offset(0, 0), end: const Offset(50, -30), curve: Curves.easeInOut)
              .scale(duration: 6.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2), curve: Curves.easeInOut),
        ),
        Positioned(
          top: size.height * 0.3, right: -150,
          child: _buildOrb(size.width * 0.6, const Color(0xFF1C1C1E).withOpacity(0.6))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .move(duration: 5.seconds, begin: const Offset(0, 0), end: const Offset(-30, -40), curve: Curves.easeInOut)
              .scale(duration: 8.seconds, begin: const Offset(1, 1), end: const Offset(0.9, 0.9), curve: Curves.easeInOut),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0.0)],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

// ─── STATE A: WELCOME ──────────────────────────────────────────────────────────
class WelcomeState extends StatelessWidget {
  final VoidCallback onStart;
  const WelcomeState({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              'ON-DEVICE PRIVACY • ZERO LATENCY',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppTheme.textSecondary,
              ),
            ),
          ).animate().fade(duration: 600.ms).slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic),
          
          const Spacer(flex: 2),
          
          const Text(
            'Intelligence,\nCondensed.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 42,
              fontWeight: FontWeight.w700,
              height: 1.1,
              letterSpacing: -1.5,
              color: Color(0xFFF5F5F7),
            ),
          ).animate().fade(delay: 200.ms, duration: 800.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
          
          const SizedBox(height: 24),
          
          const Text(
            'Run local models directly on your hardware. Fast, private, and offline.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: Color(0xFF8E8E93),
            ),
          ).animate().fade(delay: 400.ms, duration: 800.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
          
          const Spacer(flex: 3),
          
          GestureDetector(
            onTap: onStart,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Let's Get Started",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().fade(delay: 600.ms, duration: 800.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── STATE B: INSTALLATION ────────────────────────────────────────────────────
class InstallationState extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  const InstallationState({super.key, required this.onComplete});

  @override
  ConsumerState<InstallationState> createState() => _InstallationStateState();
}

class _InstallationStateState extends ConsumerState<InstallationState> {
  @override
  Widget build(BuildContext context) {
    // Listen to the real download state
    final downloadState = ref.watch(modelDownloadProvider);

    // Automatically complete when the service marks it complete
    ref.listen(modelDownloadProvider, (previous, next) {
      if (next.isComplete && previous?.isComplete != true) {
        Future.delayed(const Duration(milliseconds: 500), widget.onComplete);
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 16, height: 16,
                child: downloadState.isComplete 
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16)
                    : const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'Setting up Neural Core',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ).animate().fade(duration: 600.ms),
          
          const SizedBox(height: 32),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MODEL INFO',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Qwen 1.5 (0.5B Local Engine)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Architecture: Int4 Quantized • On-Device',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Real Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: downloadState.progress,
                        minHeight: 6,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              downloadState.isError 
                                  ? 'Error downloading model. Please restart.'
                                  : downloadState.status,
                              key: ValueKey<String>(downloadState.status),
                              style: TextStyle(
                                color: downloadState.isError ? Colors.redAccent : AppTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (!downloadState.isComplete && !downloadState.isError)
                          Text(
                            '${(downloadState.progress * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fade(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
        ],
      ),
    );
  }
}
