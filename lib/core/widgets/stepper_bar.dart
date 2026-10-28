import 'package:flutter/material.dart';
import '../theme/colors.dart';

class StepperBar extends StatelessWidget {
  final int currentStep; // 0: Group, 1: Plan, 2: Requests, 3: Seated

  const StepperBar({super.key, required this.currentStep});

  static const _steps = ['Group', 'Plan', 'Requests', 'Seated'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepBefore = index ~/ 2;
          final isCompleted = stepBefore < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? AppColors.mint : AppColors.border,
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final isActive = stepIndex == currentStep;
        final isCompleted = stepIndex < currentStep;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.mint
                    : (isActive ? AppColors.ink : AppColors.fieldGrey),
                border: Border.all(
                  color: isCompleted || isActive
                      ? Colors.transparent
                      : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: AppColors.ink)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isActive ? AppColors.mint : AppColors.textSecondary,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _steps[stepIndex],
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.ink : AppColors.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }
}
