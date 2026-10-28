import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/seat_chip.dart';
import '../../core/widgets/ticket_card.dart';
import '../../logic/seat_utils.dart';
import '../../models/passenger.dart';
import '../../providers/providers.dart';

class SwapDetailScreen extends ConsumerStatefulWidget {
  final String targetPassengerId;

  const SwapDetailScreen({super.key, required this.targetPassengerId});

  @override
  ConsumerState<SwapDetailScreen> createState() => _SwapDetailScreenState();
}

class _SwapDetailScreenState extends ConsumerState<SwapDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest(Passenger me, Passenger target) async {
    setState(() => _isSending = true);
    try {
      await ref.read(requestRepoProvider).sendRequest(
            from: me,
            to: target,
            message: _messageController.text.trim().isNotEmpty
                ? _messageController.text.trim()
                : 'Hi, would you be interested in swapping seats?',
          );

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
              Icon(Icons.check_circle_rounded, color: AppColors.accepted, size: 28),
              SizedBox(width: 10),
              Text('Request Sent!'),
            ],
          ),
          content: Text(
            'Your seat swap request has been sent to ${target.name}. Once they accept, your seats will be updated automatically.',
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
          content: Text('Failed to send request: ${e.toString()}'),
          backgroundColor: AppColors.rejected,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentPassengerProvider);
    final allPassengers = ref.watch(tripPassengersProvider).valueOrNull ?? [];
    final target = allPassengers
        .where((p) => p.id == widget.targetPassengerId)
        .firstOrNull;

    if (me == null || target == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Request Detail')),
        body: const Center(child: Text('Passenger not found')),
      );
    }

    final isSameCoach = me.coach == target.coach;
    final seatDiff = (me.seatNo - target.seatNo).abs();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text(
          'Confirm Swap Request',
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
            // Ticket Card: My seat vs Their seat
            TicketCard(
              top: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PROPOSED SEAT SWAP',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.mint,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Your Seat
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You give',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SeatChip(coach: me.coach, seatNo: me.seatNo, isDark: true),
                          const SizedBox(height: 4),
                          Text(
                            berthOf(me.seatNo),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      // Swap Icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.mint,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.swap_horiz_rounded,
                          color: AppColors.ink,
                          size: 26,
                        ),
                      ),

                      // Target Seat
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'You receive',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SeatChip(
                            coach: target.coach,
                            seatNo: target.seatNo,
                            isDark: true,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            berthOf(target.seatNo),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
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
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.mint,
                        child: Text(
                          target.name.isNotEmpty ? target.name[0] : '?',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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
                              'Request to ${target.name}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              target.willingToSwap
                                  ? 'Currently open to seat swaps'
                                  : 'Not marked open',
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
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Why This Match Section
            const Text(
              'Why This Match',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildMatchBenefit(
                    icon: Icons.airline_seat_recline_extra_rounded,
                    title: '${berthOf(target.seatNo)} Berth',
                    subtitle: 'Matches your preferred berth type',
                  ),
                  const Divider(height: 20, color: AppColors.border),
                  _buildMatchBenefit(
                    icon: Icons.directions_railway_rounded,
                    title: isSameCoach
                        ? 'Same Coach (${target.coach})'
                        : 'Different Coach (${target.coach})',
                    subtitle: isSameCoach
                        ? 'No luggage transfer between coaches required'
                        : 'Requires moving between coaches',
                  ),
                  if (isSameCoach) ...[
                    const Divider(height: 20, color: AppColors.border),
                    _buildMatchBenefit(
                      icon: Icons.social_distance_rounded,
                      title: 'Distance: $seatDiff seat(s) apart',
                      subtitle: 'Located nearby in the same carriage',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Optional Message
            const Text(
              'Add a Friendly Note (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _messageController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText:
                    'e.g. Would love to swap so my family can be closer!',
                fillColor: AppColors.white,
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
            label: 'Send Swap Request',
            isLoading: _isSending,
            onPressed: () => _sendRequest(me, target),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchBenefit({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.mint.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.ink, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
