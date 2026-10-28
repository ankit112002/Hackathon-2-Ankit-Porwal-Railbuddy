import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/seat_chip.dart';
import '../../logic/seat_utils.dart';
import '../../providers/providers.dart';

class TripDetailsScreen extends ConsumerStatefulWidget {
  const TripDetailsScreen({super.key});

  @override
  ConsumerState<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends ConsumerState<TripDetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _seatController;
  String _selectedCoach = 'S1';
  bool _willingToSwap = true;
  bool _isSaving = false;

  final List<String> _coaches = ['S1', 'S2', 'S3', 'S4', 'S5'];

  @override
  void initState() {
    super.initState();
    final current = ref.read(currentPassengerProvider);
    _nameController = TextEditingController(text: current?.name ?? '');
    _seatController =
        TextEditingController(text: current != null ? '${current.seatNo}' : '1');
    _selectedCoach = current?.coach ?? 'S1';
    _willingToSwap = current?.willingToSwap ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _seatController.dispose();
    super.dispose();
  }

  int get _currentSeatNo {
    final parsed = int.tryParse(_seatController.text);
    if (parsed == null || parsed < 1) return 1;
    if (parsed > 72) return 72;
    return parsed;
  }

  Future<void> _saveChanges() async {
    final current = ref.read(currentPassengerProvider);
    if (current == null) return;

    setState(() => _isSaving = true);
    try {
      final seatNo = _currentSeatNo;
      await ref.read(passengerRepoProvider).updateSeat(
            current.id,
            coach: _selectedCoach,
            seatNo: seatNo,
            name: _nameController.text.trim(),
          );
      await ref
          .read(passengerRepoProvider)
          .updateWillingToSwap(current.id, _willingToSwap);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reservation details updated!'),
            backgroundColor: AppColors.accepted,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.rejected,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _resetToDemo() {
    setState(() {
      _selectedCoach = 'S1';
      _seatController.text = '23';
      _nameController.text = 'Aman';
      _willingToSwap = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final seatNo = _currentSeatNo;
    final derivedBerth = berthOf(seatNo);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text(
          'Edit Reservation',
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
        actions: [
          TextButton(
            onPressed: _resetToDemo,
            child: const Text(
              'Reset Demo',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.mintPressed,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            const Text(
              'Passenger Name',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 20),

            // Coach Selector
            const Text(
              'Coach',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: _coaches.map((c) {
                final isSelected = c == _selectedCoach;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => setState(() => _selectedCoach = c),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.ink : AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.ink : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            c,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? AppColors.white : AppColors.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Seat Number Field
            const Text(
              'Seat Number (1 - 72)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _seatController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'e.g. 23',
                prefixIcon: Icon(Icons.event_seat_rounded),
              ),
            ),
            const SizedBox(height: 16),

            // Derived Berth Type Card (Read Only)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  SeatChip(coach: _selectedCoach, seatNo: seatNo),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Derived Berth: $derivedBerth',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        'Bay ${(seatNo - 1) ~/ 8 + 1} (Seats ${((seatNo - 1) ~/ 8) * 8 + 1}-${((seatNo - 1) ~/ 8) * 8 + 8})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Willing to swap switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Open to seat swaps',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          'Allow others to discover your seat',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _willingToSwap,
                    activeColor: AppColors.mintPressed,
                    onChanged: (val) => setState(() => _willingToSwap = val),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: AppColors.cream,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: PrimaryButton(
            label: 'Save Reservation',
            isLoading: _isSaving,
            onPressed: _saveChanges,
          ),
        ),
      ),
    );
  }
}
