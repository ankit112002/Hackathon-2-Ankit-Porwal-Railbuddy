import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Station Background Image (Full-bleed railway platform)
          Image.asset(
            'assets/images/station_background.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: const Color(0xFF0F1115));
            },
          ),

          // 2. Moody Cinematic Dark Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0F1115).withValues(alpha: 0.45),
                  const Color(0xFF0F1115).withValues(alpha: 0.70),
                  const Color(0xFF0F1115).withValues(alpha: 0.95),
                  const Color(0xFF0F1115),
                ],
                stops: const [0.0, 0.45, 0.75, 1.0],
              ),
            ),
          ),

          // 3. Foreground Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: RailBuddy Brand Tag & Skip Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1115).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: AppColors.mintAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.train_rounded,
                                color: Color(0xFF0F1115),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'RailBuddy',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onFinish,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            'Skip',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Segmented Carousel Indicators
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.mintAccent,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Hero Title (Exact text from user's left image)
                  Text(
                    'Sit Together,\nSwap Effortlessly',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.15,
                      letterSpacing: -0.8,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Subtitle (Exact text from user's left image)
                  Text(
                    'Swap seats with consent and bring your group together on the journey.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF94A3B8),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Primary CTA Button: "Get Started >>>" (Exact from user's image)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: widget.onFinish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mintAccent,
                        foregroundColor: const Color(0xFF0F1115),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Get Started',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F1115),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 22,
                                color: const Color(0xFF0F1115),
                              ),
                              Transform.translate(
                                offset: const Offset(-8, 0),
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  size: 22,
                                  color: const Color(0xFF0F1115).withValues(alpha: 0.65),
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(-16, 0),
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  size: 22,
                                  color: const Color(0xFF0F1115).withValues(alpha: 0.35),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Secondary Button: "I already have a group code"
                  Center(
                    child: TextButton.icon(
                      onPressed: widget.onFinish,
                      icon: const Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 16,
                        color: AppColors.mintAccent,
                      ),
                      label: Text(
                        'I already have a group code',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mintAccent,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
