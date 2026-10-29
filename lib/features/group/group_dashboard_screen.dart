import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/dark_header_scaffold.dart';
import '../../core/widgets/station_backdrop.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/score_ring.dart';
import '../../core/widgets/seat_chip.dart';
import '../../core/widgets/stepper_bar.dart';
import '../../logic/score.dart';
import '../../models/swap_request.dart';
import '../../providers/providers.dart';
import '../walkthrough/walkthrough_keys.dart';
import '../walkthrough/walkthrough_target.dart';

class GroupDashboardScreen extends ConsumerWidget {
  const GroupDashboardScreen({super.key});

  int _deriveCurrentStep({
    required int score,
    required List<SwapRequest> activePlanRequests,
  }) {
    if (score == 100) return 3; // Seated
    if (activePlanRequests.isNotEmpty) {
      if (activePlanRequests.every(
        (r) => r.status == SwapRequestStatus.accepted,
      )) {
        return 3; // Seated
      }
      return 2; // Requests
    }
    return 1; // Plan / Group stage
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentPassengerProvider);
    final myGroup = ref.watch(myGroupProvider);
    final score = ref.watch(groupScoreProvider);
    final plan = ref.watch(planProvider);
    final activePlanRequests =
        ref.watch(activePlanRequestsProvider).valueOrNull ?? [];

    if (me == null || me.groupId == null || myGroup.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.cream,
          elevation: 0,
          title: const Text(
            'My Group',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
        body: WalkthroughTarget(
          id: WalkthroughTargetId.groupFocus,
          child: EmptyState(
            icon: Icons.group_add_rounded,
            title: 'Not in a Group Yet',
            description:
                'Create a group for your travel companions or join with an existing code to bring your seats together.',
            buttonLabel: 'Create Group',
            onButtonPressed: () => context.push('/group/create'),
          ),
        ),
      );
    }

    final spread = coachSpread(myGroup);
    final mainBay = getMainBay(myGroup);
    final currentStep = _deriveCurrentStep(
      score: score,
      activePlanRequests: activePlanRequests,
    );

    return DarkHeaderScaffold(
      headerImageAsset: AppImages.station,
      headerImageAlignment: const Alignment(0, -0.15),
      header: WalkthroughTarget(
        id: WalkthroughTargetId.groupFocus,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GROUP SEATING SCORE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.mint,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${myGroup.length} Group Members',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  ScoreRing(score: score),
                ],
              ),
              const SizedBox(height: 16),

              // Spread & Best Possible Subtext Card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.inkSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    Icon(
                      score == 100
                          ? Icons.celebration_rounded
                          : Icons.warning_amber_rounded,
                      color: score == 100
                          ? AppColors.mint
                          : const Color(0xFFF5A524),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        score == 100
                            ? 'Perfect! All members are seated together in the same bay.'
                            : 'Scattered across $spread coaches · ${plan != null ? "Best possible: ${plan.targetScore}/100 with ${plan.swaps.length} swaps" : "Analyzing swaps..."}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stepper Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: StepperBar(currentStep: currentStep),
          ),
          const SizedBox(height: 24),

          // Member List Header
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Group Members & Locations',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => context.push('/seat-map'),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Seat Map',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mintPressed,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: AppColors.mintPressed,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Member Rows
          ...myGroup.map((p) {
            final isMe = p.id == me.id;
            final status = getMemberStatus(p, mainBay);

            Color dotColor;
            String statusText;
            switch (status) {
              case MemberBayStatus.sameBay:
                dotColor = AppColors.accepted;
                statusText = 'Same Bay (Bay ${(p.seatNo - 1) ~/ 8 + 1})';
                break;
              case MemberBayStatus.sameCoach:
                dotColor = const Color(0xFFF5A524);
                statusText =
                    'Same Coach (${p.coach}), Bay ${(p.seatNo - 1) ~/ 8 + 1}';
                break;
              case MemberBayStatus.otherCoach:
                dotColor = AppColors.rejected;
                statusText = 'Different Coach (${p.coach})';
                break;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    // Status Dot
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Name and info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                p.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.mint.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'You',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            statusText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Seat Chip
                    SeatChip(coach: p.coach, seatNo: p.seatNo),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),

          // Primary Optimizer Button
          if (score < 100)
            PrimaryButton(
              label: 'Bring my group together',
              onPressed: () => context.push('/optimizer'),
            )
          else
            PrimaryButton(
              label: 'View Final Seating Plan',
              icon: Icons.confirmation_num_rounded,
              showArrow: true,
              onPressed: () => context.push('/final-plan'),
            ),
        ],
      ),
    );
  }
}
