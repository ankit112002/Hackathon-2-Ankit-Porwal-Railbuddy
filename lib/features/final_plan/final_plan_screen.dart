import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/seat_chip.dart';
import '../../core/widgets/ticket_card.dart';
import '../../logic/seat_utils.dart';
import '../../providers/providers.dart';

class FinalPlanScreen extends ConsumerWidget {
  const FinalPlanScreen({super.key});

  void _sharePlan(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Seating plan copied to clipboard for TTE / sharing!'),
        backgroundColor: AppColors.accepted,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myGroup = ref.watch(myGroupProvider);
    final trip = ref.watch(tripProvider).valueOrNull;
    final score = ref.watch(groupScoreProvider);

    if (myGroup.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Final Seating Plan')),
        body: const Center(child: Text('No group members found')),
      );
    }

    // Sort group members by seat number
    final sortedMembers = [...myGroup]
      ..sort((a, b) {
        final cmp = a.coach.compareTo(b.coach);
        if (cmp != 0) return cmp;
        return a.seatNo.compareTo(b.seatNo);
      });

    final coach = sortedMembers.first.coach;
    final minSeat = sortedMembers.map((m) => m.seatNo).reduce((a, b) => a < b ? a : b);
    final maxSeat = sortedMembers.map((m) => m.seatNo).reduce((a, b) => a > b ? a : b);
    final bayNumber = (minSeat - 1) ~/ 8 + 1;

    final summaryText = '''
RailBuddy Group Seating Arrangement
Train: ${trip?.trainNo ?? '12345'} ${trip?.trainName ?? 'Demo Express'}
Coach: $coach · Bay: $bayNumber (Seats $minSeat - $maxSeat)
Score: $score/100 (All ${myGroup.length} seated together)

Members:
${sortedMembers.map((m) => '• ${m.name}: Coach ${m.coach}, Seat ${m.seatNo} (${berthOf(m.seatNo)})').join('\n')}

Note: Swaps are voluntary and subject to railway rules.
''';

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text(
          'Final Seating Plan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          onPressed: () => context.go('/group'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        child: Column(
          children: [
            // Hero Ticket Card
            TicketCard(
              top: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.mint,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'OFFICIAL PLAN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      Text(
                        'SCORE $score/100',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.mint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'COACH',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white.withOpacity(0.6),
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            coach,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BAY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white.withOpacity(0.6),
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Bay $bayNumber',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'SEATS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white.withOpacity(0.6),
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$minSeat - $maxSeat',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColors.mint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              bottom: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SEATED PASSENGERS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        '${myGroup.length} Members',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Members Grid
                  ...sortedMembers.map((m) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.fieldGrey,
                            child: Text(
                              m.name.isNotEmpty ? m.name[0] : '?',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              m.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          Text(
                            berthOf(m.seatNo),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SeatChip(coach: m.coach, seatNo: m.seatNo),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 24, color: AppColors.border),

                  // Simulated Barcode
                  Center(
                    child: Column(
                      children: [
                        Container(
                          height: 40,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: AppColors.fieldGrey,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              38,
                              (i) => Container(
                                width: (i % 3 == 0) ? 3 : (i % 2 == 0 ? 2 : 1),
                                height: 28,
                                color: AppColors.ink.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'RAIL-PLAN-OK-100',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 3.0,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Mandatory Footnote
            Center(
              child: Text(
                'Swaps are voluntary and subject to railway rules.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary.withOpacity(0.8),
                ),
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
            label: 'Show to TTE / Share Plan',
            icon: Icons.share_rounded,
            showArrow: false,
            onPressed: () => _sharePlan(context, summaryText),
          ),
        ),
      ),
    );
  }
}
