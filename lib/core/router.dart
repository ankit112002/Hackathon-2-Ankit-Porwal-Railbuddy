import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/final_plan/final_plan_screen.dart';
import '../features/gallery/widget_gallery_screen.dart';
import '../features/group/create_group_screen.dart';
import '../features/group/group_dashboard_screen.dart';
import '../features/group/join_group_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/optimizer/optimizer_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/requests/incoming_request_sheet.dart';
import '../features/requests/requests_screen.dart';
import '../features/requests/swap_outcome_dialog.dart';
import '../features/seat_map/seat_map_screen.dart';
import '../features/select_passenger/select_passenger_screen.dart';
import '../features/swap/swap_detail_screen.dart';
import '../features/swap/swap_matches_screen.dart';
import '../features/swap/swap_preferences_screen.dart';
import '../features/trip_details/trip_details_screen.dart';
import '../features/walkthrough/walkthrough_keys.dart';
import '../features/walkthrough/walkthrough_overlay.dart';
import '../features/walkthrough/walkthrough_target.dart';
import '../models/swap_request.dart';
import '../providers/providers.dart';
import 'theme/colors.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final sessionStore = ref.watch(sessionStoreProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final onboardingSeen = sessionStore.isOnboardingSeen();
      final passengerId = sessionStore.getPassengerId();

      final loc = state.uri.path;

      // Allow splash, onboarding, gallery, and select-passenger freely
      if (loc == '/splash' || loc == '/onboarding' || loc == '/gallery') {
        return null;
      }

      if (!onboardingSeen) {
        return '/onboarding';
      }

      if ((passengerId == null || passengerId.isEmpty) &&
          loc != '/select-passenger') {
        return '/select-passenger';
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Select Passenger
      GoRoute(
        path: '/select-passenger',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SelectPassengerScreen(),
      ),

      // Widget Gallery (Review)
      GoRoute(
        path: '/gallery',
        builder: (context, state) => const WidgetGalleryScreen(),
      ),

      // Sub-flows
      GoRoute(
        path: '/trip',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TripDetailsScreen(),
      ),
      GoRoute(
        path: '/group/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateGroupScreen(),
      ),
      GoRoute(
        path: '/group/join',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const JoinGroupScreen(),
      ),
      GoRoute(
        path: '/seat-map',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CoachSeatMapScreen(),
      ),
      GoRoute(
        path: '/swap/preferences',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SwapPreferencesScreen(),
      ),
      GoRoute(
        path: '/swap/matches',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SwapMatchesScreen(),
      ),
      GoRoute(
        path: '/swap/detail/:passengerId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => SwapDetailScreen(
          targetPassengerId: state.pathParameters['passengerId']!,
        ),
      ),
      GoRoute(
        path: '/optimizer',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OptimizerScreen(),
      ),
      GoRoute(
        path: '/final-plan',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FinalPlanScreen(),
      ),

      // 4 Main Tab Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppTabShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Branch 1: My Group
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/group',
                builder: (context, state) => const GroupDashboardScreen(),
              ),
            ],
          ),

          // Branch 2: Requests
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/requests',
                builder: (context, state) => const RequestsScreen(),
              ),
            ],
          ),

          // Branch 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class AppTabShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppTabShell({super.key, required this.navigationShell});

  @override
  ConsumerState<AppTabShell> createState() => _AppTabShellState();
}

class _AppTabShellState extends ConsumerState<AppTabShell> {
  final Set<String> _seenIncomingReqIds = {};
  final Map<String, Set<String>> _seenPendingOutgoingIds = {};
  bool _isShowingSheet = false;
  bool _outcomeDialogOpen = false;
  bool _askedToStartTour = false;
  GoRouterDelegate? _routerDelegate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final delegate = GoRouter.of(context).routerDelegate;
    if (!identical(_routerDelegate, delegate)) {
      _routerDelegate?.removeListener(_handleRouteChange);
      _routerDelegate = delegate;
      _routerDelegate!.addListener(_handleRouteChange);
    }
  }

  void _handleRouteChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _routerDelegate?.removeListener(_handleRouteChange);
    super.dispose();
  }

  void _queueTourStart() {
    if (_askedToStartTour) return;
    if (ref.read(currentPassengerProvider) == null) return;
    _askedToStartTour = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(walkthroughControllerProvider.notifier).startIfNeeded();
    });
  }

  void _checkIncomingRequests(List<SwapRequest> incoming) {
    if (_isShowingSheet) return;
    if (ref.read(walkthroughControllerProvider).active) return;
    final pending = incoming.where(
      (r) => r.status == SwapRequestStatus.pending,
    );
    for (final req in pending) {
      if (_seenIncomingReqIds.contains(req.id)) continue;
      _seenIncomingReqIds.add(req.id);
      _showIncomingModal(req);
      return;
    }
  }

  void _showIncomingModal(SwapRequest request) {
    final me = ref.read(currentPassengerProvider);
    if (me == null) {
      _seenIncomingReqIds.remove(request.id);
      _isShowingSheet = false;
      return;
    }
    final allPassengers = ref.read(tripPassengersProvider).valueOrNull ?? [];
    final requester = allPassengers
        .where((p) => p.id == request.requesterId)
        .firstOrNull;

    _isShowingSheet = true;
    showModalBottomSheet<SwapSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => IncomingRequestSheet(
        request: request,
        requester: requester,
        me: me,
        onAccept: (reqId) => ref.read(requestRepoProvider).accept(reqId),
        onReject: (reqId) => ref.read(requestRepoProvider).reject(reqId),
      ),
    ).then((result) async {
      _isShowingSheet = false;
      if (!mounted) return;
      if (result != null) {
        await _showVolunteerOutcome(
          result: result,
          request: request,
          requesterName: requester?.name ?? 'The passenger',
        );
      }
      if (!mounted) return;
      final incoming = ref.read(incomingRequestsProvider).valueOrNull ?? [];
      _checkIncomingRequests(incoming);
      final outgoing = ref.read(outgoingRequestsProvider).valueOrNull;
      if (outgoing != null) _onOutgoingUpdate(outgoing);
    });
  }

  Future<void> _showVolunteerOutcome({
    required SwapSheetResult result,
    required SwapRequest request,
    required String requesterName,
  }) async {
    if (!mounted || _outcomeDialogOpen) return;
    _outcomeDialogOpen = true;
    try {
      await showVolunteerSwapOutcomeDialog(
        context,
        result: result,
        request: request,
        requesterName: requesterName,
      );
    } finally {
      _outcomeDialogOpen = false;
    }
  }

  void _onOutgoingUpdate(List<SwapRequest> outgoing) {
    final me = ref.read(currentPassengerProvider);
    if (me == null) return;

    final pendingIds = {
      for (final request in outgoing)
        if (request.status == SwapRequestStatus.pending) request.id,
    };
    final previous = _seenPendingOutgoingIds[me.id];
    if (previous == null) {
      _seenPendingOutgoingIds[me.id] = pendingIds;
      return;
    }

    final newlyDeclined = outgoing.where((request) {
      final closed = request.status == SwapRequestStatus.rejected ||
          request.status == SwapRequestStatus.invalid;
      return closed && previous.contains(request.id);
    }).toList();
    if (newlyDeclined.isEmpty) {
      _seenPendingOutgoingIds[me.id] = pendingIds;
      return;
    }
    if (_outcomeDialogOpen ||
        _isShowingSheet ||
        !mounted ||
        ref.read(walkthroughControllerProvider).active) {
      return;
    }

    _seenPendingOutgoingIds[me.id] = pendingIds;
    _presentOutgoingDeclines(newlyDeclined);
  }

  Future<void> _presentOutgoingDeclines(List<SwapRequest> requests) async {
    if (!mounted || _outcomeDialogOpen) return;
    _outcomeDialogOpen = true;
    try {
      final passengers = ref.read(tripPassengersProvider).valueOrNull ?? [];
      await showRequesterDeclinedDialog(
        context,
        requests: requests,
        passengers: passengers,
        onViewRejected: () {
          ref.read(requestsTabIndexProvider.notifier).state = 3;
          widget.navigationShell.goBranch(2);
        },
      );
    } finally {
      _outcomeDialogOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to realtime incoming requests
    ref.listen<AsyncValue<List<SwapRequest>>>(incomingRequestsProvider, (
      prev,
      next,
    ) {
      next.whenData((incoming) => _checkIncomingRequests(incoming));
    });
    final outgoingNow = ref.read(outgoingRequestsProvider).valueOrNull;
    final me = ref.read(currentPassengerProvider);
    if (outgoingNow != null &&
        me != null &&
        !_seenPendingOutgoingIds.containsKey(me.id)) {
      _seenPendingOutgoingIds[me.id] = {
        for (final request in outgoingNow)
          if (request.status == SwapRequestStatus.pending) request.id,
      };
    }
    ref.listen<AsyncValue<List<SwapRequest>>>(outgoingRequestsProvider, (
      prev,
      next,
    ) {
      next.whenData(_onOutgoingUpdate);
    });
    ref.listen(walkthroughControllerProvider, (prev, next) {
      final wasActive = prev?.active ?? false;
      if (wasActive && !next.active) {
        final pending = ref.read(incomingRequestsProvider).valueOrNull ?? [];
        _checkIncomingRequests(pending);
        final outgoing = ref.read(outgoingRequestsProvider).valueOrNull;
        if (outgoing != null) _onOutgoingUpdate(outgoing);
      }
    });

    _queueTourStart();

    final tour = ref.watch(walkthroughControllerProvider);
    final shellIsCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    final incoming = ref.watch(incomingRequestsProvider).valueOrNull ?? [];
    final hasUnseenPending = incoming.any(
      (r) =>
          r.status == SwapRequestStatus.pending &&
          !_seenIncomingReqIds.contains(r.id),
    );
    if (hasUnseenPending && !tour.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _checkIncomingRequests(incoming);
      });
    }
    final pendingIncomingCount = incoming
        .where((r) => r.status == SwapRequestStatus.pending)
        .length;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Expanded(child: widget.navigationShell),
              WalkthroughTarget(
                id: WalkthroughTargetId.bottomNav,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
                  color: Colors.transparent,
                  child: Container(
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ink.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(
                          index: 0,
                          icon: Icons.home_rounded,
                          label: 'Home',
                        ),
                        _buildNavItem(
                          index: 1,
                          icon: Icons.groups_rounded,
                          label: 'My Group',
                        ),
                        _buildNavItem(
                          index: 2,
                          icon: Icons.swap_horiz_rounded,
                          label: 'Requests',
                          badgeCount: pendingIncomingCount,
                        ),
                        _buildNavItem(
                          index: 3,
                          icon: Icons.person_rounded,
                          label: 'Profile',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (tour.active && shellIsCurrent)
            Positioned.fill(
              child: WalkthroughOverlay(
                navigationShell: widget.navigationShell,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    int badgeCount = 0,
  }) {
    final isSelected = widget.navigationShell.currentIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: isSelected
                        ? AppColors.mint
                        : AppColors.white.withOpacity(0.5),
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.mint,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$badgeCount',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.mint
                      : AppColors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
