import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/passenger.dart';
import '../theme/app_theme.dart';
import '../widgets/circular_cohesion_gauge.dart';
import '../widgets/perforated_ticket_card.dart';

class GroupSeatingScreen extends StatefulWidget {
  final List<Passenger> passengers;
  final double cohesionScore;
  final bool isOptimized;
  final VoidCallback onOptimizeGroup;
  final Function(Passenger) onSwapPassenger;
  final VoidCallback onOpenSeatMap;

  const GroupSeatingScreen({
    super.key,
    required this.passengers,
    required this.cohesionScore,
    required this.isOptimized,
    required this.onOptimizeGroup,
    required this.onSwapPassenger,
    required this.onOpenSeatMap,
  });

  @override
  State<GroupSeatingScreen> createState() => _GroupSeatingScreenState();
}

class _GroupSeatingScreenState extends State<GroupSeatingScreen> {
  String _activeFilter = 'all'; // 'all', 'isolated', 'together'
  int _viewTab = 0; // 0: Roster, 1: Boarding Pass

  @override
  void didUpdateWidget(covariant GroupSeatingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOptimized && !oldWidget.isOptimized) {
      _viewTab = 1; // Switch to boarding ticket pass upon optimization
    }
  }

  List<Passenger> get _filteredPassengers {
    if (_activeFilter == 'isolated') {
      return widget.passengers
          .where((p) => p.cohesionLevel == CohesionLevel.otherCoach)
          .toList();
    } else if (_activeFilter == 'together') {
      return widget.passengers
          .where((p) => p.cohesionLevel != CohesionLevel.otherCoach)
          .toList();
    }
    return widget.passengers;
  }

  @override
  Widget build(BuildContext context) {
    final isTicketView = _viewTab == 1;

    return Container(
      color: isTicketView ? AppColors.mintAccent : Colors.transparent,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(18, 6, 18, isTicketView ? 80 : 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // View Switcher (Roster vs Boarding Pass Ticket)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isTicketView
                    ? const Color(0xFF141D1B).withValues(alpha: 0.08)
                    : AppColors.mintSurfaceLow,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: isTicketView
                      ? const Color(0xFF141D1B).withValues(alpha: 0.15)
                      : AppColors.mintSurfaceHigh,
                ),
              ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _viewTab = 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _viewTab == 0 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: _viewTab == 0
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF141D1B).withValues(alpha: 0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.groups_rounded,
                            size: 16,
                            color: _viewTab == 0
                                ? AppColors.forestMint
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Passenger Roster (6)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: _viewTab == 0
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: _viewTab == 0
                                  ? AppColors.textDark
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _viewTab = 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _viewTab == 1 ? AppColors.mintAccent : Colors.transparent,
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: _viewTab == 1
                            ? [
                                BoxShadow(
                                  color: AppColors.mintAccent.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.confirmation_number_rounded,
                            size: 15,
                            color: _viewTab == 1
                                ? AppColors.darkCharcoal
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Boarding Pass',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: _viewTab == 1
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: _viewTab == 1
                                  ? AppColors.darkCharcoal
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (_viewTab == 1) ...[
            // Stitch Perforated Boarding Pass Ticket View (Screen 14)
            StitchPerforatedTicketCard(
              onOpenSeatMap: widget.onOpenSeatMap,
            ),
          ] else ...[
            // Family Overview Card
            _buildFamilyHeaderCard(),

            const SizedBox(height: 16),

            // Cohesion Score & Analysis Card
            _buildScoreAnalysisCard(),

            const SizedBox(height: 18),

            // AI Convergence Recommendation Banner
            _buildConvergenceBanner(),

            const SizedBox(height: 22),

            // Filter Segmented Chips & Count
            _buildFilterChips(),

            const SizedBox(height: 14),

            // Passenger Cards List
            ..._filteredPassengers.map((p) => _buildPassengerCard(p)),

            const SizedBox(height: 18),

            // Step-by-Step AI Swap Roadmap
            _buildConsolidationRoadmap(),

            const SizedBox(height: 22),

            // Primary Auto-Optimize CTA
            _buildOptimizeActionButton(),

            const SizedBox(height: 12),

            // Secondary: View on Seat Map
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onOpenSeatMap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.airline_seat_recline_extra_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Explore Coach S2 Interactive Bay Map',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Railway Disclaimer
            Center(
              child: Text(
                'Peer seat swaps are mutually agreed upon and voluntary.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textLight,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

  // Family Header Card
  Widget _buildFamilyHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.darkCharcoal,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(
                Icons.groups_rounded,
                color: AppColors.mintAccent,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sharma Family Party',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '12951 Mumbai Rajdhani · PNR 8472910482',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.mintSurfaceLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.mintSurfaceHigh, width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_rounded,
                  size: 13,
                  color: AppColors.forestMint,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.passengers.length} Travelers',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forestMint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Cohesion Score & Analysis Card
  Widget _buildScoreAnalysisCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          // Top pill: Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: widget.isOptimized ? AppColors.emeraldLight : AppColors.roseLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isOptimized ? AppColors.emeraldBorder : AppColors.roseBorder,
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.isOptimized ? AppColors.emerald : AppColors.rose,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  widget.isOptimized
                      ? 'Consolidated in Coach S2 (Bay 7)'
                      : 'High Dispersion · 5 Coaches Apart',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: widget.isOptimized ? AppColors.emerald : AppColors.rose,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Circular Cohesion Gauge
          CircularCohesionGauge(
            score: widget.cohesionScore,
            size: 120,
            strokeWidth: 10,
            showLabel: true,
          ),

          const SizedBox(height: 16),

          Text(
            widget.isOptimized ? 'Group Cohesion Reached 88%' : 'Group Travel Health: 20%',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            widget.isOptimized
                ? 'All 6 travelers consolidated into Coach S2 adjacent berths in Bay 7!'
                : 'Your family is currently booked in coaches S1, S2, S3, S4, and S5.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // Dispersion Span Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.isOptimized ? Icons.check_circle_rounded : Icons.sync_problem_rounded,
                  size: 16,
                  color: widget.isOptimized ? AppColors.emerald : AppColors.rose,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.isOptimized
                      ? 'Dispersion: 0 Bogies Apart (Same Bay)'
                      : 'Dispersion: 4 Bogies Apart (S1 to S5)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // AI Convergence Recommendation Banner
  Widget _buildConvergenceBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: AppColors.brandAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Optimal Bay Convergence',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Coach S2 Bay 7 has 4 fellow travelers open to adjacent trades. You can reunite all 6 members with 4 gentle swaps.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.brandPrimary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Filter Segmented Chips
  Widget _buildFilterChips() {
    final isolatedCount =
        widget.passengers.where((p) => p.cohesionLevel == CohesionLevel.otherCoach).length;
    final togetherCount = widget.passengers.length - isolatedCount;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip('all', 'All (${widget.passengers.length})'),
          const SizedBox(width: 8),
          _buildFilterChip(
            'isolated',
            '⚠️ Scattered ($isolatedCount)',
            activeColor: AppColors.rose,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'together',
            '✅ Together ($togetherCount)',
            activeColor: AppColors.emerald,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, {Color? activeColor}) {
    final isSelected = _activeFilter == key;
    final color = activeColor ?? AppColors.brandNavy;

    return InkWell(
      onTap: () => setState(() => _activeFilter = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textBody,
          ),
        ),
      ),
    );
  }

  // Redesigned Passenger Seat Card
  Widget _buildPassengerCard(Passenger p) {
    Color statusColor;
    String statusTitle;
    IconData statusIcon;

    switch (p.cohesionLevel) {
      case CohesionLevel.sameBay:
        statusColor = AppColors.emerald;
        statusTitle = 'Together (Bay 7)';
        statusIcon = Icons.check_circle_rounded;
        break;
      case CohesionLevel.sameCoach:
        statusColor = AppColors.amber;
        statusTitle = 'Same Coach';
        statusIcon = Icons.info_rounded;
        break;
      case CohesionLevel.otherCoach:
        statusColor = AppColors.rose;
        statusTitle = 'Isolated';
        statusIcon = Icons.warning_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Indicator bar
          Container(
            width: 4,
            height: 42,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar Circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: p.isCurrentUser
                    ? [const Color(0xFF2563EB), const Color(0xFF1D4ED8)]
                    : [const Color(0xFF334155), const Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                p.avatarLetter,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Passenger Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        p.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (p.isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          'You',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brandAccent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  p.bay != null ? '${p.berthType} · ${p.bay}' : p.berthType,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Seat badge and Swap Action Button
          InkWell(
            onTap: () => widget.onSwapPassenger(p),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        p.seatTag,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 9, color: statusColor),
                          const SizedBox(width: 3),
                          Text(
                            p.statusNote ?? statusTitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.brandLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.swap_horiz_rounded,
                      size: 16,
                      color: AppColors.brandAccent,
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

  // Step-by-Step AI Swap Roadmap
  Widget _buildConsolidationRoadmap() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI CONSOLIDATION PLAN (BAY 7)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.textLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '4 Trades Found',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.emerald,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTradeRow('1', 'Aman (S1 · 23 MB)', '⇄', 'Rahul K. (S2 · 48 SUB)'),
          const SizedBox(height: 8),
          _buildTradeRow('2', 'Disha (S3 · 56 SL)', '⇄', 'Priyanka M. (S2 · 43 UB)'),
          const SizedBox(height: 8),
          _buildTradeRow('3', 'Esha (S4 · 21 UB)', '⇄', 'Amit S. (S2 · 44 UB)'),
          const SizedBox(height: 8),
          _buildTradeRow('4', 'Farhan (S5 · 37 SU)', '⇄', 'Vikram T. (S2 · 47 SL)'),
        ],
      ),
    );
  }

  Widget _buildTradeRow(String step, String from, String symbol, String to) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              from,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              symbol,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.brandAccent,
              ),
            ),
          ),
          Expanded(
            child: Text(
              to,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.brandAccent,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Primary Auto-Optimize CTA
  Widget _buildOptimizeActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (widget.isOptimized ? AppColors.emerald : AppColors.brandAccent)
                .withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: widget.onOptimizeGroup,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isOptimized ? AppColors.emerald : AppColors.brandNavy,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.isOptimized
                    ? Icons.restart_alt_rounded
                    : Icons.auto_awesome_rounded,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.isOptimized
                    ? 'Revert to Original Seating'
                    : '⚡ Bring My Group Together (1-Tap)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
