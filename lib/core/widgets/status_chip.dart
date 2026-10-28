import 'package:flutter/material.dart';
import '../../models/swap_request.dart';
import '../theme/colors.dart';

class StatusChip extends StatelessWidget {
  final SwapRequestStatus status;

  const StatusChip({super.key, required this.status});

  Color get _bg {
    switch (status) {
      case SwapRequestStatus.accepted:
        return AppColors.accepted.withOpacity(0.12);
      case SwapRequestStatus.pending:
        return AppColors.pending.withOpacity(0.15);
      case SwapRequestStatus.rejected:
      case SwapRequestStatus.invalid:
        return AppColors.rejected.withOpacity(0.12);
      case SwapRequestStatus.cancelled:
        return AppColors.textSecondary.withOpacity(0.12);
    }
  }

  Color get _fg {
    switch (status) {
      case SwapRequestStatus.accepted:
        return AppColors.accepted;
      case SwapRequestStatus.pending:
        return const Color(0xFFC77E00);
      case SwapRequestStatus.rejected:
      case SwapRequestStatus.invalid:
        return AppColors.rejected;
      case SwapRequestStatus.cancelled:
        return AppColors.textSecondary;
    }
  }

  String get _text {
    switch (status) {
      case SwapRequestStatus.accepted:
        return 'Accepted';
      case SwapRequestStatus.pending:
        return 'Pending';
      case SwapRequestStatus.rejected:
        return 'Rejected';
      case SwapRequestStatus.invalid:
        return 'Invalid';
      case SwapRequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _fg,
            ),
          ),
        ],
      ),
    );
  }
}
