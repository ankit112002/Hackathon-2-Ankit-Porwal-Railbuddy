import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/passenger.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';

class CoachSeatMapScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onConsolidateSuccess;

  const CoachSeatMapScreen({
    super.key,
    required this.onBack,
    required this.onConsolidateSuccess,
  });

  @override
  State<CoachSeatMapScreen> createState() => _CoachSeatMapScreenState();
}

class _CoachSeatMapScreenState extends State<CoachSeatMapScreen> {
  String _selectedCoach = 'Coach S2';
  final int _selectedBay = 7;
  bool _isOptimized = false;
  int? _selectedSeatNumber;

  final List<Map<String, dynamic>> _coachInfo = [
    {'name': 'Coach S1', 'members': 1, 'note': 'Aman (You)'},
    {'name': 'Coach S2', 'members': 2, 'note': 'Bhavna, Chetan'},
    {'name': 'Coach S3', 'members': 1, 'note': 'Disha'},
    {'name': 'Coach S4', 'members': 1, 'note': 'Esha'},
    {'name': 'Coach S5', 'members': 1, 'note': 'Farhan'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top App Bar
        _buildTopBar(),

        // Coach Selector horizontal pills
        _buildCoachSelector(),

        const SizedBox(height: 8),

        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 96.0),
            child: Column(
              children: [
                // Bay Header & Cohesion Pill
                _buildBayHeader(),

                const SizedBox(height: 12),

                // Cabin Dimensions / Window Side / Track Side Bar
                _buildCabinLabels(),

                const SizedBox(height: 12),

                // Interactive Coach Seat Grid
                _buildSeatGrid(),

                const SizedBox(height: 14),

                // Map Legend
                _buildMapLegend(),

                const SizedBox(height: 16),

                // Bottom Optimization Floating Card
                _buildOptimizationSheet(),

                const SizedBox(height: 12),

                // Disclaimer
                Text(
                  'Seat swaps are voluntary, peer-to-peer and subject to railway rules.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textLight,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          BouncingScaleButton(
            onTap: widget.onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.cardBorderSubtle, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 15,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.airline_seat_recline_extra_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Coach Seat Map',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.brandLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
                      ),
                      child: Text(
                        'BAY 7',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brandAccent,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    const Icon(Icons.train_outlined, size: 12, color: AppColors.brandAccent),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '12951 Rajdhani · $_selectedCoach',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: _coachInfo.map((info) {
          final coachName = info['name'] as String;
          final isSelected = coachName == _selectedCoach;
          final members = info['members'] as int;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCoach = coachName;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.brandNavy : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.brandNavy : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.brandNavy.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF67E8F9)
                            : (members > 1 ? AppColors.emerald : AppColors.amber),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      coachName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.2)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$members',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : AppColors.textBody,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBayHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppTheme.cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.brandLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  size: 16,
                  color: AppColors.brandAccent,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bay $_selectedBay · Berth 41 to 48',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'AC 3-Tier (3A) Standard Layout',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _isOptimized ? AppColors.emeraldLight : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isOptimized ? AppColors.emeraldBorder : const Color(0xFFBFDBFE),
              ),
            ),
            child: Text(
              _isOptimized ? '100% Cohesion' : '67% Cohesion',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: _isOptimized ? AppColors.emerald : AppColors.brandAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCabinLabels() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Text(
                'WINDOW SIDE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Text(
            'Tap any seat to inspect or swap',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textBody,
            ),
          ),
          Row(
            children: [
              Text(
                'CORRIDOR',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.swap_calls_rounded, size: 13, color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeatGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MAIN CABIN (6 berths: 3 rows x 2 cols)
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'MAIN COMPARTMENT (6 BERTHS)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 12),

                // Row 1: Seat 41 (LB) & Seat 44 (UB)
                Row(
                  children: [
                    Expanded(
                      child: _buildSeatTile(
                        seatNum: 41,
                        berth: 'LB',
                        name: 'Bhavna',
                        status: SeatOccupancyStatus.yourGroup,
                        details: 'Bhavna Sharma · Lower Berth (Your Family)',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSeatTile(
                        seatNum: 44,
                        berth: 'UB',
                        name: _isOptimized ? 'Farhan (Group)' : 'Amit S. (Swap)',
                        status: _isOptimized
                            ? SeatOccupancyStatus.yourGroup
                            : SeatOccupancyStatus.openToSwap,
                        details: _isOptimized
                            ? 'Farhan Sharma · Consolidated'
                            : 'Amit S. · Upper Berth (Open to swap for Coach S4)',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Row 2: Seat 42 (MB) & Seat 45 (MB)
                Row(
                  children: [
                    Expanded(
                      child: _buildSeatTile(
                        seatNum: 42,
                        berth: 'MB',
                        name: 'Chetan',
                        status: SeatOccupancyStatus.yourGroup,
                        details: 'Chetan Sharma · Middle Berth (Your Family)',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSeatTile(
                        seatNum: 45,
                        berth: 'MB',
                        name: 'Occupied',
                        status: SeatOccupancyStatus.occupied,
                        details: 'Passenger X · Travelling with elder parent',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Row 3: Seat 43 (UB) & Seat 46 (UB)
                Row(
                  children: [
                    Expanded(
                      child: _buildSeatTile(
                        seatNum: 43,
                        berth: 'UB',
                        name: _isOptimized ? 'Disha (Group)' : 'Priyanka (Swap)',
                        status: _isOptimized
                            ? SeatOccupancyStatus.yourGroup
                            : SeatOccupancyStatus.openToSwap,
                        details: _isOptimized
                            ? 'Disha Sharma · Consolidated'
                            : 'Priyanka M. · Upper Berth (Open to swap for S3 Side Lower)',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSeatTile(
                        seatNum: 46,
                        berth: 'UB',
                        name: 'Occupied',
                        status: SeatOccupancyStatus.occupied,
                        details: 'Passenger Y · Confirmed Ticket',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // AISLE DIVIDER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: SizedBox(
              height: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_upward_rounded, size: 12, color: Color(0xFFCBD5E1)),
                  const SizedBox(height: 8),
                  RotatedBox(
                    quarterTurns: 1,
                    child: Text(
                      'AISLE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.arrow_downward_rounded, size: 12, color: Color(0xFFCBD5E1)),
                ],
              ),
            ),
          ),

          // SIDE CABIN (2 berths: 47 SL, 48 SU)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'SIDE (2 BERTHS)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 12),

                // Seat 47 (SL)
                _buildSeatTile(
                  seatNum: 47,
                  berth: 'SL',
                  name: _isOptimized ? 'Esha (Group)' : 'Vikram (Swap)',
                  status: _isOptimized
                      ? SeatOccupancyStatus.yourGroup
                      : SeatOccupancyStatus.openToSwap,
                  isSide: true,
                  details: _isOptimized
                      ? 'Esha Sharma · Consolidated'
                      : 'Vikram T. · Side Lower (Willing to swap for Coach S5)',
                ),

                const SizedBox(height: 16),

                // Seat 48 (SU) - Aman (Your Seat)
                _buildSeatTile(
                  seatNum: 48,
                  berth: 'SU',
                  name: _isOptimized ? 'Aman (You)' : 'Rahul (Swap)',
                  status: _isOptimized
                      ? SeatOccupancyStatus.yourGroup
                      : SeatOccupancyStatus.openToSwap,
                  isCurrentUser: _isOptimized,
                  isSide: true,
                  details: _isOptimized
                      ? 'Aman Sharma (You) · Consolidated into Bay 7'
                      : 'Rahul K. · Side Upper (Open to swap for Coach S1)',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatTile({
    required int seatNum,
    required String berth,
    required String name,
    required SeatOccupancyStatus status,
    required String details,
    bool isCurrentUser = false,
    bool isSide = false,
  }) {
    Color bg;
    Color border;
    Color titleColor;
    Color badgeBg;
    Color badgeFg;
    IconData icon;

    final isSelected = _selectedSeatNumber == seatNum;

    switch (status) {
      case SeatOccupancyStatus.yourGroup:
        bg = const Color(0xFFECFDF5);
        border = AppColors.emerald;
        titleColor = const Color(0xFF047857);
        badgeBg = AppColors.emerald;
        badgeFg = Colors.white;
        icon = Icons.check_circle_rounded;
        break;
      case SeatOccupancyStatus.openToSwap:
        bg = Colors.white;
        border = AppColors.brandAccent;
        titleColor = AppColors.brandNavy;
        badgeBg = AppColors.brandLight;
        badgeFg = AppColors.brandAccent;
        icon = Icons.swap_horiz_rounded;
        break;
      case SeatOccupancyStatus.occupied:
        bg = const Color(0xFFF8FAFC);
        border = const Color(0xFFE2E8F0);
        titleColor = const Color(0xFF94A3B8);
        badgeBg = const Color(0xFFF1F5F9);
        badgeFg = const Color(0xFF64748B);
        icon = Icons.lock_outline_rounded;
        break;
    }

    return InkWell(
      onTap: () {
        setState(() => _selectedSeatNumber = seatNum);
        _showSeatDetailsSheet(seatNum, berth, name, status, details);
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: isSide ? 78 : 72,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.brandAccent : border,
            width: isSelected ? 2.2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.brandAccent.withValues(alpha: 0.25)
                  : const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: isSelected ? 10 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$seatNum',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    berth,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: badgeFg,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(icon, size: 12, color: titleColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    isCurrentUser ? 'Aman (You)' : name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSeatDetailsSheet(
    int seatNum,
    String berth,
    String name,
    SeatOccupancyStatus status,
    String details,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.brandLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Center(
                      child: Text(
                        '$seatNum',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brandAccent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seat $seatNum · $berth Berth',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'Coach $_selectedCoach · Bay $_selectedBay',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  details,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textBody,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (status == SeatOccupancyStatus.openToSwap) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.brandNavy,
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            'Gentle swap proposal dispatched to $name!',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Propose Mutual Swap →'),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendDot(AppColors.emerald, 'Your Family (${_isOptimized ? 6 : 2})'),
        const SizedBox(width: 14),
        _buildLegendDot(AppColors.brandAccent, 'Open to Swap (${_isOptimized ? 0 : 4})'),
        const SizedBox(width: 14),
        _buildLegendDot(const Color(0xFF94A3B8), 'Occupied (2)'),
      ],
    );
  }

  Widget _buildLegendDot(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildOptimizationSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _isOptimized ? AppColors.emeraldLight : AppColors.brandLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isOptimized ? AppColors.emeraldBorder : const Color(0xFFBFDBFE),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _isOptimized ? '6/6' : '2/6',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: _isOptimized ? AppColors.emerald : AppColors.brandAccent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isOptimized
                          ? 'Bay 7: 6 of 6 Consolidated!'
                          : 'Bay 7: 2 of 6 in your group',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isOptimized
                          ? 'All 6 members relocated into Coach S2 Bay 7.'
                          : '4 fellow travelers in this bay are willing to trade seats to unite your family.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Primary Button: Select Bay for Optimization
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isOptimized = !_isOptimized;
                });
                widget.onConsolidateSuccess();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.brandNavy,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    content: Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF38BDF8),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _isOptimized
                                ? 'Bay 7 chosen! 4 swaps executed. 6/6 members reunited!'
                                : 'Optimization reset to initial booking.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isOptimized ? AppColors.emerald : AppColors.brandNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isOptimized ? Icons.check_circle_rounded : Icons.auto_awesome_rounded,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isOptimized
                        ? 'Bay 7 Consolidation Active'
                        : '⚡ Auto-Consolidate Group into Bay 7',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
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
}
