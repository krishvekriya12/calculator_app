import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../data/repositories/settings_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(AppConstants.splashDuration);
    if (!mounted) return;

    final done = SettingsRepository().onboardingDone;
    if (done) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Radial glow background ─────────────────────────────────────────
          Positioned.fill(
            child: CustomPaint(painter: _GlowPainter()),
          ),

          // ── Center content ─────────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo icon
                _LogoWidget()
                    .animate()
                    .scale(
                      begin: const Offset(0.4, 0.4),
                      end: const Offset(1.0, 1.0),
                      duration: 700.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 32),

                // App name
                Text(
                  'DAILY HISAAB',
                  style: AppTextStyles.headingLg.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    color: AppColors.textPrimary,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0, delay: 500.ms, duration: 600.ms),

                const SizedBox(height: 10),

                // Tagline
                Text(
                  AppConstants.appTagline,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 600.ms),
              ],
            ),
          ),

          // ── Version at bottom ──────────────────────────────────────────────
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Loader dots
                _LoadingDots()
                    .animate()
                    .fadeIn(delay: 1200.ms, duration: 400.ms),
                const SizedBox(height: 16),
                Text(
                  'v${AppConstants.appVersion}',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textMuted.withValues(alpha: 0.5),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1400.ms, duration: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logo widget ────────────────────────────────────────────────────────────────

class _LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [AppColors.goldLight, AppColors.gold, AppColors.goldDark],
          radius: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '₹',
          style: TextStyle(
            fontSize: 54,
            fontWeight: FontWeight.w900,
            color: AppColors.background,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ── Animated loading dots ──────────────────────────────────────────────────────

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )
        ..forward()
        ..addStatusListener((s) {
          if (s == AnimationStatus.completed) {
            _controllers[i].reverse();
          } else if (s == AnimationStatus.dismissed) {
            Future.delayed(Duration(milliseconds: 300 * i), () {
              if (mounted) _controllers[i].forward();
            });
          }
        }),
    );

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: 200 * i), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (_, _) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 
                  0.3 + (_controllers[i].value * 0.7),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ── Background glow painter ────────────────────────────────────────────────────

class _GlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.gold.withValues(alpha: 0.06),
          AppColors.background.withValues(alpha: 0),
        ],
        radius: 0.5,
      ).createShader(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2 - 60),
          width: size.width,
          height: size.height,
        ),
      );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2 - 60),
      size.width * 0.7,
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
