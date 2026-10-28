import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/seat_chip.dart';
import '../../core/widgets/seat_tile.dart';
import '../../logic/score.dart';
import '../../logic/seat_utils.dart';
import '../../models/passenger.dart';
import '../../providers/providers.dart';

class CoachSeatMapScreen extends ConsumerStatefulWidget {
  const CoachSeatMapScreen({super.key});

  @override
  ConsumerState<CoachSeatMapScreen> createState() => _CoachSeatMapScreenState();
}

class _CoachSeatMapScreenState extends ConsumerState<CoachSeatMapScreen> {
  final List<String> _coaches = ['S1', 'S2', 'S3', 'S4', 'S5'];
  String _selectedCoach = 'S2';
  int _selectedBayIndex = 5; // Default bay index 5 (Bay 6, seats 41 to 48)

  @override
  void initState() {
    super.initState();
    // Default to the bay with most group members if available
    final myGroup = ref.read(myGroupProvider);
    final mainBay = getMainBay(myGroup);
    if (mainBay != null) {
      _selectedCoach = mainBay.$1;
      _selectedBayIndex = mainBay.$2;
    }
  }

  void _showSeatDetailsPopup(int seatNo, Passenger? occupant) {
    final berth = berthOf(seatNo);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SeatChip(coach: _selectedCoach, seatNo: seatNo),
                    const SizedBox(width: 12),
                    Text(
                      '$berth Berth',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                if (occupant != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: occupant.willingToSwap
                          ? AppColors.mint.withOpacity(0.2)
                          : AppColors.fieldGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      occupant.willingToSwap ? 'Open to swap' : 'Not open',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: occupant.willingToSwap
                            ? const Color(0xFF0D6B49)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Coach $_selectedCoach · Bay ${_selectedBayIndex + 1} (Seats ${bayStartSeat(seatNo)}-${bayEndSeat(seatNo)})',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            if (occupant != null && occupant.willingToSwap)
              const Text(
                'This passenger is open to seat swap. You can request a swap from the Individual Swap screen or Group Optimizer.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.ink,
                  height: 1.4,
                ),
              )
            else
              const Text(
                'This seat is currently not marked open for swaps.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentPassengerProvider);
    final myGroup = ref.watch(myGroupProvider);
    final allPassengers = ref.watch(tripPassengersProvider).valueOrNull ?? [];

    final bayStart = _selectedBayIndex * 8 + 1;
    final bayEnd = bayStart + 7;

    final bayOccupants = <int, Passenger>{};
    for (final p in allPassengers) {
      if (p.coach == _selectedCoach &&
          p.seatNo >= bayStart &&
          p.seatNo <= bayEnd) {
        bayOccupants[p.seatNo] = p;
      }
    }

    SeatTileState getSeatState(int seatNo) {
      if (me != null && me.coach == _selectedCoach && me.seatNo == seatNo) {
        return SeatTileState.yours;
      }
      final occupant = bayOccupants[seatNo];
      if (occupant != null) {
        if (myGroup.any((g) => g.id == occupant.id)) {
          return SeatTileState.groupMember;
        }
        if (occupant.willingToSwap) {
          return SeatTileState.openToSwap;
        }
      }
      return SeatTileState.other;
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text(
          'Coach Seat Map',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coach Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _coaches.map((c) {
                  final isSelected = c == _selectedCoach;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AppChip(
                      label: 'Coach $c',
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedCoach = c),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Bay Selector Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bay ${_selectedBayIndex + 1} of 9 (Seats $bayStart - $bayEnd)',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: _selectedBayIndex > 0
                          ? () => setState(() => _selectedBayIndex--)
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: _selectedBayIndex < 8
                          ? () => setState(() => _selectedBayIndex++)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Bay Visual Layout Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Main Compartment (6 berths): 3 on left, aisle, 3 on right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left Berth Column (LB, MB, UB)
                      Column(
                        children: [
                          SeatTile(
                            seatNo: bayStart,
                            state: getSeatState(bayStart),
                            onTap: () => _showSeatDetailsPopup(
                              bayStart,
                              bayOccupants[bayStart],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SeatTile(
                            seatNo: bayStart + 1,
                            state: getSeatState(bayStart + 1),
                            onTap: () => _showSeatDetailsPopup(
                              bayStart + 1,
                              bayOccupants[bayStart + 1],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SeatTile(
                            seatNo: bayStart + 2,
                            state: getSeatState(bayStart + 2),
                            onTap: () => _showSeatDetailsPopup(
                              bayStart + 2,
                              bayOccupants[bayStart + 2],
                            ),
                          ),
                        ],
                      ),

                      // Middle Aisle Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 24),
                        decoration: BoxDecoration(
                          color: AppColors.fieldGrey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            'BAY AISLE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),

                      // Right Berth Column (LB, MB, UB)
                      Column(
                        children: [
                          SeatTile(
                            seatNo: bayStart + 3,
                            state: getSeatState(bayStart + 3),
                            onTap: () => _showSeatDetailsPopup(
                              bayStart + 3,
                              bayOccupants[bayStart + 3],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SeatTile(
                            seatNo: bayStart + 4,
                            state: getSeatState(bayStart + 4),
                            onTap: () => _showSeatDetailsPopup(
                              bayStart + 4,
                              bayOccupants[bayStart + 4],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SeatTile(
                            seatNo: bayStart + 5,
                            state: getSeatState(bayStart + 5),
                            onTap: () => _showSeatDetailsPopup(
                              bayStart + 5,
                              bayOccupants[bayStart + 5],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Corridor Divider
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'CORRIDOR',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),
                  ),

                  // Side Berths Row (SL, SU)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SeatTile(
                        seatNo: bayStart + 6,
                        state: getSeatState(bayStart + 6),
                        onTap: () => _showSeatDetailsPopup(
                          bayStart + 6,
                          bayOccupants[bayStart + 6],
                        ),
                      ),
                      const SizedBox(width: 24),
                      SeatTile(
                        seatNo: bayStart + 7,
                        state: getSeatState(bayStart + 7),
                        onTap: () => _showSeatDetailsPopup(
                          bayStart + 7,
                          bayOccupants[bayStart + 7],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Map Legend
            const Text(
              'Legend',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildLegendItem(AppColors.mint, 'Your Seat'),
                  const SizedBox(height: 8),
                  _buildLegendItem(
                    const Color(0xFF6B4EE6),
                    'Group Member (Family / Friends)',
                  ),
                  const SizedBox(height: 8),
                  _buildLegendItem(
                    const Color(0xFF2FE3A5),
                    'Open to Swap (Volunteer)',
                    isTint: true,
                  ),
                  const SizedBox(height: 8),
                  _buildLegendItem(
                    AppColors.border,
                    'Other Passenger (Unavailable)',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool isTint = false}) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: isTint ? const Color(0xFFD8F2E6) : color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isTint ? AppColors.mintPressed : color,
              width: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}
