import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/repositories/settings_repository.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardPage> _pages = const [
    _OnboardPage(
      emoji: '💰',
      title: 'Apna Hisaab\nRakho',
      subtitle:
          'Har din ki kamaai aur kharcha track karo.\nKoi bhi platform ho — sab yahan.',
      gradientColor: AppColors.gold,
    ),
    _OnboardPage(
      emoji: '🛵',
      title: 'Platform Wise\nTrack Karo',
      subtitle:
          'Zomato, Swiggy, Ola, Uber — sab alag\nalag dekho. Pata chale kaun deta hai zyada.',
      gradientColor: AppColors.profit,
    ),
    _OnboardPage(
      emoji: '📊',
      title: 'Weekly Stats\nDekho',
      subtitle:
          'Har hafte aur mahine ki progress dekho.\nBest day, average earning — sab clear.',
      gradientColor: AppColors.other,
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() async {
    await SettingsRepository().setOnboardingDone();
    if (!mounted) return;
    context.go('/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Pages
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return _PageContent(page: _pages[index], isActive: index == _currentPage);
            },
          ),

          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomControls(
              currentPage: _currentPage,
              totalPages: _pages.length,
              onNext: _onNext,
              onSkip: _finish,
              activeColor: _pages[_currentPage].gradientColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page content ───────────────────────────────────────────────────────────────

class _PageContent extends StatelessWidget {
  final _OnboardPage page;
  final bool isActive;

  const _PageContent({required this.page, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 60, 32, 180),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji illustration
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: page.gradientColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: page.gradientColor.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  page.emoji,
                  style: const TextStyle(fontSize: 90),
                )
                    .animate(target: isActive ? 1.0 : 0.0)
                    .scale(
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 350.ms),
              ),
            ),

            const SizedBox(height: 48),

            // Tag
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: page.gradientColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'STEP ${_pages.indexOf(page) + 1} OF 3',
                style: AppTextStyles.labelMd.copyWith(
                  color: page.gradientColor,
                ),
              ),
            ).animate(target: isActive ? 1.0 : 0.0).fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),

            const SizedBox(height: 16),

            // Title
            Text(
              page.title,
              style: AppTextStyles.displayMd.copyWith(
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ).animate(target: isActive ? 1.0 : 0.0).fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 16),

            // Subtitle
            Text(
              page.subtitle,
              style: AppTextStyles.bodyLg.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ).animate(target: isActive ? 1.0 : 0.0).fadeIn(delay: 200.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  static List<_OnboardPage> get _pages => const [
        _OnboardPage(emoji: '', title: '', subtitle: '', gradientColor: AppColors.gold),
        _OnboardPage(emoji: '', title: '', subtitle: '', gradientColor: AppColors.profit),
        _OnboardPage(emoji: '', title: '', subtitle: '', gradientColor: AppColors.other),
      ];
}

// ── Bottom controls ────────────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final Color activeColor;

  const _BottomControls({
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onSkip,
    required this.activeColor,
  });

  bool get isLast => currentPage == totalPages - 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 32,
        right: 32,
        top: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withValues(alpha: 0),
            AppColors.background,
            AppColors.background,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (i) {
              final active = i == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active
                      ? activeColor
                      : AppColors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          const SizedBox(height: 28),

          // Buttons row
          Row(
            children: [
              if (!isLast)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSkip,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.buttonLg.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              if (!isLast) const SizedBox(width: 12),
              Expanded(
                flex: isLast ? 1 : 2,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: activeColor,
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: onNext,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            isLast ? 'Shuru Karo 🚀' : 'Aage Chalo',
                            style: AppTextStyles.buttonLg.copyWith(
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Data model ─────────────────────────────────────────────────────────────────

class _OnboardPage {
  final String emoji;
  final String title;
  final String subtitle;
  final Color gradientColor;

  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradientColor,
  });

  int indexOf(List<_OnboardPage> list) => list.indexOf(this);
}
