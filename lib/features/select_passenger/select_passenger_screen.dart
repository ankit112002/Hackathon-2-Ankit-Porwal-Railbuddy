import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/seat_chip.dart';
import '../../core/widgets/station_backdrop.dart';
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

  static const _tabs = {'/home', '/group', '/requests', '/profile'};

  String? _returnTab() {
    final from = GoRouterState.of(context).uri.queryParameters['from'];
    if (from != null && _tabs.contains(from)) return from;
    return null;
  }

  String _fallbackLocation() {
    final tab = _returnTab();
    if (tab != null) return tab;
    final passengerId = ref.read(sessionStoreProvider).getPassengerId();
    if (passengerId != null && passengerId.isNotEmpty) return '/home';
    return '/onboarding';
  }

  Future<void> _continueAs(Passenger passenger) async {
    final sessionStore = ref.read(sessionStoreProvider);
    await sessionStore.setPassengerId(passenger.id);
    ref.read(currentPassengerIdProvider.notifier).state = passenger.id;
    if (!mounted) return;
    final tab = _returnTab();
    if (tab != null) {
      if (GoRouter.of(context).canPop()) {
        context.pop();
        return;
      }
      context.go(tab);
      return;
    }
    context.go('/home');
  }

  void _leave() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }
    context.go(_fallbackLocation());
  }

  @override
  Widget build(BuildContext context) {
    final passengersAsync = ref.watch(tripPassengersProvider);
    final canPop = GoRouter.of(context).canPop();

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.go(_fallbackLocation());
      },
      child: Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          _StationHeader(
            title: 'Who is travelling?',
            subtitle: 'Pick a profile and bring your group together.',
            onBack: _leave,
          ),
          Expanded(
            child: passengersAsync.when(
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
          ),
        ],
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

class _StationHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _StationHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 188,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppImages.station,
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.25),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x660F1115),
                  Color(0xE60F1115),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Material(
                        color: AppColors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: onBack,
                          borderRadius: BorderRadius.circular(12),
                          child: const SizedBox(
                            width: 36,
                            height: 36,
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.train_rounded,
                        color: AppColors.mint,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'RailBuddy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                      letterSpacing: -0.4,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white.withOpacity(0.78),
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
