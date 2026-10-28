import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/seat_chip.dart';
import '../../logic/seat_utils.dart';
import '../../models/plan.dart';
import '../../providers/providers.dart';

class OptimizerScreen extends ConsumerStatefulWidget {
  const OptimizerScreen({super.key});

  @override
  ConsumerState<OptimizerScreen> createState() => _OptimizerScreenState();
}

class _OptimizerScreenState extends ConsumerState<OptimizerScreen> {
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _tryAnotherPlan(Plan currentPlan) {
    // Add current plan volunteers to excludedIds
    final currentExcluded = ref.read(excludedIdsProvider);
    final newExcluded = {
      ...currentExcluded,
      ...currentPlan.swaps.map((s) => s.volunteer.id),
    };
    ref.read(excludedIdsProvider.notifier).state = newExcluded;
  }

  Future<void> _sendAllRequests(Plan plan) async {
    final trip = ref.read(tripProvider).valueOrNull;
    if (trip == null) return;

    setState(() => _isSending = true);
    try {
      final sent = await ref.read(requestRepoProvider).sendPlanRequests(
            plan,
            trip.id,
          );
      ref.read(activePlanIdProvider.notifier).state = sent.planId;

      if (!mounted) return;

      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: AppColors.white,
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: AppColors.accepted, size: 28),
              SizedBox(width: 10),
              Text('Requests Sent!'),
            ],
          ),
          content: Text(
            '${plan.swaps.length} swap requests have been sent to volunteers in Coach ${plan.coach}. Track their responses live in the Requests tab.',
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/requests');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mint,
                foregroundColor: AppColors.ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('View Requests'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending requests: ${e.toString()}'),
          backgroundColor: AppColors.rejected,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentScore = ref.watch(groupScoreProvider);
    final plan = ref.watch(planProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text(
          'Group Arrangement Plan',
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
      body: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  LoadingSkeleton(height: 120, borderRadius: 20),
                  SizedBox(height: 20),
                  ListLoadingSkeleton(count: 4),
                ],
              ),
            )
          : plan == null
              ? EmptyState(
                  icon: Icons.sentiment_dissatisfied_rounded,
                  title: 'Arrangement not possible right now',
                  description:
                      'There are not enough willing volunteers in a single bay or coach to seat your whole group together. Try again later or adjust individual preferences.',
                  buttonLabel: 'Back to Group',
                  onButtonPressed: () => Navigator.of(context).pop(),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Before & After Score Hero Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.ink.withOpacity(0.1),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'CURRENT SCORE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textSecondary,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$currentScore/100',
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.mint.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.trending_up_rounded,
                                        color: AppColors.mint,
                                        size: 20,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'OPTIMAL',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.mint,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'TARGET SCORE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.mint,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${plan.targetScore}/100',
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.mint,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 24, color: AppColors.inkSoft),
                            Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.mint,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    plan.bay != null
                                        ? 'Target: Coach ${plan.coach}, Bay ${plan.bay! + 1} (Seats ${plan.bay! * 8 + 1}-${plan.bay! * 8 + 8})'
                                        : 'Target: All seated within Coach ${plan.coach}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Swaps Header & Try Another Plan
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Proposed Swaps (${plan.swaps.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          TextButton(
                            onPressed: () => _tryAnotherPlan(plan),
                            child: const Text(
                              'Try another plan',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.mintPressed,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // List of Proposed Swaps
                      ...plan.swaps.map((pair) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                // Member
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pair.member.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      SeatChip(
                                        coach: pair.member.coach,
                                        seatNo: pair.member.seatNo,
                                      ),
                                      Text(
                                        berthOf(pair.member.seatNo),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Arrow
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.mint.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: AppColors.ink,
                                  ),
                                ),

                                // Volunteer
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        pair.volunteer.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      SeatChip(
                                        coach: pair.volunteer.coach,
                                        seatNo: pair.volunteer.seatNo,
                                      ),
                                      Text(
                                        berthOf(pair.volunteer.seatNo),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
      bottomSheet: plan != null
          ? Container(
              color: AppColors.cream,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: SafeArea(
                top: false,
                child: PrimaryButton(
                  label: 'Send all ${plan.swaps.length} requests',
                  isLoading: _isSending,
                  onPressed: () => _sendAllRequests(plan),
                ),
              ),
            )
          : null,
    );
  }
}
