import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/station_backdrop.dart';
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
    return const Scaffold(
      backgroundColor: AppColors.ink,
      body: StationBackdrop(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                Spacer(flex: 3),
                _SplashMark(),
                Spacer(flex: 4),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.mint,
                  ),
                ),
                SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashMark extends StatelessWidget {
  const _SplashMark();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.white.withOpacity(0.22)),
          ),
          child: const Icon(
            Icons.train_rounded,
            size: 38,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'RailBuddy',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: AppColors.white,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sit together, swap with consent',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.white.withOpacity(0.78),
          ),
        ),
      ],
    );
  }
}
