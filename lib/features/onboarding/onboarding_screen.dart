import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<({String title, String subtitle, IconData icon, String tag})> _slides = [
    (
      title: 'Scattered seats?\nSit together.',
      subtitle:
          'RailBuddy connects you with fellow passengers to voluntary swap berths and bring groups together.',
      icon: Icons.groups_rounded,
      tag: 'GROUP SEATING'
    ),
    (
      title: 'Smart Coach\nOptimizer.',
      subtitle:
          'Our matching algorithm calculates the optimal swaps with the fewest changes to seat your family in one bay.',
      icon: Icons.auto_awesome_rounded,
      tag: 'BAY ALIGNMENT'
    ),
    (
      title: '100% Voluntary\n& Consensual.',
      subtitle:
          'Every swap requires mutual passenger consent. Swaps are subject to official railway rules and cooperation.',
      icon: Icons.handshake_rounded,
      tag: 'MUTUAL CONSENT'
    ),
  ];

  Future<void> _completeOnboarding() async {
    final sessionStore = ref.read(sessionStoreProvider);
    await sessionStore.setOnboardingSeen(true);
    if (!mounted) return;
    context.go('/select-passenger');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Top Bar with Skip
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mint,
                    ),
                  ),
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: AppColors.inkSoft,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.mint.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                slide.icon,
                                size: 64,
                                color: AppColors.mint,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.mint.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            slide.tag,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.mint,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.title,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                            height: 1.15,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.subtitle,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: AppColors.white.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Page Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? AppColors.mint
                          : AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Bottom Button
              PrimaryButton(
                label: _currentIndex == _slides.length - 1
                    ? 'Get Started'
                    : 'Continue',
                onPressed: () {
                  if (_currentIndex < _slides.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _completeOnboarding();
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
