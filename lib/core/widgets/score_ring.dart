import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ScoreRing extends StatefulWidget {
  final int score;
  final double size;
  final double strokeWidth;
  final String? subtitle;

  const ScoreRing({
    super.key,
    required this.score,
    this.size = 110,
    this.strokeWidth = 10,
    this.subtitle,
  });

  @override
  State<ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<ScoreRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldScore = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0, end: widget.score.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    _oldScore = widget.score.toDouble();
  }

  @override
  void didUpdateWidget(covariant ScoreRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation = Tween<double>(
        begin: _oldScore,
        end: widget.score.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
      _oldScore = widget.score.toDouble();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentVal = _animation.value;
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _ScoreRingPainter(
            score: currentVal,
            strokeWidth: widget.strokeWidth,
          ),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${currentVal.round()}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                      height: 1,
                    ),
                  ),
                  Text(
                    widget.subtitle ?? '/100',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double score;
  final double strokeWidth;

  _ScoreRingPainter({required this.score, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = AppColors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress
    final progressPaint = Paint()
      ..color = AppColors.mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 100) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.strokeWidth != strokeWidth;
  }
}
