import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/seat_chip.dart';
import '../../logic/seat_utils.dart';
import '../../providers/providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isToggling = false;

  Future<void> _switchPassenger() async {
    final session = ref.read(sessionStoreProvider);
    await session.clear();
    ref.read(currentPassengerIdProvider.notifier).state = null;
    if (!mounted) return;
    context.go('/select-passenger');
  }

  @override
  Widget build(BuildContext context) {
    final currentPassenger = ref.watch(currentPassengerProvider);

    if (currentPassenger == null) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(
          child: PrimaryButton(
            label: 'Select Passenger',
            onPressed: () => context.go('/select-passenger'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text(
          'Profile & Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          // Passenger Hero Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.mint,
                  child: Text(
                    currentPassenger.name.isNotEmpty
                        ? currentPassenger.name[0]
                        : '?',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  currentPassenger.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SeatChip(
                      coach: currentPassenger.coach,
                      seatNo: currentPassenger.seatNo,
                      isDark: true,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${berthOf(currentPassenger.seatNo)} Berth',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Open to Swap Toggle Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: currentPassenger.willingToSwap
                        ? AppColors.mint.withOpacity(0.2)
                        : AppColors.fieldGrey,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sync_alt_rounded,
                    color: currentPassenger.willingToSwap
                        ? AppColors.mintPressed
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Open to seat swap',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        currentPassenger.willingToSwap
                            ? 'Willing to accept swap requests'
                            : 'Currently not participating in swaps',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: currentPassenger.willingToSwap,
                  activeColor: AppColors.mintPressed,
                  onChanged: _isToggling
                      ? null
                      : (val) async {
                          setState(() => _isToggling = true);
                          try {
                            await ref
                                .read(passengerRepoProvider)
                                .updateWillingToSwap(currentPassenger.id, val);
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not update: $e')),
                            );
                          } finally {
                            if (mounted) setState(() => _isToggling = false);
                          }
                        },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Switch Demo User
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DEMO TESTING',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.ink.withOpacity(0.06),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.switch_account_rounded,
                      color: AppColors.ink,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Switch Demo Passenger',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  subtitle: const Text(
                    'Simulate testing from another passenger\'s perspective',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                  onTap: _switchPassenger,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // App Info
          Center(
            child: Column(
              children: [
                Text(
                  'RailBuddy v1.0.0 (Hackathon Edition)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Clean Pure Dart Architecture · Supabase Realtime',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
