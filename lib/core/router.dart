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
import '../features/seat_map/seat_map_screen.dart';
import '../features/select_passenger/select_passenger_screen.dart';
import '../features/swap/swap_detail_screen.dart';
import '../features/swap/swap_matches_screen.dart';
import '../features/swap/swap_preferences_screen.dart';
import '../features/trip_details/trip_details_screen.dart';
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
      if (loc == '/splash' ||
          loc == '/onboarding' ||
          loc == '/gallery') {
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
  bool _isShowingSheet = false;

  void _checkIncomingRequests(List<SwapRequest> incoming) {
    if (_isShowingSheet) return;
    final pending =
        incoming.where((r) => r.status == SwapRequestStatus.pending);
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
    final allPassengers =
        ref.read(tripPassengersProvider).valueOrNull ?? [];
    final requester =
        allPassengers.where((p) => p.id == request.requesterId).firstOrNull;

    _isShowingSheet = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => IncomingRequestSheet(
        request: request,
        requester: requester,
        me: me,
        onAccept: (reqId) async {
          final res = await ref.read(requestRepoProvider).accept(reqId);
          if (ctx.mounted) {
            if (res == 'invalid') {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('Seat changed, please find again.'),
                  backgroundColor: AppColors.rejected,
                ),
              );
            } else {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('Swap accepted! Your seat has been updated.'),
                  backgroundColor: AppColors.accepted,
                ),
              );
            }
          }
        },
        onReject: (reqId) async {
          await ref.read(requestRepoProvider).reject(reqId);
          if (ctx.mounted) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(
                content: Text('Swap declined.'),
                backgroundColor: AppColors.textSecondary,
              ),
            );
          }
        },
      ),
    ).whenComplete(() {
      _isShowingSheet = false;
      final incoming = ref.read(incomingRequestsProvider).valueOrNull ?? [];
      _checkIncomingRequests(incoming);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to realtime incoming requests
    ref.listen<AsyncValue<List<SwapRequest>>>(
      incomingRequestsProvider,
      (prev, next) {
        next.whenData((incoming) => _checkIncomingRequests(incoming));
      },
    );

    final incoming = ref.watch(incomingRequestsProvider).valueOrNull ?? [];
    final hasUnseenPending = incoming.any((r) =>
        r.status == SwapRequestStatus.pending &&
        !_seenIncomingReqIds.contains(r.id));
    if (hasUnseenPending) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _checkIncomingRequests(incoming);
      });
    }
    final pendingIncomingCount = incoming
        .where((r) => r.status == SwapRequestStatus.pending)
        .length;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: widget.navigationShell,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
