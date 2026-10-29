import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/status_chip.dart';
import '../../models/passenger.dart';
import '../../models/swap_request.dart';
import '../../providers/providers.dart';
import '../walkthrough/walkthrough_keys.dart';
import '../walkthrough/walkthrough_target.dart';
import 'swap_outcome_dialog.dart';

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

  Future<void> _handleReject(SwapRequest request, Passenger? requester) async {
    try {
      await ref.read(requestRepoProvider).reject(request.id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not decline this request. Please try again.'),
          backgroundColor: AppColors.rejected,
        ),
      );
      return;
    }
    if (!mounted) return;
    await showVolunteerSwapOutcomeDialog(
      context,
      result: SwapSheetResult.declined,
      request: request,
      requesterName: requester?.name ?? 'The passenger',
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

  void _findAnotherMatch(Iterable<SwapRequest> declined) {
    final targets = declined.map((request) => request.targetId).toSet();
    if (targets.isEmpty) return;
    final currentExcluded = ref.read(excludedIdsProvider);
    ref.read(excludedIdsProvider.notifier).state = {
      ...currentExcluded,
      ...targets,
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
    final myGroup = ref.watch(myGroupProvider);
    if (planId != _trackedPlanId) {
      _trackedPlanId = planId;
      _openedFinalPlan = false;
    }

    ref.listen<int?>(requestsTabIndexProvider, (_, next) {
      if (next == null || next < 0 || next >= _tabController.length) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _tabController.animateTo(next);
        if (ref.read(requestsTabIndexProvider) == next) {
          ref.read(requestsTabIndexProvider.notifier).state = null;
        }
      });
    });

    // Only the group that sent the plan should open the seating plan.
    // Volunteers who accept requests stay on the current screen.
    if (!_openedFinalPlan &&
        myGroup.isNotEmpty &&
        activePlanRequests.isNotEmpty &&
        activePlanRequests.every(
          (r) => r.status == SwapRequestStatus.accepted,
        )) {
      _openedFinalPlan = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.push('/final-plan');
      });
    }

    if (me == null) {
      return const Scaffold(body: Center(child: Text('No passenger selected')));
    }

    final pendingOutgoing = outgoingRequests
        .where((r) => r.status == SwapRequestStatus.pending)
        .toList();
    final acceptedOutgoing = outgoingRequests
        .where((r) => r.status == SwapRequestStatus.accepted)
        .toList();
    final rejectedOutgoing = outgoingRequests
        .where(
          (r) =>
              r.status == SwapRequestStatus.rejected ||
              r.status == SwapRequestStatus.invalid,
        )
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: WalkthroughTarget(
            id: WalkthroughTargetId.requestsTabs,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.ink,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.ink,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              tabs: [
                Tab(text: 'Incoming (${pendingIncoming.length})'),
                Tab(text: 'Pending (${pendingOutgoing.length})'),
                Tab(text: 'Accepted (${acceptedOutgoing.length})'),
                Tab(text: 'Rejected (${rejectedOutgoing.length})'),
              ],
            ),
          ),
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
            child: ListenableBuilder(
              listenable: _tabController,
              builder: (context, _) {
                return switch (_tabController.index) {
                  0 => _buildIncomingList(pendingIncoming, allPassengers, me),
                  1 => _buildOutgoingList(
                    pendingOutgoing,
                    allPassengers,
                    isPending: true,
                  ),
                  2 => _buildOutgoingList(
                    acceptedOutgoing,
                    allPassengers,
                    isAccepted: true,
                  ),
                  _ => _buildOutgoingList(
                    rejectedOutgoing,
                    allPassengers,
                    isRejected: true,
                  ),
                };
              },
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
    final declined = planRequests
        .where(
          (r) =>
              r.status == SwapRequestStatus.rejected ||
              r.status == SwapRequestStatus.invalid,
        )
        .toList();
    final rejectedCount = declined.length;
    final pendingCount = planRequests
        .where((r) => r.status == SwapRequestStatus.pending)
        .length;
    final totalCount = planRequests.length;
    final progress = totalCount > 0 ? acceptedCount / totalCount : 0.0;
    final statusLine = acceptedCount == totalCount
        ? 'All group swaps accepted. Your seating plan is ready.'
        : rejectedCount > 0 && pendingCount == 0
            ? acceptedCount > 0
                ? '$acceptedCount accepted, $rejectedCount declined. Replace the declined seats to finish the plan.'
                : rejectedCount == 1
                    ? 'A volunteer declined. Your seat is unchanged. Review the request and find another match.'
                    : '$rejectedCount volunteers declined. Review those requests and find other matches.'
            : rejectedCount > 0
                ? '$rejectedCount declined, $pendingCount still waiting for a reply.'
                : 'Waiting for volunteers to accept. A decline shows here and under Rejected.';

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
            children: [
              const Expanded(
                child: Text(
                  'GROUP ARRANGEMENT PROGRESS',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.mint,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
            statusLine,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: AppColors.white.withOpacity(0.7),
            ),
          ),
          if (rejectedCount > 0) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _findAnotherMatch(declined),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mint,
                  foregroundColor: AppColors.ink,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Find another match',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
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
      primary: false,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        final requester = allPassengers
            .where((p) => p.id == req.requesterId)
            .firstOrNull;

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
                        onPressed: () => _handleReject(req, requester),
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
                  : 'When a volunteer declines, the request appears here so you can choose someone else.'),
      );
    }

    return ListView.builder(
      primary: false,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        final target = allPassengers
            .where((p) => p.id == req.targetId)
            .firstOrNull;

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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            target?.name ?? 'Passenger',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            'Seat: ${req.targetSeat}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(status: req.status),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  'Your seat ${req.requesterSeat}  ➔  Their seat ${req.targetSeat}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
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
                  Text(
                    req.status == SwapRequestStatus.invalid
                        ? 'This swap closed because a seat changed. Your seat was not updated.'
                        : '${target?.name ?? 'This volunteer'} declined. Your seat was not changed.',
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: AppColors.rejected,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _findAnotherMatch([req]),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        minimumSize: const Size.fromHeight(44),
                      ),
                      child: const Text(
                        'Find another match',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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
