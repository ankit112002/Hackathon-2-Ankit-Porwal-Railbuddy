import 'package:flutter/material.dart';
import '../../logic/seat_utils.dart';
import '../theme/colors.dart';

enum SeatTileState {
  yours,
  groupMember,
  other,
  openToSwap,
  selected;
}

class SeatTile extends StatelessWidget {
  final int seatNo;
  final String? coach;
  final SeatTileState state;
  final VoidCallback? onTap;
  final String? occupantName;

  const SeatTile({
    super.key,
    required this.seatNo,
    this.coach,
    required this.state,
    this.onTap,
    this.occupantName,
  });

  String get _berthShort {
    final b = berthOf(seatNo);
    switch (b) {
      case 'Lower':
        return 'LB';
      case 'Middle':
        return 'MB';
      case 'Upper':
        return 'UB';
      case 'Side Lower':
        return 'SL';
      case 'Side Upper':
        return 'SU';
      default:
        return '';
    }
  }

  Color get _bgColor {
    switch (state) {
      case SeatTileState.yours:
        return AppColors.mint;
      case SeatTileState.groupMember:
        return const Color(0xFF6B4EE6); // Indigo / purple for group members
      case SeatTileState.openToSwap:
        return const Color(0xFFD8F2E6); // Light mint tint
      case SeatTileState.selected:
        return AppColors.ink;
      case SeatTileState.other:
        return AppColors.white;
    }
  }

  Color get _textColor {
    switch (state) {
      case SeatTileState.yours:
        return AppColors.ink;
      case SeatTileState.groupMember:
      case SeatTileState.selected:
        return AppColors.white;
      case SeatTileState.openToSwap:
        return const Color(0xFF0F5A3E);
      case SeatTileState.other:
        return AppColors.textPrimary;
    }
  }

  Color get _borderColor {
    switch (state) {
      case SeatTileState.selected:
        return AppColors.ink;
      case SeatTileState.openToSwap:
        return AppColors.mintPressed;
      case SeatTileState.yours:
        return AppColors.mint;
      case SeatTileState.groupMember:
        return const Color(0xFF6B4EE6);
      case SeatTileState.other:
        return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor, width: 1.5),
            boxShadow: state == SeatTileState.selected
                ? [
                    BoxShadow(
                      color: AppColors.ink.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$seatNo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _berthShort,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _textColor.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
