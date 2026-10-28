import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../providers/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final sessionStore = ref.read(sessionStoreProvider);
    final onboardingSeen = sessionStore.isOnboardingSeen();
    final passengerId = sessionStore.getPassengerId();

    if (!onboardingSeen) {
      context.go('/onboarding');
    } else if (passengerId == null || passengerId.isEmpty) {
      context.go('/select-passenger');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mint.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: const Icon(
                Icons.train_rounded,
                size: 48,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'RailBuddy',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sit Together, Travel Better',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.mint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
