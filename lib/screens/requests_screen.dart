import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin {
  // Preferred berth multi-select set
  final Set<String> _selectedBerths = {'Lower', 'Side Lower'};

  // Options toggles
  bool _sameCoachOnly = false;
  bool _sitNearGroup = true;
  bool _openToSwapOnly = true;

  // Radar animation controller
  late AnimationController _radarController;


  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  void _toggleBerth(String berth) {
    setState(() {
      if (_selectedBerths.contains(berth)) {
        if (_selectedBerths.length > 1) {
          _selectedBerths.remove(berth);
        }
      } else {
        _selectedBerths.add(berth);
      }
    });
  }

  void _showSwapSuccessSheet(String matchPassenger, String seat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.mintAccent.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.forestMint,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Swap Request Dispatched!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sent to $matchPassenger for Seat $seat. You will be notified the instant they accept.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mintAccent,
                  foregroundColor: AppColors.darkCharcoal,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Great, Understood',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Dark Contextual Header (Stitch Screen 4)
          _buildDarkHeader(),

          // 2. Sheet Canvas Overlapping Container
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Assigned Seat Card
                  _buildAssignedSeatCard(),
                  const SizedBox(height: 12),

                  // Sharma Family Context Banner
                  _buildGroupContextBanner(),
                  const SizedBox(height: 18),

                  // Preferred Berth Chips (Multi-Select)
                  _buildBerthSelectionSection(),
                  const SizedBox(height: 18),

                  // Options Toggles
                  _buildOptionsCard(),
                  const SizedBox(height: 16),

                  // Radar Live Beacon Banner
                  _buildRadarBanner(),
                  const SizedBox(height: 20),

                  // Live Matched Opportunities Feed
                  _buildMatchedFeed(),
                  const SizedBox(height: 20),

                  // Disclaimer
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Seat swaps are voluntary between consenting passengers and subject to Indian Railways passenger rules.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textLight,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Sticky Primary CTA
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.darkCharcoal,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.radar_rounded,
                                  color: AppColors.mintAccent,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Scanning 6 nearby passengers in S2...',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mintAccent,
                        foregroundColor: AppColors.darkCharcoal,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Find Matches',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkCharcoal,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 19,
                            color: AppColors.darkCharcoal,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Dark Header (Stitch Screen 4)
  Widget _buildDarkHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.darkCharcoal,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.mintAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  'Train #12951 · Rajdhani',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mintAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Swap my seat',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Find a fellow passenger to exchange with',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFBACAC0),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Assigned Seat Card
  Widget _buildAssignedSeatCard() {
    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.darkCharcoal,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.airline_seat_flat_rounded,
                  color: AppColors.mintAccent,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'S1 / 23',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.mintSurfaceLow,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          'Assigned',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.forestMint,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Coach S1 · Bay 3 · Middle berth',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.mintSurfaceLow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_rounded,
              size: 16,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Group Context Banner
  Widget _buildGroupContextBanner() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorderSubtle),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Avatar Cluster
          SizedBox(
            width: 58,
            height: 28,
            child: Stack(
              children: [
                _buildAvatarMini('A', 0, AppColors.forestMint),
                _buildAvatarMini('B', 16, AppColors.mintAccent),
                Positioned(
                  left: 32,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.darkCharcoal,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '+4',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.mintAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Traveling with Sharma Family',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'Coaches S1 & S2 (Split across 2 bays)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.groups_rounded,
            color: AppColors.forestMint,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarMini(String letter, double left, Color bg) {
    return Positioned(
      left: left,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: bg == AppColors.mintAccent ? AppColors.darkCharcoal : Colors.white,
          ),
        ),
      ),
    );
  }

  // 4. Preferred Berth Selection
  Widget _buildBerthSelectionSection() {
    final berths = [
      'Lower',
      'Middle',
      'Upper',
      'Side Lower',
      'Side Upper',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Preferred berth',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            Text(
              'Multi-select enabled',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: berths.map((b) {
            final isSelected = _selectedBerths.contains(b);
            return GestureDetector(
              onTap: () => _toggleBerth(b),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.mintAccent
                      : AppColors.mintSurfaceHighest,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.mintAccent.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: AppColors.mintDark,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      b,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? AppColors.mintDark
                            : AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 5. Options Switches (Same coach, Near group, Open to swap only)
  Widget _buildOptionsCard() {
    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          _buildToggleRow(
            title: 'Same coach only',
            subtitle: 'Prioritize swaps within Coach S1',
            value: _sameCoachOnly,
            onChanged: (v) => setState(() => _sameCoachOnly = v),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.cardBorderSubtle, height: 1),
          ),
          _buildToggleRow(
            title: 'Sit near my group',
            subtitle: 'Target Coach S2 where Sharma Family has 2 seats',
            value: _sitNearGroup,
            hasDot: true,
            onChanged: (v) => setState(() => _sitNearGroup = v),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.cardBorderSubtle, height: 1),
          ),
          _buildToggleRow(
            title: 'Only show passengers open to swap',
            subtitle: 'Hide passengers who have disabled swap requests',
            value: _openToSwapOnly,
            onChanged: (v) => setState(() => _openToSwapOnly = v),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    bool hasDot = false,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (hasDot) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.forestMint,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46,
            height: 26,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: value
                  ? AppColors.mintAccent
                  : AppColors.mintSurfaceHighest,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 21,
                height: 21,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 6. Radar Banner (Stitch)
  Widget _buildRadarBanner() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mintSurfaceLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mintSurfaceHigh),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.mintAccent.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.radar_rounded,
              color: AppColors.forestMint,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '6 active passengers nearby',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedBuilder(
                      animation: _radarController,
                      builder: (context, child) {
                        return Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: AppColors.forestMint.withValues(
                              alpha: 0.4 + 0.6 * _radarController.value,
                            ),
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Text(
                  'Ready to match your preferences',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 7. Live Matched Opportunities Feed
  Widget _buildMatchedFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LIVE SWAP CANDIDATES',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textDark,
              ),
            ),
            Text(
              'Coach S2 Priority',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.forestMint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _buildMatchCandidateCard(
          name: 'Priyanka M.',
          persona: 'Solo Traveler · Travelling to Kota',
          offerSeat: 'Coach S2 / Seat 43',
          offerBerth: 'Upper Berth (UB)',
          matchScore: 98,
          reason: 'Open to swap for any middle or lower berth in S1',
        ),

        const SizedBox(height: 10),

        _buildMatchCandidateCard(
          name: 'Amit S.',
          persona: 'Solo Traveler · Travelling to Ratlam',
          offerSeat: 'Coach S2 / Seat 44',
          offerBerth: 'Upper Berth (UB)',
          matchScore: 95,
          reason: 'Happy to move to Coach S1 to reunite your family',
        ),

        const SizedBox(height: 10),

        _buildMatchCandidateCard(
          name: 'Rahul K.',
          persona: 'Solo Passenger · Surat',
          offerSeat: 'Coach S2 / Seat 47',
          offerBerth: 'Side Lower Berth (SL)',
          matchScore: 91,
          reason: 'Agreed to trade for Coach S1 middle berth',
        ),
      ],
    );
  }

  Widget _buildMatchCandidateCard({
    required String name,
    required String persona,
    required String offerSeat,
    required String offerBerth,
    required int matchScore,
    required String reason,
  }) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: AppColors.forestMint,
                    child: Text(
                      name[0],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        persona,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.mintAccent.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  '$matchScore% Match',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forestMint,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.mintSurfaceLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.airline_seat_recline_normal_rounded,
                  size: 16,
                  color: AppColors.forestMint,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Offers: $offerSeat ($offerBerth)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '"$reason"',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontStyle: FontStyle.italic,
              color: AppColors.textMuted,
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed: () => _showSwapSuccessSheet(name, offerSeat),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestMint,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Request Instant Swap',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
