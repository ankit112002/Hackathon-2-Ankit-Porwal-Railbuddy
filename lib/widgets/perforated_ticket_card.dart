import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class StitchPerforatedTicketCard extends StatefulWidget {
  final VoidCallback? onSharePlan;
  final VoidCallback? onOpenSeatMap;
  final bool fullVibrantBackground;

  const StitchPerforatedTicketCard({
    super.key,
    this.onSharePlan,
    this.onOpenSeatMap,
    this.fullVibrantBackground = true,
  });

  @override
  State<StitchPerforatedTicketCard> createState() =>
      _StitchPerforatedTicketCardState();
}

class _StitchPerforatedTicketCardState extends State<StitchPerforatedTicketCard> {
  bool _isSharing = false;
  bool _shareDone = false;

  void _handleShare() {
    if (_isSharing) return;
    setState(() {
      _isSharing = true;
      _shareDone = false;
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _isSharing = false;
          _shareDone = true;
        });
      }
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) {
          setState(() {
            _shareDone = false;
          });
        }
      });
    });

    if (widget.onSharePlan != null) {
      widget.onSharePlan!();
    }
  }

  @override
  Widget build(BuildContext context) {
    const notchBg = AppColors.mintAccent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 16),
      child: Column(
        children: [
          // Screen Title (Exact text from user right image)
          Text(
            'Seat Optimized Swap',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.darkCharcoal,
              letterSpacing: -0.4,
            ),
          ),

          const SizedBox(height: 18),

          // PERFORATED TICKET CARD
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF141D1B).withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: [
                  // TOP CARD: Deep Dark Ink Panel (from user photo)
                  Container(
                    color: AppColors.darkCharcoal,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Coach & Bay Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'S2',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  'Coach',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFBACAC0),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '41–46',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  'Bay',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFBACAC0),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Sharma Family & ID Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sharma Family',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'ID-1234',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Subtitle & Status Dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '& Optimized Seating',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFBACAC0),
                              ),
                            ),
                            // Segmented Mini Indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: AppColors.rose,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: AppColors.mintAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // PERFORATION SEPARATOR WITH NOTCH CUTOUTS
                  Container(
                    color: Colors.white,
                    height: 24,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Center Dashed Line
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final dashWidth = 5.0;
                            final dashSpace = 4.0;
                            final count = (constraints.maxWidth - 48) ~/
                                (dashWidth + dashSpace);
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(count, (_) {
                                return Container(
                                  width: dashWidth,
                                  height: 1.5,
                                  margin: EdgeInsets.only(right: dashSpace),
                                  color: const Color(0xFFBACAC0),
                                );
                              }),
                            );
                          },
                        ),

                        // Left Circular Cutout Notch (colored to notchBg)
                        Positioned(
                          left: -12,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: notchBg,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        // Right Circular Cutout Notch (colored to notchBg)
                        Positioned(
                          right: -12,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: notchBg,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // BOTTOM CARD: White Ticket Surface (from user photo)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
                    child: Column(
                      children: [
                        // Split Seats Row: S2/41 Bhavna  &  S2/43 Aman
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'S2/41',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textDark,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  'Bhavna',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),

                            // Ampersand
                            Text(
                              '&',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'S2/43',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textDark,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  'Aman',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Barcode Representation
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 44,
                                width: double.infinity,
                                child: CustomPaint(
                                  painter: StitchBarcodePainter(),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '7 7 6 4 7 6 4 6 7 6 9 8 7 5 5 8 0 2 7 4',
                                style: GoogleFonts.robotoMono(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.0,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Bottom Action: "Show to TTE / Share Plan" Button (Exact from user right image)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _handleShare,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkCharcoal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isSharing) ...[
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.mintAccent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Generating Pass...',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ] else if (_shareDone) ...[
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.mintAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pass Ready & Saved',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.mintAccent,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Show to TTE / Share Plan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.open_in_new_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Barcode lines
class StitchBarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textDark
      ..style = PaintingStyle.fill;

    final widths = [
      3.0, 1.5, 4.0, 2.0, 1.0, 5.0, 2.0, 3.5, 1.0, 4.0, 2.0, 6.0, 1.5, 3.0,
      2.0, 4.0, 1.0, 5.0, 2.0, 3.0, 1.5, 4.0, 2.0, 3.0, 5.0, 1.0, 4.0, 2.0,
      1.5, 4.0, 3.0, 1.0, 5.0, 2.0, 3.5, 1.0, 4.0, 2.0, 5.0, 1.5, 3.0, 2.0,
      4.0, 1.0, 5.0, 2.0, 3.5, 1.5, 4.0,
    ];

    double currentX = 0;
    final totalPatternWidth = widths.reduce((a, b) => a + b) + widths.length * 2.0;
    final scale = size.width / totalPatternWidth;

    for (int i = 0; i < widths.length; i++) {
      final barWidth = widths[i] * scale;
      canvas.drawRect(
        Rect.fromLTWH(currentX, 0, barWidth, size.height),
        paint,
      );
      currentX += barWidth + (2.0 * scale);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
