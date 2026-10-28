import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/seat_chip.dart';
import '../../providers/providers.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'My Family');
  final Set<String> _selectedMemberIds = {};
  bool _isCreating = false;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    final me = ref.read(currentPassengerProvider);
    if (me != null) {
      _selectedMemberIds.add(me.id);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    final me = ref.read(currentPassengerProvider);
    final trip = ref.read(tripProvider).valueOrNull;
    if (me == null || trip == null) return;

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    setState(() => _isCreating = true);
    try {
      final group = await ref.read(groupRepoProvider).createGroup(
            tripId: trip.id,
            name: _nameController.text.trim(),
          );

      // Assign all selected members to this group
      for (final pId in _selectedMemberIds) {
        await ref.read(passengerRepoProvider).assignToGroup(pId, group.id);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Group "${group.name}" created! Code: ${group.joinCode}'),
          backgroundColor: AppColors.accepted,
        ),
      );
      context.go('/group');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create group: ${e.toString()}'),
          backgroundColor: AppColors.rejected,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentPassengerProvider);
    final allPassengers = ref.watch(tripPassengersProvider).valueOrNull ?? [];

    final filteredPassengers = allPassengers.where((p) {
      if (_searchQuery == null || _searchQuery!.trim().isEmpty) return true;
      return p.name.toLowerCase().contains(_searchQuery!.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text(
          'Create Travel Group',
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
            // Group Name Field
            const Text(
              'Group Name',
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
                hintText: 'e.g. Sharma Family',
                prefixIcon: Icon(Icons.group_outlined),
                fillColor: AppColors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Member selection header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Group Members',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  '${_selectedMemberIds.length} selected',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Search input
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search passenger name...',
                prefixIcon: Icon(Icons.search_rounded),
                fillColor: AppColors.white,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 14),

            // Passenger List
            ...filteredPassengers.map((p) {
              final isMe = me != null && p.id == me.id;
              final isSelected = _selectedMemberIds.contains(p.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.ink : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    activeColor: AppColors.ink,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    onChanged: isMe
                        ? null // You are always in your group
                        : (val) {
                            setState(() {
                              if (val == true) {
                                _selectedMemberIds.add(p.id);
                              } else {
                                _selectedMemberIds.remove(p.id);
                              }
                            });
                          },
                    title: Row(
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.mint.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'You',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      'Coach ${p.coach} · Seat ${p.seatNo}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    secondary: SeatChip(coach: p.coach, seatNo: p.seatNo),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      bottomSheet: Container(
        color: AppColors.cream,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: PrimaryButton(
            label: 'Create Group',
            isLoading: _isCreating,
            onPressed: _createGroup,
          ),
        ),
      ),
    );
  }
}
