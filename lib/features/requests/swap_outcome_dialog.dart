import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../models/passenger.dart';
import '../../models/swap_request.dart';

enum SwapSheetResult { accepted, declined, seatChanged, unavailable }

/// Confirmation shown to the passenger who just answered a swap request.
/// Kept off the bottom sheet so closing the sheet cannot dismiss it.
Future<void> showVolunteerSwapOutcomeDialog(
  BuildContext context, {
  required SwapSheetResult result,
  required SwapRequest request,
  required String requesterName,
}) {
  final title = switch (result) {
    SwapSheetResult.accepted => 'Swap accepted',
    SwapSheetResult.declined => 'Request declined',
    SwapSheetResult.seatChanged => 'Swap no longer possible',
    SwapSheetResult.unavailable => 'Request already closed',
  };
  final message = switch (result) {
    SwapSheetResult.accepted =>
      'You accepted $requesterName\'s swap. You move to seat ${request.requesterSeat}, and $requesterName moves to seat ${request.targetSeat}.',
    SwapSheetResult.declined =>
      'You declined $requesterName\'s request to exchange your seat ${request.targetSeat} for seat ${request.requesterSeat}. Both seats stay as they are. $requesterName can see this under Rejected requests and choose another volunteer.',
    SwapSheetResult.seatChanged =>
      'This swap with $requesterName could not be completed because a seat changed. Your seat ${request.targetSeat} is unchanged.',
    SwapSheetResult.unavailable =>
      'This request from $requesterName is no longer waiting for your reply.',
  };
  final icon = switch (result) {
    SwapSheetResult.accepted => Icons.check_circle_rounded,
    SwapSheetResult.declined => Icons.do_not_disturb_on_rounded,
    SwapSheetResult.seatChanged => Icons.error_outline_rounded,
    SwapSheetResult.unavailable => Icons.info_outline_rounded,
  };
  final iconColor = result == SwapSheetResult.accepted
      ? AppColors.accepted
      : result == SwapSheetResult.declined ||
              result == SwapSheetResult.seatChanged
          ? AppColors.rejected
          : AppColors.pending;

  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (ctx) => _OutcomeDialog(
      icon: icon,
      iconColor: iconColor,
      title: title,
      message: message,
      primaryLabel: 'Done',
      onPrimary: () => Navigator.of(ctx).pop(),
    ),
  );
}

/// Shown to the passenger who sent the request, once a volunteer declines.
Future<void> showRequesterDeclinedDialog(
  BuildContext context, {
  required List<SwapRequest> requests,
  required List<Passenger> passengers,
  required VoidCallback onViewRejected,
}) {
  final names = requests
      .map((request) {
        final match = passengers
            .where((passenger) => passenger.id == request.targetId)
            .firstOrNull;
        return match?.name ?? 'A volunteer';
      })
      .toSet()
      .toList();
  final allInvalid = requests.isNotEmpty &&
      requests.every((request) => request.status == SwapRequestStatus.invalid);
  final who = names.length == 1
      ? names.first
      : names.length == 2
          ? '${names[0]} and ${names[1]}'
          : '${names.length} volunteers';
  final message = allInvalid
      ? '$who could not complete the swap because a seat changed. Your seat is unchanged. Send a new request from Rejected requests.'
      : names.length == 1
          ? '$who declined your seat swap. Your seat is unchanged. You can ask someone else from Rejected requests.'
          : '$who declined your seat swaps. Your seats are unchanged. Review Rejected requests to find other volunteers.';

  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (ctx) => _OutcomeDialog(
      icon: Icons.do_not_disturb_on_rounded,
      iconColor: AppColors.rejected,
      title: names.length == 1 ? 'Swap declined' : 'Swaps declined',
      message: message,
      primaryLabel: 'Review declined',
      onPrimary: () {
        Navigator.of(ctx).pop();
        onViewRejected();
      },
      secondaryLabel: 'Stay here',
      onSecondary: () => Navigator.of(ctx).pop(),
    ),
  );
}

class _OutcomeDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const _OutcomeDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.white,
      title: Row(
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          height: 1.4,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        if (secondaryLabel != null)
          TextButton(
            onPressed: onSecondary,
            child: Text(
              secondaryLabel!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ElevatedButton(
          onPressed: onPrimary,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mint,
            foregroundColor: AppColors.ink,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            primaryLabel,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
