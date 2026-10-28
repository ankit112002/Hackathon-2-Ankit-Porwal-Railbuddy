import 'package:flutter/material.dart';
import '../theme/colors.dart';

class TicketCard extends StatelessWidget {
  final Widget top;
  final Widget bottom;
  final double notchRadius;

  const TicketCard({
    super.key,
    required this.top,
    required this.bottom,
    this.notchRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Section (typically dark ink)
            Container(
              color: AppColors.ink,
              padding: const EdgeInsets.all(20),
              child: top,
            ),

            // Perforation Line with Side Notches
            SizedBox(
              height: notchRadius * 2,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    color: AppColors.white,
                  ),
                  // Left notch
                  Positioned(
                    left: -notchRadius,
                    child: Container(
                      width: notchRadius * 2,
                      height: notchRadius * 2,
                      decoration: const BoxDecoration(
                        color: AppColors.cream,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Dashed perforation line
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: notchRadius + 8),
                      child: CustomPaint(
                        painter: _DashedLinePainter(),
                      ),
                    ),
                  ),
                  // Right notch
                  Positioned(
                    right: -notchRadius,
                    child: Container(
                      width: notchRadius * 2,
                      height: notchRadius * 2,
                      decoration: const BoxDecoration(
                        color: AppColors.cream,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Section (white/cream)
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(20),
              child: bottom,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.5;

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = 0;
    final y = size.height / 2;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + dashWidth, y),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
