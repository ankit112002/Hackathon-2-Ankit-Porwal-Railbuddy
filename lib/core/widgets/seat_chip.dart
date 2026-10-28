import 'package:flutter/material.dart';
import '../theme/colors.dart';

class SeatChip extends StatelessWidget {
  final String coach;
  final int seatNo;
  final bool isDark;

  const SeatChip({
    super.key,
    required this.coach,
    required this.seatNo,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inkSoft : AppColors.fieldGrey,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isDark ? AppColors.inkSoft : AppColors.border,
          width: 1,
        ),
      ),
      child: Text(
        '$coach / $seatNo',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.white : AppColors.ink,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
