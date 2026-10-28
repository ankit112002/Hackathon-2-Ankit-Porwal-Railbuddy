import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/seat_chip.dart';
import '../../logic/seat_utils.dart';
import '../../models/passenger.dart';
import '../../providers/providers.dart';

class SelectPassengerScreen extends ConsumerStatefulWidget {
  const SelectPassengerScreen({super.key});

  @override
  ConsumerState<SelectPassengerScreen> createState() =>
      _SelectPassengerScreenState();
}

class _SelectPassengerScreenState extends ConsumerState<SelectPassengerScreen> {
  String? _selectedPassengerId;

  @override
  void initState() {
    super.initState();
    _selectedPassengerId = ref.read(currentPassengerIdProvider);
  }

  Future<void> _continueAs(Passenger passenger) async {
    final sessionStore = ref.read(sessionStoreProvider);
    await sessionStore.setPassengerId(passenger.id);
    ref.read(currentPassengerIdProvider.notifier).state = passenger.id;
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final passengersAsync = ref.watch(tripPassengersProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        elevation: 0,
        title: const Text(
          'Select Demo Passenger',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: passengersAsync.when(
        data: (passengers) {
          if (passengers.isEmpty) {
            return const Center(
              child: Text('No passengers found. Please seed the database.'),
            );
          }

          // Split into Sharma Family (group) and Others
          final groupPassengers =
              passengers.where((p) => p.groupId != null).toList();
          final otherPassengers =
              passengers.where((p) => p.groupId == null).toList();

          final selectedPassenger = passengers
              .where((p) => p.id == _selectedPassengerId)
              .firstOrNull;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.mintTint,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.mintPressed),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.ink,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Select a passenger profile to simulate multi-user seat swaps and group arrangement.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.ink.withOpacity(0.85),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 1: Sharma Family
                    if (groupPassengers.isNotEmpty) ...[
                      const Text(
                        'Sharma Family (Group Members)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...groupPassengers.map((p) => _buildPassengerTile(p)),
                      const SizedBox(height: 24),
                    ],

                    // Section 2: Other passengers
                    if (otherPassengers.isNotEmpty) ...[
                      const Text(
                        'Other Passengers (Volunteers)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...otherPassengers.map((p) => _buildPassengerTile(p)),
                    ],
                  ],
                ),
              ),

              // Bottom sticky button
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ink.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: PrimaryButton(
                    label: selectedPassenger != null
                        ? 'Continue as ${selectedPassenger.name}'
                        : 'Select a Passenger',
                    onPressed: selectedPassenger != null
                        ? () => _continueAs(selectedPassenger)
                        : null,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(20),
          child: ListLoadingSkeleton(count: 6),
        ),
        error: (err, stack) => ErrorState(
          message: err.toString(),
          onRetry: () {
            ref.invalidate(tripProvider);
            ref.invalidate(tripPassengersProvider);
          },
        ),
      ),
    );
  }

  Widget _buildPassengerTile(Passenger p) {
    final isSelected = p.id == _selectedPassengerId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _selectedPassengerId = p.id);
          },
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.white : AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.ink : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.ink.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Avatar Circle
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isSelected ? AppColors.mint : AppColors.fieldGrey,
                  child: Text(
                    p.name.isNotEmpty ? p.name[0] : '?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name & Berth
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (p.groupId != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6B4EE6).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Group',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6B4EE6),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${berthOf(p.seatNo)} Berth · ${p.willingToSwap ? "Open to swap" : "Not swapping"}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Seat Chip
                SeatChip(coach: p.coach, seatNo: p.seatNo),
                const SizedBox(width: 12),

                // Radio Indicator
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? AppColors.ink : AppColors.border,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
