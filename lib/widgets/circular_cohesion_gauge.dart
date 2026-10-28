import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CircularCohesionGauge extends StatelessWidget {
  final double score; // 0 to 100
  final double size;
  final double strokeWidth;
  final bool showLabel;
  final Color? trackColor;
  final Color? progressColor;

  const CircularCohesionGauge({
    super.key,
    required this.score,
    this.size = 110,
    this.strokeWidth = 10,
    this.showLabel = true,
    this.trackColor,
    this.progressColor,
  });

  List<Color> _getGradientColors() {
    if (progressColor != null) {
      return [progressColor!, progressColor!];
    }
    if (score >= 80) {
      return const [Color(0xFF10B981), Color(0xFF059669)]; // Mint to Emerald
    } else if (score >= 50) {
      return const [Color(0xFFFBBF24), Color(0xFFD97706)]; // Amber
    } else {
      return const [Color(0xFFFB7185), Color(0xFFE11D48)]; // Rose
    }
  }

  Color _getScoreColor() {
    if (progressColor != null) return progressColor!;
    if (score >= 80) return AppColors.emerald;
    if (score >= 50) return AppColors.amber;
    return AppColors.rose;
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _getGradientColors();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient soft inner glow for high cohesion
          if (score >= 80)
            Container(
              width: size * 0.72,
              height: size * 0.72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.emerald.withValues(alpha: 0.06),
              ),
            ),

          CustomPaint(
            size: Size(size, size),
            painter: _CohesionGaugePainter(
              progress: score / 100.0,
              strokeWidth: strokeWidth,
              trackColor: trackColor ?? const Color(0xFFE2E8F0).withValues(alpha: 0.8),
              gradientColors: gradientColors,
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${score.toInt()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: size * 0.28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: -0.8,
                      ),
                    ),
                    TextSpan(
                      text: '%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: size * 0.14,
                        fontWeight: FontWeight.w700,
                        color: _getScoreColor(),
                      ),
                    ),
                  ],
                ),
              ),
              if (showLabel) ...[
                const SizedBox(height: 1),
                Text(
                  'Cohesion',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: size * 0.11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CohesionGaugePainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final List<Color> gradientColors;

  _CohesionGaugePainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Active Arc with smooth gradient
    final clampedProgress = progress.clamp(0.01, 1.0);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: gradientColors,
        startAngle: -pi / 2,
        endAngle: -pi / 2 + (2 * pi * clampedProgress),
        transform: const GradientRotation(-pi / 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * clampedProgress;
    canvas.drawArc(
      rect,
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CohesionGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.gradientColors != gradientColors;
  }
}
