import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/dark_button.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/score_ring.dart';
import '../../core/widgets/seat_chip.dart';
import '../../core/widgets/seat_tile.dart';
import '../../core/widgets/status_chip.dart';
import '../../core/widgets/stepper_bar.dart';
import '../../core/widgets/ticket_card.dart';
import '../../models/swap_request.dart';

class WidgetGalleryScreen extends StatefulWidget {
  const WidgetGalleryScreen({super.key});

  @override
  State<WidgetGalleryScreen> createState() => _WidgetGalleryScreenState();
}

class _WidgetGalleryScreenState extends State<WidgetGalleryScreen> {
  int _score = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Widget Gallery'),
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Primary & Dark Buttons',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          PrimaryButton(label: 'Primary Button', onPressed: () {}),
          const SizedBox(height: 8),
          const PrimaryButton(label: 'Loading Button', isLoading: true),
          const SizedBox(height: 8),
          DarkButton(label: 'Dark Button', onPressed: () {}),
          const SizedBox(height: 24),

          const Text('Chips & Badges',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppChip(label: 'Selected Chip', isSelected: true),
              AppChip(label: 'Unselected Chip', isSelected: false),
              SeatChip(coach: 'S2', seatNo: 43),
              SeatChip(coach: 'S1', seatNo: 23, isDark: true),
              StatusChip(status: SwapRequestStatus.pending),
              StatusChip(status: SwapRequestStatus.accepted),
              StatusChip(status: SwapRequestStatus.rejected),
            ],
          ),
          const SizedBox(height: 24),

          const Text('Seat Tiles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SeatTile(seatNo: 23, state: SeatTileState.yours),
              SeatTile(seatNo: 41, state: SeatTileState.groupMember),
              SeatTile(seatNo: 43, state: SeatTileState.openToSwap),
              SeatTile(seatNo: 47, state: SeatTileState.other),
              SeatTile(seatNo: 56, state: SeatTileState.selected),
            ],
          ),
          const SizedBox(height: 24),

          const Text('Score Ring & Stepper',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Center(
            child: ScoreRing(score: _score),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () => setState(() => _score = 20),
                  child: const Text('Score 20')),
              TextButton(
                  onPressed: () => setState(() => _score = 80),
                  child: const Text('Score 80')),
              TextButton(
                  onPressed: () => setState(() => _score = 100),
                  child: const Text('Score 100')),
            ],
          ),
          const SizedBox(height: 12),
          const StepperBar(currentStep: 1),
          const SizedBox(height: 24),

          const Text('Ticket Card',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const TicketCard(
            top: Text('Ticket Card Top Content',
                style: TextStyle(color: Colors.white)),
            bottom: Text('Ticket Card Bottom Content'),
          ),
          const SizedBox(height: 24),

          const Text('Loading Skeleton',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const ListLoadingSkeleton(count: 2),
        ],
      ),
    );
  }
}
