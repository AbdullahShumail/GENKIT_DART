import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/onboarding_theme.dart';
import '../chat_screen.dart';

class InstallationScreen extends StatefulWidget {
  const InstallationScreen({super.key});

  @override
  State<InstallationScreen> createState() => _InstallationScreenState();
}

class _InstallationScreenState extends State<InstallationScreen> with TickerProviderStateMixin {
  late final AnimationController _progressController;
  late final AnimationController _waveController;
  int _phraseIndex = 0;
  bool _isSuccess = false;
  
  final List<String> _phrases = [
    "Allocating memory...",
    "Aligning weights...",
    "Structuring logic...",
    "Optimizing local inference...",
    "Almost ready..."
  ];

  @override
  void initState() {
    super.initState();
    
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6), // Fake 6 second download simulation
    )..forward().then((_) {
      setState(() => _isSuccess = true);
      Future.delayed(const Duration(milliseconds: 1200), _navigateToChat);
    });

    _progressController.addListener(() {
      final newIndex = (_progressController.value * _phrases.length).floor().clamp(0, _phrases.length - 1);
      if (newIndex != _phraseIndex) {
        setState(() => _phraseIndex = newIndex);
      }
    });
  }
  
  void _navigateToChat() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ChatScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.background,
      body: Stack(
        children: [
          // Interactive Particle Field
          Positioned.fill(
            child: const InteractiveParticleBackground()
                .animate(target: _isSuccess ? 1 : 0)
                .fade(end: 0, duration: 800.ms), // Fade out particles on success
          ),
          
          // Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Liquid Progress Indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    width: _isSuccess ? 140 : 120,
                    height: _isSuccess ? 140 : 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isSuccess ? Colors.transparent : OnboardingTheme.border, 
                        width: 1
                      ),
                      color: _isSuccess ? OnboardingTheme.textPrimary : OnboardingTheme.surface,
                      boxShadow: _isSuccess ? [
                        BoxShadow(
                          color: OnboardingTheme.textPrimary.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ] : [],
                    ),
                    child: _isSuccess 
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 48)
                          .animate().scale(duration: 400.ms, curve: Curves.easeOutBack)
                      : ClipOval(
                          child: AnimatedBuilder(
                            animation: Listenable.merge([_progressController, _waveController]),
                            builder: (context, child) {
                              return CustomPaint(
                                painter: LiquidProgressPainter(
                                  progress: _progressController.value,
                                  wavePhase: _waveController.value * 2 * pi,
                                ),
                              );
                            },
                          ),
                        ),
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 48),
                  
                  // Typewriter Text
                  SizedBox(
                    height: 24,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        _isSuccess ? "Initialization Complete" : _phrases[_phraseIndex],
                        key: ValueKey<String>(_isSuccess ? "done" : _phrases[_phraseIndex]),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: _isSuccess ? FontWeight.w500 : FontWeight.w400,
                          color: _isSuccess ? OnboardingTheme.textPrimary : OnboardingTheme.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Liquid Progress Painter ──────────────────────────────────────────────────
class LiquidProgressPainter extends CustomPainter {
  final double progress;
  final double wavePhase;

  LiquidProgressPainter({required this.progress, required this.wavePhase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = OnboardingTheme.textPrimary.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path = Path();
    final yOffset = size.height * (1 - progress);
    
    path.moveTo(0, size.height);
    path.lineTo(0, yOffset);

    // Draw fluid wave
    for (double i = 0; i <= size.width; i++) {
      final wave1 = sin((i / size.width * 2 * pi) + wavePhase) * 4;
      final wave2 = cos((i / size.width * 3 * pi) + wavePhase * 1.5) * 2;
      path.lineTo(i, yOffset + wave1 + wave2);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LiquidProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.wavePhase != wavePhase;
  }
}

// ─── Interactive Particle Background ──────────────────────────────────────────
class InteractiveParticleBackground extends StatefulWidget {
  const InteractiveParticleBackground({super.key});

  @override
  State<InteractiveParticleBackground> createState() => _InteractiveParticleBackgroundState();
}

class _InteractiveParticleBackgroundState extends State<InteractiveParticleBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();
  Offset? _touchPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateParticles)..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_particles.isEmpty) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < 40; i++) {
        _particles.add(Particle(
          x: _random.nextDouble() * size.width,
          y: _random.nextDouble() * size.height,
          vx: (_random.nextDouble() - 0.5) * 0.4,
          vy: (_random.nextDouble() - 0.5) * 0.4,
          size: _random.nextDouble() * 1.5 + 0.5, // Tiny minimalist particles
        ));
      }
    }
  }

  void _updateParticles() {
    final size = MediaQuery.of(context).size;
    for (var p in _particles) {
      // Basic movement
      p.x += p.vx;
      p.y += p.vy;

      // Mouse/Touch interaction repels particles gently
      if (_touchPosition != null) {
        final dx = p.x - _touchPosition!.dx;
        final dy = p.y - _touchPosition!.dy;
        final dist = sqrt(dx * dx + dy * dy);
        
        if (dist < 120) {
          final force = (120 - dist) / 120;
          p.x += (dx / dist) * force * 1.5;
          p.y += (dy / dist) * force * 1.5;
        }
      }

      // Wrapping bounds checking
      if (p.x < 0) p.x = size.width;
      if (p.x > size.width) p.x = 0;
      if (p.y < 0) p.y = size.height;
      if (p.y > size.height) p.y = 0;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() => _touchPosition = details.localPosition);
      },
      onPanEnd: (_) {
        setState(() => _touchPosition = null);
      },
      child: CustomPaint(
        painter: ParticlePainter(particles: _particles),
        size: Size.infinite,
      ),
    );
  }
}

class Particle {
  double x, y, vx, vy, size;
  Particle({required this.x, required this.y, required this.vx, required this.vy, required this.size});
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = OnboardingTheme.textPrimary.withOpacity(0.08); // Very subtle
    for (var p in particles) {
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
