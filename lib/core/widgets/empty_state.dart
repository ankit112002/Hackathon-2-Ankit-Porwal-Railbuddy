import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'primary_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.buttonLabel,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                icon,
                size: 36,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (buttonLabel != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                label: buttonLabel!,
                onPressed: onButtonPressed,
                showArrow: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
