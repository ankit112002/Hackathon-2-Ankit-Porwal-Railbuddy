import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final bool isOptimized;
  final VoidCallback onNavigateToGroup;
  final VoidCallback onNavigateToSeatMap;
  final VoidCallback onNavigateToRequests;
  final VoidCallback onNavigateToProfile;
  final VoidCallback? onToggleOptimize;

  const HomeScreen({
    super.key,
    this.isOptimized = false,
    required this.onNavigateToGroup,
    required this.onNavigateToSeatMap,
    required this.onNavigateToRequests,
    required this.onNavigateToProfile,
    this.onToggleOptimize,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String _selectedTripType = 'Group'; // 'Group', 'One way', 'Multi-city'
  String _originName = 'Indore Jn';
  String _originCity = 'Madhya Pradesh';
  String _destName = 'Mumbai';
  String _destCity = 'Maharashtra';

  bool _seatSwapOpen = true;
  late AnimationController _swapAnimController;

  @override
  void initState() {
    super.initState();
    _swapAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _swapAnimController.dispose();
    super.dispose();
  }

  void _swapStations() {
    _swapAnimController.forward(from: 0.0);
    setState(() {
      final tempName = _originName;
      final tempCity = _originCity;

      _originName = _destName;
      _originCity = _destCity;

      _destName = tempName;
      _destCity = tempCity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Dark Context Hero Container with Train Illustration Background (from user photo)
          _buildDarkHeroWithTrainBackground(),

          // 2. Overlapping Booking Card (from user middle photo)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Transform.translate(
              offset: const Offset(0, -26),
              child: Column(
                children: [
                  _buildIndoreMumbaiBookingCard(),
                  const SizedBox(height: 14),
                  _buildGroupSeatOptimizerCard(),
                  const SizedBox(height: 18),
                  _buildQuickActionShortcuts(),
                  const SizedBox(height: 22),
                  _buildRecentGroupRoutes(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Dark Context Hero Container with Train Illustration (from user middle image)
  Widget _buildDarkHeroWithTrainBackground() {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.darkCharcoal,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          // Train on Tracks Illustration in the Top-Right Corner
          Positioned(
            right: 0,
            top: topInset + 30,
            child: Opacity(
              opacity: 0.85,
              child: Image.asset(
                'assets/images/train_header_clean.png',
                width: 155,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),

          // Content Layer
          Padding(
            padding: EdgeInsets.fromLTRB(20, topInset + 12, 20, 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Brand & Quick Actions Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
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
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppColors.mintAccent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.train_rounded,
                              color: Color(0xFF0F1115),
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'RailBuddy',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Actions: Notifications & Profile
                    Row(
                      children: [
                        GestureDetector(
                          onTap: widget.onNavigateToRequests,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: widget.onNavigateToProfile,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: AppColors.mintAccent,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'AS',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F1115),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Welcome Back Greeting (Exact text from user photo)
                Text(
                  'Welcome back!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),

                // User Name
                Text(
                  'Hi, Aman',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 3),

                // Subtitle
                Text(
                  'Bring your group together',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFBACAC0),
                  ),
                ),

                const SizedBox(height: 22),

                // Floating Trip Selector Pills (Group / One way / Multi-city)
                Row(
                  children: [
                    _buildPillButton(
                      label: 'Group',
                      icon: Icons.groups_rounded,
                      type: 'Group',
                    ),
                    const SizedBox(width: 8),
                    _buildPillButton(
                      label: 'One way',
                      icon: Icons.add_rounded,
                      type: 'One way',
                    ),
                    const SizedBox(width: 8),
                    _buildPillButton(
                      label: 'Multi-city',
                      icon: Icons.percent_rounded,
                      type: 'Multi-city',
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

  Widget _buildPillButton({
    required String label,
    required IconData icon,
    required String type,
  }) {
    final isSelected = _selectedTripType == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedTripType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.mintAccent
              : Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected
                ? AppColors.mintAccent
                : Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
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
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? AppColors.darkCharcoal
                  : Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.darkCharcoal : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Booking Card (Indore Jn ➔ Mumbai with Travellers & Seat swap open switch)
  Widget _buildIndoreMumbaiBookingCard() {
    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FROM Station
          Text(
            'FROM',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  _originName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _swapStations,
                child: RotationTransition(
                  turns: _swapAnimController,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.mintSurfaceLow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorderSubtle),
                    ),
                    child: const Icon(
                      Icons.unfold_more_rounded,
                      color: AppColors.textDark,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: AppColors.cardBorderSubtle, height: 1),
          ),

          // TO Station
          Text(
            'TO',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _destName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),

          const SizedBox(height: 14),

          // TRAVELLERS Field (from user photo)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.mintSurfaceLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRAVELLERS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline_rounded,
                      size: 16,
                      color: AppColors.forestMint,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '6 Members (Sharma Family)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // COACH Field (from user photo)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.mintSurfaceLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COACH',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.isOptimized
                          ? 'Coach S2 · Bay 7 (All Contiguous)'
                          : 'S1 to S5 (5 scattered coaches)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: widget.isOptimized
                            ? AppColors.forestMint
                            : AppColors.rose,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isOptimized
                            ? AppColors.mintAccent
                            : AppColors.roseLight,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        widget.isOptimized ? '100% Sync' : 'Needs Swap',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: widget.isOptimized
                              ? AppColors.darkCharcoal
                              : AppColors.rose,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Seat Swap Open Toggle Switch (from user photo)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Seat swap open',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: AppColors.textLight,
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _seatSwapOpen = !_seatSwapOpen),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 46,
                  height: 26,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    color: _seatSwapOpen
                        ? AppColors.mintAccent
                        : AppColors.mintSurfaceHighest,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    alignment: _seatSwapOpen
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
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
          ),

          const SizedBox(height: 18),

          // Primary Button: "Bring group together →" (from user middle photo)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (widget.onToggleOptimize != null) {
                  widget.onToggleOptimize!();
                } else {
                  widget.onNavigateToGroup();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mintAccent,
                foregroundColor: AppColors.darkCharcoal,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.isOptimized
                        ? 'View Seating Plan'
                        : 'Bring group together',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.darkCharcoal,
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Group Seat Optimizer Scatter Visualization (Core Stitch Feature)
  Widget _buildGroupSeatOptimizerCard() {
    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.mintAccent.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.forestMint,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Group Seat Optimizer',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        widget.isOptimized
                            ? 'All 6 consolidated in Bay 7'
                            : 'Scattered across coaches S1–S5',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: widget.isOptimized
                              ? AppColors.forestMint
                              : AppColors.rose,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.isOptimized
                      ? AppColors.mintAccent
                      : AppColors.roseLight,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  widget.isOptimized ? '100% Match' : '20% Cohesion',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: widget.isOptimized
                        ? AppColors.darkCharcoal
                        : AppColors.rose,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Scatter Visualizer Badges (C1, C2, C3, C4, C5)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.mintSurfaceLow,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.mintSurfaceHigh),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.isOptimized
                          ? 'OPTIMIZED COACH S2 (BAY 7)'
                          : 'LIVE SCATTER MAP',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: AppColors.textLight,
                      ),
                    ),
                    Text(
                      widget.isOptimized
                          ? '6 seats contiguous'
                          : '5 isolated segments',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Live Coach Boxes
                widget.isOptimized
                    ? _buildOptimizedCoachBox()
                    : _buildScatteredCoachBoxes(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScatteredCoachBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCoachBadge('S1', AppColors.amber),
        _buildCoachBadge('S2', AppColors.forestMint),
        _buildCoachBadge('S3', AppColors.rose),
        _buildCoachBadge('S4', AppColors.rose),
        _buildCoachBadge('S5', AppColors.rose),
      ],
    );
  }

  Widget _buildOptimizedCoachBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.mintAccent, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.mintAccent,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'S2',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coach S2 · Bay 7 (Seats 41 to 48)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'Aman, Bhavna, Chetan, Disha, Esha, Farhan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Icon(
            Icons.verified_rounded,
            color: AppColors.forestMint,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildCoachBadge(String coach, Color badgeColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: badgeColor.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              coach,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: badgeColor,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Quick Action Shortcuts
  Widget _buildQuickActionShortcuts() {
    return Row(
      children: [
        _buildActionTile(
          icon: Icons.airline_seat_recline_extra_rounded,
          title: 'Seat Map',
          subtitle: 'Interactive S2',
          onTap: widget.onNavigateToSeatMap,
        ),
        const SizedBox(width: 10),
        _buildActionTile(
          icon: Icons.swap_horizontal_circle_rounded,
          title: 'Swaps',
          subtitle: '6 Nearby',
          onTap: widget.onNavigateToRequests,
        ),
        const SizedBox(width: 10),
        _buildActionTile(
          icon: Icons.groups_rounded,
          title: 'My Group',
          subtitle: '6 Travelers',
          onTap: widget.onNavigateToGroup,
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: AppTheme.cardDecoration(),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.mintSurfaceLow,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.forestMint, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 5. Recent Group Circuits
  Widget _buildRecentGroupRoutes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'POPULAR GROUP CIRCUITS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textDark,
              ),
            ),
            Text(
              'Direct Express',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.forestMint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRouteCard(
          trainName: '12962 · Avantika SF Express',
          origin: 'Indore Jn (INDB)',
          dest: 'Mumbai Central (MMCT)',
          time: '17:40 ➔ 06:10 (12h 30m)',
          passengersAvg: '6.0 pax avg',
        ),
        const SizedBox(height: 10),
        _buildRouteCard(
          trainName: '12015 · Ajmer Shatabdi',
          origin: 'New Delhi (NDLS)',
          dest: 'Jaipur Junction (JP)',
          time: '06:10 ➔ 10:40 (4h 30m)',
          passengersAvg: '4.8 pax avg',
        ),
      ],
    );
  }

  Widget _buildRouteCard({
    required String trainName,
    required String origin,
    required String dest,
    required String time,
    required String passengersAvg,
  }) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.darkCharcoal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.train_rounded,
              color: AppColors.mintAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      trainName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forestMint,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mintSurfaceLow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        passengersAvg,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$origin ➔ $dest',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  time,
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
}
