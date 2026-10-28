import 'package:flutter/material.dart';
import '../theme/colors.dart';

class LoadingSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
  });

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.border.withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

class ListLoadingSkeleton extends StatelessWidget {
  final int count;

  const ListLoadingSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                LoadingSkeleton(width: 44, height: 44, borderRadius: 22),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LoadingSkeleton(width: 140, height: 16),
                      SizedBox(height: 8),
                      LoadingSkeleton(width: 90, height: 12),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                LoadingSkeleton(width: 60, height: 28, borderRadius: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
