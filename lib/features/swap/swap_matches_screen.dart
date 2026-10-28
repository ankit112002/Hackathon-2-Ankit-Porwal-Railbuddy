import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/seat_chip.dart';
import '../../logic/seat_utils.dart';
import '../../providers/providers.dart';

class SwapMatchesScreen extends ConsumerWidget {
  const SwapMatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPassenger = ref.watch(currentPassengerProvider);
    final matches = ref.watch(matchesProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text(
          'Matching Seats',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.ink),
            onPressed: () => context.push('/swap/preferences'),
          ),
        ],
      ),
      body: matches.isEmpty
          ? EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No Matching Seats Found',
              description:
                  'Try loosening your preferences (e.g. any berth, across coaches, or check back later).',
              buttonLabel: 'Adjust Preferences',
              onButtonPressed: () => context.push('/swap/preferences'),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                final target = match.passenger;
                final isSameCoach =
                    currentPassenger != null && target.coach == currentPassenger.coach;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.mint,
                              child: Text(
                                target.name.isNotEmpty ? target.name[0] : '?',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    target.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${berthOf(target.seatNo)} Berth · Bay ${(target.seatNo - 1) ~/ 8 + 1}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Match Score Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.mint.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${match.score}% MATCH',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0D6B49),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, color: AppColors.border),
                        Row(
                          children: [
                            SeatChip(coach: target.coach, seatNo: target.seatNo),
                            const SizedBox(width: 8),
                            if (isSameCoach)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.fieldGrey,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Same Coach',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                context.push('/swap/detail/${target.id}');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.ink,
                                foregroundColor: AppColors.white,
                                minimumSize: const Size(110, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Request',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_rounded, size: 14),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
