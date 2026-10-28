import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/dark_header_scaffold.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/seat_chip.dart';
import '../../logic/seat_utils.dart';
import '../../providers/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedModeIndex = 0; // 0: Group, 1: Single swap, 2: Multi swap
  bool _isTogglingSwap = false;

  @override
  Widget build(BuildContext context) {
    final currentPassenger = ref.watch(currentPassengerProvider);
    final tripAsync = ref.watch(tripProvider);
    final myGroup = ref.watch(myGroupProvider);

    if (currentPassenger == null) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No passenger selected'),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Select Passenger',
                onPressed: () => context.go('/select-passenger'),
                showArrow: false,
              ),
            ],
          ),
        ),
      );
    }

    return DarkHeaderScaffold(
      header: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Greeting & Avatar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentPassenger.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => context.push('/profile'),
                  borderRadius: BorderRadius.circular(22),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.mint,
                    child: Text(
                      currentPassenger.name.isNotEmpty
                          ? currentPassenger.name[0]
                          : '?',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Train Banner Chip
            tripAsync.when(
              data: (trip) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.inkSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.white.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.train_rounded,
                      size: 16,
                      color: AppColors.mint,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${trip.trainNo} ${trip.trainName}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      trip.journeyDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const LoadingSkeleton(width: 200, height: 32),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'YOUR RESERVATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/trip'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mintPressed,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // From & To Station Row
                tripAsync.when(
                  data: (trip) => Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'From',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              trip.fromStation,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            if (trip.departTime != null)
                              Text(
                                trip.departTime!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppColors.fieldGrey,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: AppColors.ink,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'To',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              trip.toStation,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            if (trip.arriveTime != null)
                              Text(
                                trip.arriveTime!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  loading: () => const LoadingSkeleton(height: 48),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const Divider(height: 28, color: AppColors.border),

                // Seat & Travellers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Seat',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            SeatChip(
                              coach: currentPassenger.coach,
                              seatNo: currentPassenger.seatNo,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              berthOf(currentPassenger.seatNo),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Travellers',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          myGroup.isNotEmpty
                              ? '${myGroup.length} in group'
                              : '1 solo',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Mode Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AppChip(
                  label: 'Group Seating',
                  icon: Icons.groups_rounded,
                  isSelected: _selectedModeIndex == 0,
                  onTap: () => setState(() => _selectedModeIndex = 0),
                ),
                const SizedBox(width: 8),
                AppChip(
                  label: 'Single Swap',
                  icon: Icons.swap_horiz_rounded,
                  isSelected: _selectedModeIndex == 1,
                  onTap: () {
                    setState(() => _selectedModeIndex = 1);
                    context.push('/swap/preferences');
                  },
                ),
                const SizedBox(width: 8),
                AppChip(
                  label: 'Coach Map',
                  icon: Icons.grid_view_rounded,
                  isSelected: _selectedModeIndex == 2,
                  onTap: () {
                    setState(() => _selectedModeIndex = 2);
                    context.push('/seat-map');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // "Seat swap open" Toggle Card
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
                    Icons.swap_calls_rounded,
                    color: currentPassenger.willingToSwap
                        ? AppColors.mintPressed
                        : AppColors.textSecondary,
                    size: 22,
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
                            ? 'Fellow passengers can request swaps'
                            : 'You are hidden from swap suggestions',
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
                  onChanged: _isTogglingSwap
                      ? null
                      : (val) async {
                          setState(() => _isTogglingSwap = true);
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
                            if (mounted) {
                              setState(() => _isTogglingSwap = false);
                            }
                          }
                        },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Primary Action Button
          PrimaryButton(
            label: currentPassenger.groupId != null
                ? 'Bring group together'
                : 'Create or join a group',
            onPressed: () {
              if (currentPassenger.groupId != null) {
                context.go('/group');
              } else {
                context.push('/group/create');
              }
            },
          ),
          const SizedBox(height: 20),

          // Footnote as mandated by SPEC Section 1
          Center(
            child: Text(
              'Swaps are voluntary and subject to railway rules.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
