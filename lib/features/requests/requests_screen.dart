import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/status_chip.dart';
import '../../models/passenger.dart';
import '../../models/swap_request.dart';
import '../../providers/providers.dart';

class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _openedFinalPlan = false;
  String? _trackedPlanId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleAccept(String reqId) async {
    final res = await ref.read(requestRepoProvider).accept(reqId);
    if (!mounted) return;
    if (res == 'invalid') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seat changed, please find again.'),
          backgroundColor: AppColors.rejected,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Swap accepted! Seats updated in database.'),
          backgroundColor: AppColors.accepted,
        ),
      );
    }
  }

  Future<void> _handleReject(String reqId) async {
    await ref.read(requestRepoProvider).reject(reqId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Swap request rejected.'),
        backgroundColor: AppColors.textSecondary,
      ),
    );
  }

  Future<void> _handleCancel(String reqId) async {
    await ref.read(requestRepoProvider).cancel(reqId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Swap request cancelled.'),
        backgroundColor: AppColors.textSecondary,
      ),
    );
  }

  void _findAnotherMatch(SwapRequest request) {
    // Add target volunteer to excludedIds and open optimizer
    final currentExcluded = ref.read(excludedIdsProvider);
    ref.read(excludedIdsProvider.notifier).state = {
      ...currentExcluded,
      request.targetId,
    };
    context.push('/optimizer');
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentPassengerProvider);
    final allPassengers = ref.watch(tripPassengersProvider).valueOrNull ?? [];
    final incomingRequests =
        ref.watch(incomingRequestsProvider).valueOrNull ?? [];
    final outgoingRequests =
        ref.watch(outgoingRequestsProvider).valueOrNull ?? [];
    final activePlanRequests =
        ref.watch(activePlanRequestsProvider).valueOrNull ?? [];
    final planId = ref.watch(activePlanIdProvider);
    if (planId != _trackedPlanId) {
      _trackedPlanId = planId;
      _openedFinalPlan = false;
    }

    if (!_openedFinalPlan &&
        activePlanRequests.isNotEmpty &&
        activePlanRequests.every((r) => r.status == SwapRequestStatus.accepted)) {
      _openedFinalPlan = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/final-plan');
      });
    }

    if (me == null) {
      return const Scaffold(
        body: Center(child: Text('No passenger selected')),
      );
    }

    final pendingOutgoing = outgoingRequests
        .where((r) => r.status == SwapRequestStatus.pending)
        .toList();
    final acceptedOutgoing = outgoingRequests
        .where((r) => r.status == SwapRequestStatus.accepted)
        .toList();
    final rejectedOutgoing = outgoingRequests
        .where((r) =>
            r.status == SwapRequestStatus.rejected ||
            r.status == SwapRequestStatus.invalid)
        .toList();
    final pendingIncoming = incomingRequests
        .where((r) => r.status == SwapRequestStatus.pending)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text(
          'Swap Requests',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.ink,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.ink,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: [
            Tab(text: 'Incoming (${pendingIncoming.length})'),
            Tab(text: 'Pending (${pendingOutgoing.length})'),
            Tab(text: 'Accepted (${acceptedOutgoing.length})'),
            Tab(text: 'Rejected (${rejectedOutgoing.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Active Plan Progress Card (if any active plan exists)
          if (activePlanRequests.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: _buildPlanProgressCard(activePlanRequests),
            ),
          ],

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Incoming Tab
                _buildIncomingList(pendingIncoming, allPassengers, me),

                // 2. Pending Outgoing Tab
                _buildOutgoingList(
                  pendingOutgoing,
                  allPassengers,
                  isPending: true,
                ),

                // 3. Accepted Outgoing Tab
                _buildOutgoingList(
                  acceptedOutgoing,
                  allPassengers,
                  isAccepted: true,
                ),

                // 4. Rejected Outgoing Tab
                _buildOutgoingList(
                  rejectedOutgoing,
                  allPassengers,
                  isRejected: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanProgressCard(List<SwapRequest> planRequests) {
    final acceptedCount = planRequests
        .where((r) => r.status == SwapRequestStatus.accepted)
        .length;
    final totalCount = planRequests.length;
    final progress = totalCount > 0 ? acceptedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'GROUP ARRANGEMENT PROGRESS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.mint,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.mint.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$acceptedCount of $totalCount Accepted',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mint,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.white.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mint),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            acceptedCount == totalCount
                ? 'All group swaps accepted! Generating final seating plan...'
                : 'Waiting for volunteers to accept swap requests.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingList(
    List<SwapRequest> requests,
    List<Passenger> allPassengers,
    Passenger me,
  ) {
    if (requests.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_rounded,
        title: 'No Incoming Requests',
        description:
            'When fellow passengers request a seat swap with you, their requests will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        final requester =
            allPassengers.where((p) => p.id == req.requesterId).firstOrNull;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.mint,
                      child: Text(
                        requester?.name.isNotEmpty == true
                            ? requester!.name[0]
                            : '?',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            requester?.name ?? 'Passenger',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const Text(
                            'Wants to swap seats with you',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusChip(status: req.status),
                  ],
                ),
                const SizedBox(height: 14),

                // Seat Comparison Row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.fieldGrey,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Your Seat',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            req.targetSeat,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.swap_horiz_rounded,
                        color: AppColors.textSecondary,
                      ),
                      Column(
                        children: [
                          const Text(
                            'Offered Seat',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            req.requesterSeat,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0D6B49),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Accept & Reject Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _handleReject(req.id),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.rejected,
                          side: const BorderSide(color: AppColors.rejected),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleAccept(req.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mint,
                          foregroundColor: AppColors.ink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Accept Swap',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOutgoingList(
    List<SwapRequest> requests,
    List<Passenger> allPassengers, {
    bool isPending = false,
    bool isAccepted = false,
    bool isRejected = false,
  }) {
    if (requests.isEmpty) {
      return EmptyState(
        icon: Icons.send_rounded,
        title: isPending
            ? 'No Pending Requests'
            : (isAccepted ? 'No Accepted Swaps' : 'No Rejected Requests'),
        description: isPending
            ? 'Sent swap requests awaiting response will appear here.'
            : (isAccepted
                ? 'Accepted swaps will show here once passengers agree.'
                : 'Any declined requests will appear here with retry options.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        final target =
            allPassengers.where((p) => p.id == req.targetId).firstOrNull;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.mint.withOpacity(0.3),
                          child: Text(
                            target?.name.isNotEmpty == true
                                ? target!.name[0]
                                : '?',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              target?.name ?? 'Passenger',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              'Seat: ${req.targetSeat}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    StatusChip(status: req.status),
                  ],
                ),
                const SizedBox(height: 12),

                // Snapshot row
                Row(
                  children: [
                    Text(
                      'Your seat ${req.requesterSeat}  ➔  Their seat ${req.targetSeat}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),

                // Actions
                if (isPending) ...[
                  const Divider(height: 20, color: AppColors.border),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _handleCancel(req.id),
                      child: const Text(
                        'Cancel Request',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],

                if (isRejected) ...[
                  const Divider(height: 20, color: AppColors.border),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Swap was not accepted',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.rejected,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _findAnotherMatch(req),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.ink,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        child: const Text(
                          'Find another match',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
