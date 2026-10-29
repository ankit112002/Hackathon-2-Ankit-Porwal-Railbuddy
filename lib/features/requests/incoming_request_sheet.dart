import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/ticket_card.dart';
import '../../models/passenger.dart';
import '../../models/swap_request.dart';
import 'swap_outcome_dialog.dart';

enum _SheetAction { accept, decline }

class IncomingRequestSheet extends StatefulWidget {
  final SwapRequest request;
  final Passenger? requester;
  final Passenger me;
  final Future<String> Function(String reqId) onAccept;
  final Future<void> Function(String reqId) onReject;

  const IncomingRequestSheet({
    super.key,
    required this.request,
    this.requester,
    required this.me,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<IncomingRequestSheet> createState() => _IncomingRequestSheetState();
}

class _IncomingRequestSheetState extends State<IncomingRequestSheet> {
  _SheetAction? _pending;

  bool get _isProcessing => _pending != null;

  Future<void> _handleAccept() async {
    if (_isProcessing) return;
    setState(() => _pending = _SheetAction.accept);
    try {
      final res = await widget.onAccept(widget.request.id);
      if (!mounted) return;
      final result = switch (res) {
        'invalid' => SwapSheetResult.seatChanged,
        'accepted' => SwapSheetResult.accepted,
        _ => SwapSheetResult.unavailable,
      };
      Navigator.of(context).pop(result);
    } catch (_) {
      if (!mounted) return;
      setState(() => _pending = null);
      _showActionError('Could not accept this request. Please try again.');
    }
  }

  Future<void> _handleReject() async {
    if (_isProcessing) return;
    setState(() => _pending = _SheetAction.decline);
    try {
      await widget.onReject(widget.request.id);
      if (!mounted) return;
      Navigator.of(context).pop(SwapSheetResult.declined);
    } catch (_) {
      if (!mounted) return;
      setState(() => _pending = null);
      _showActionError('Could not decline this request. Please try again.');
    }
  }

  void _showActionError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.rejected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requesterName = widget.requester?.name ?? 'A passenger';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sheet Title
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.mint.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.swap_calls_rounded,
                    color: AppColors.ink,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Incoming Seat Swap Request',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        'From $requesterName',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Ticket Card Comparison
            TicketCard(
              top: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Current Seat',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.request.targetSeat,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.swap_horiz_rounded,
                        color: AppColors.mint,
                        size: 28,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Offered Seat',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.request.requesterSeat,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
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
                  if (widget.request.message != null &&
                      widget.request.message!.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.format_quote_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.request.message!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    'Both passengers must accept to swap seats. No official railway tickets are modified.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : _handleReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.rejected,
                      side: const BorderSide(color: AppColors.rejected),
                      minimumSize: const Size.fromHeight(52),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _pending == _SheetAction.decline
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: AppColors.rejected,
                            ),
                          )
                        : const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Decline',
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: PrimaryButton(
                    label: 'Accept Swap',
                    isLoading: _pending == _SheetAction.accept,
                    showArrow: false,
                    onPressed: _handleAccept,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
