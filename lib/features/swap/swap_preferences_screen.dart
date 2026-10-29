import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/seat_chip.dart';
import '../../logic/seat_utils.dart';
import '../../providers/providers.dart';

class SwapPreferencesScreen extends ConsumerStatefulWidget {
  const SwapPreferencesScreen({super.key});

  @override
  ConsumerState<SwapPreferencesScreen> createState() =>
      _SwapPreferencesScreenState();
}

class _SwapPreferencesScreenState
    extends ConsumerState<SwapPreferencesScreen> {
  final List<String> _berths = [
    'Lower',
    'Middle',
    'Upper',
    'Side Lower',
    'Side Upper',
  ];

  @override
  Widget build(BuildContext context) {
    final currentPassenger = ref.watch(currentPassengerProvider);
    final prefs = ref.watch(swapPrefsProvider);

    if (currentPassenger == null) {
      return const Scaffold(
        body: Center(child: Text('No passenger selected')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text(
          'Swap Preferences',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Seat Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.mint.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.airline_seat_recline_extra_rounded,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Current Seat',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
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
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Preferred Berth Section
            const Text(
              'Preferred Berth Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pick your favorite berth to give it the highest match priority (+40 pts).',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),

            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: [
                AppChip(
                  label: 'Any Berth',
                  isSelected: prefs.preferredBerth == null,
                  onTap: () {
                    ref.read(swapPrefsProvider.notifier).state =
                        prefs.copyWith(preferredBerth: () => null);
                  },
                ),
                ..._berths.map((b) {
                  final isSelected = prefs.preferredBerth == b;
                  return AppChip(
                    label: b,
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(swapPrefsProvider.notifier).state =
                          prefs.copyWith(preferredBerth: () => b);
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 28),

            // Matching Filters / Toggles
            const Text(
              'Matching Preferences',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 12),

            Material(
              color: AppColors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: prefs.sameCoachOnly,
                    activeColor: AppColors.mintPressed,
                    title: const Text(
                      'Same Coach Only',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    subtitle: Text(
                      'Only look for seats within ${currentPassenger.coach}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onChanged: (val) {
                      ref.read(swapPrefsProvider.notifier).state =
                          prefs.copyWith(sameCoachOnly: val);
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile.adaptive(
                    value: prefs.nearGroup,
                    activeColor: AppColors.mintPressed,
                    title: const Text(
                      'Sit Near My Group',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    subtitle: const Text(
                      'Prioritize seats in bays where family members sit',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onChanged: (val) {
                      ref.read(swapPrefsProvider.notifier).state =
                          prefs.copyWith(nearGroup: val);
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile.adaptive(
                    value: prefs.onlyOpen,
                    activeColor: AppColors.mintPressed,
                    title: const Text(
                      'Only Passengers Open to Swap',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    subtitle: const Text(
                      'Exclude passengers who disabled swap requests',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onChanged: (val) {
                      ref.read(swapPrefsProvider.notifier).state =
                          prefs.copyWith(onlyOpen: val);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: AppColors.cream,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: PrimaryButton(
            label: 'Find Matches',
            onPressed: () => context.push('/swap/matches'),
          ),
        ),
      ),
    );
  }
}
